--[[
    Universal UI Library
    Reusable Roblox UI framework based on the original interface layout.
    Neutral branding, no game-specific logic, no pause system.
]]

local Players = game:GetService("Players")
local Input = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

local Library = {}
Library.__index = Library

local ColorPickerModule

local function getColorPickerModule()
    if ColorPickerModule then
        return ColorPickerModule
    end

    local ok, result = pcall(function()
        local source = game:HttpGet(
            "https://raw.githubusercontent.com/deepisthatdeep/Ermidklolui/main/ColorPicker.lua?rev=961f1da"
        )
        return loadstring(source)()
    end)

    if ok and type(result) == "table" and type(result.Create) == "function" then
        ColorPickerModule = result
        return ColorPickerModule
    end

    warn("[UI Library] color picker failed to load:", result)
    return nil
end

Library.Palette = {
    bg = Color3.fromRGB(4, 6, 14),
    card = Color3.fromRGB(10, 14, 29),
    line = Color3.fromRGB(70, 86, 138),
    accent = Color3.fromRGB(176, 148, 255),
    accent2 = Color3.fromRGB(104, 224, 255),
    glow = Color3.fromRGB(220, 242, 255),
    bright = Color3.fromRGB(246, 249, 255),
    text = Color3.fromRGB(255, 255, 255),
    muted = Color3.fromRGB(224, 230, 245),
}

local function copy(source)
    local out = {}
    for key, value in pairs(source or {}) do
        out[key] = value
    end
    return out
end

local function colorToHex(color)
    return string.format(
        "#%02X%02X%02X",
        math.floor(color.R * 255 + .5),
        math.floor(color.G * 255 + .5),
        math.floor(color.B * 255 + .5)
    )
end

local function hexToColor(value)
    if typeof(value) == "Color3" then
        return value
    end

    value = tostring(value or ""):gsub("#", ""):gsub("%s+", "")
    if #value == 3 then
        value = value:sub(1, 1):rep(2)
            .. value:sub(2, 2):rep(2)
            .. value:sub(3, 3):rep(2)
    end

    if #value ~= 6 or value:find("[^%x]") then
        return nil
    end

    return Color3.fromRGB(
        tonumber(value:sub(1, 2), 16),
        tonumber(value:sub(3, 4), 16),
        tonumber(value:sub(5, 6), 16)
    )
end

local function make(className, parent, props)
    local object = Instance.new(className)
    for key, value in pairs(props or {}) do
        object[key] = value
    end
    object.Parent = parent
    return object
end

local function safeCall(callback, ...)
    if typeof(callback) ~= "function" then
        return
    end

    local args = table.pack(...)
    task.spawn(function()
        local ok, err = pcall(callback, table.unpack(args, 1, args.n))
        if not ok then
            warn("[UI Library] callback error:", err)
        end
    end)
end

local function proxy(initial, setter)
    local valueObject = {Current = initial}

    function valueObject:Get()
        return self.Current
    end

    function valueObject:Set(value)
        setter(value)
    end

    return valueObject
end

local function defaultParent()
    if gethui then
        local ok, result = pcall(gethui)
        if ok and result then
            return result
        end
    end

    return LocalPlayer:WaitForChild("PlayerGui")
end

local function resolvePalette(custom)
    local palette = copy(Library.Palette)

    if type(custom) == "table" then
        for key, value in pairs(custom) do
            if palette[key] ~= nil and typeof(value) == "Color3" then
                palette[key] = value
            end
        end
    end

    return palette
end

function Library:CreateWindow(cfg)
    cfg = cfg or {}

    local P = resolvePalette(cfg.Palette)
    local DefaultPalette = copy(P)
    local paletteFile = tostring(cfg.PaletteFile or "Ermidklolui_palette.json")

    local function readSavedPalette()
        if type(isfile) ~= "function" or type(readfile) ~= "function" then
            return nil
        end

        local okExists, exists = pcall(isfile, paletteFile)
        if not okExists or not exists then
            return nil
        end

        local okRead, raw = pcall(readfile, paletteFile)
        if not okRead or type(raw) ~= "string" then
            return nil
        end

        local okDecode, decoded = pcall(function()
            return HttpService:JSONDecode(raw)
        end)

        if not okDecode or type(decoded) ~= "table" then
            return nil
        end

        local source = decoded.colors or decoded
        local loaded = {}

        for key in pairs(P) do
            local parsed = hexToColor(source[key])
            if parsed then
                loaded[key] = parsed
            end
        end

        return loaded
    end

    if cfg.AutoLoadPalette ~= false then
        local saved = readSavedPalette()
        if saved then
            for key, value in pairs(saved) do
                P[key] = value
            end
        end
    end

    local connections = {}
    local refresh = {}
    local tabs = {}
    local pages = {}
    local nav = {}
    local alive = true
    local activeTab = nil
    local capturingKey = false

    local title = tostring(cfg.Title or "AETHER")
    local subtitleText = tostring(cfg.SubTitle or "S P E C T R A L")
    local productName = tostring(cfg.ProductName or "PRISM")
    local currentPage = tostring(cfg.CurrentPage or "OVERVIEW")
    local versionText = tostring(cfg.Version or "UI LIBRARY")

    local toggleKey = cfg.ToggleKey == false and nil or (cfg.ToggleKey or Enum.KeyCode.RightShift)
    local unloadKey = cfg.UnloadKey == false and nil or (cfg.UnloadKey or Enum.KeyCode.F9)

    local function bind(signal, callback)
        local connection = signal:Connect(callback)
        table.insert(connections, connection)
        return connection
    end

    local gui = make("ScreenGui", cfg.Parent or defaultParent(), {
        Name = tostring(cfg.Name or "UniversalInterface"),
        ResetOnSpawn = false,
        IgnoreGuiInset = false,
        Enabled = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = tonumber(cfg.DisplayOrder) or 100,
    })

    pcall(function()
        if syn and syn.protect_gui then
            syn.protect_gui(gui)
        end
    end)

    local window = make("Frame", gui, {
        Size = UDim2.fromOffset(940, 610),
        Position = UDim2.new(.5, -470, .5, -305),
        BackgroundColor3 = P.bg,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Active = true,
    })

    make("UIStroke", window, {
        Color = P.line,
        Thickness = 1,
    })

    local windowGradient = make("UIGradient", window, {
        Rotation = 118,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, P.bg),
            ColorSequenceKeypoint.new(.38, Color3.fromRGB(9, 12, 26)),
            ColorSequenceKeypoint.new(.72, Color3.fromRGB(10, 8, 25)),
            ColorSequenceKeypoint.new(1, P.bg),
        }),
    })

    local outerGlow = make("Frame", window, {
        Name = "OuterGlow",
        Position = UDim2.fromOffset(5, 5),
        Size = UDim2.new(1, -10, 1, -10),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    })

    make("UIStroke", outerGlow, {
        Color = P.accent2,
        Thickness = 1,
        Transparency = .82,
    })

    local innerGlow = make("Frame", window, {
        Name = "InnerGlow",
        Position = UDim2.fromOffset(10, 10),
        Size = UDim2.new(1, -20, 1, -20),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    })

    make("UIStroke", innerGlow, {
        Color = P.accent,
        Thickness = 1,
        Transparency = .88,
    })

    local scale = make("UIScale", window, {
        Scale = 1,
    })

    local function text(parent, value, x, y, w, h, size, color, font)
        return make("TextLabel", parent, {
            Text = tostring(value or ""),
            Position = UDim2.fromOffset(x, y),
            Size = UDim2.fromOffset(w, h),
            BackgroundTransparency = 1,
            TextColor3 = color or P.text,
            TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
            TextStrokeTransparency = .22,
            Font = font or Enum.Font.Code,
            TextSize = size or 12,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            ZIndex = 9,
        })
    end

    -- Layered celestial/prismatic background field.
    local art = make("Frame", window, {
        Name = "SpectralField",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
    })

    local glowA = make("Frame", art, {
        Position = UDim2.fromOffset(535, -145),
        Size = UDim2.fromOffset(380, 380),
        BackgroundColor3 = P.accent2,
        BackgroundTransparency = .95,
        BorderSizePixel = 0,
    })
    make("UICorner", glowA, {CornerRadius = UDim.new(1, 0)})
    make("UIGradient", glowA, {
        Rotation = 35,
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, .82),
            NumberSequenceKeypoint.new(.45, .92),
            NumberSequenceKeypoint.new(1, 1),
        }),
    })

    local glowB = make("Frame", art, {
        Position = UDim2.fromOffset(-155, 265),
        Size = UDim2.fromOffset(430, 430),
        BackgroundColor3 = P.accent,
        BackgroundTransparency = .96,
        BorderSizePixel = 0,
    })
    make("UICorner", glowB, {CornerRadius = UDim.new(1, 0)})

    local horizon = make("Frame", art, {
        Position = UDim2.fromOffset(175, 74),
        Size = UDim2.fromOffset(655, 2),
        BackgroundColor3 = P.glow,
        BackgroundTransparency = .82,
        BorderSizePixel = 0,
    })
    make("UIGradient", horizon, {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, P.accent),
            ColorSequenceKeypoint.new(.5, P.accent2),
            ColorSequenceKeypoint.new(1, P.accent),
        }),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(.15, .2),
            NumberSequenceKeypoint.new(.5, 0),
            NumberSequenceKeypoint.new(.85, .2),
            NumberSequenceKeypoint.new(1, 1),
        }),
    })

    local function line(parent, x, y, w, h, angle, color, transparency)
        return make("Frame", parent, {
            Position = UDim2.fromOffset(x, y),
            Size = UDim2.fromOffset(w, h),
            Rotation = angle or 0,
            BackgroundColor3 = color or P.line,
            BackgroundTransparency = transparency or 0,
            BorderSizePixel = 0,
        })
    end

    local function diamond(parent, x, y, size, color, transparency)
        return line(
            parent,
            x,
            y,
            size or 7,
            size or 7,
            45,
            color or P.line,
            transparency or 0
        )
    end

    local function ring(parent, x, y, size, color, transparency, thickness)
        local holder = make("Frame", parent, {
            Position = UDim2.fromOffset(x, y),
            Size = UDim2.fromOffset(size, size),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
        })

        make("UICorner", holder, {
            CornerRadius = UDim.new(1, 0),
        })

        make("UIStroke", holder, {
            Color = color or P.line,
            Transparency = transparency or 0,
            Thickness = thickness or 1,
        })

        return holder
    end

    -- Celestial field: circular halos, orbital arcs, star nodes, and constellation links.
    -- This replaces the old rigid lattice/grid while keeping the original frame language.
    local function dot(parent, x, y, size, color, transparency)
        local node = make("Frame", parent, {
            Position = UDim2.fromOffset(x, y),
            Size = UDim2.fromOffset(size or 3, size or 3),
            BackgroundColor3 = color or P.glow,
            BackgroundTransparency = transparency or 0,
            BorderSizePixel = 0,
        })

        make("UICorner", node, {
            CornerRadius = UDim.new(1, 0),
        })

        return node
    end

    local function orbitArc(parent, cx, cy, radius, startAngle, endAngle, segments, color, transparency, thickness)
        segments = math.max(4, segments or 18)
        local step = (endAngle - startAngle) / segments

        for index = 0, segments - 1 do
            local a0 = math.rad(startAngle + step * index)
            local a1 = math.rad(startAngle + step * (index + 1))
            local x0 = cx + math.cos(a0) * radius
            local y0 = cy + math.sin(a0) * radius
            local x1 = cx + math.cos(a1) * radius
            local y1 = cy + math.sin(a1) * radius
            local dx = x1 - x0
            local dy = y1 - y0
            local length = math.sqrt(dx * dx + dy * dy)
            local angle = math.deg(math.atan2(dy, dx))

            line(
                parent,
                x0,
                y0,
                length + 1,
                thickness or 1,
                angle,
                color or P.line,
                transparency or .9
            )
        end
    end

    local function constellation(parent, points, color, transparency)
        for index, point in ipairs(points) do
            local nodeColor = point[4] or color or P.glow
            local nodeSize = point[3] or 3

            dot(
                parent,
                point[1] - nodeSize / 2,
                point[2] - nodeSize / 2,
                nodeSize,
                nodeColor,
                math.max(0, (transparency or .7) - .18)
            )

            if index > 1 and point[5] ~= false then
                local previous = points[index - 1]
                local dx = point[1] - previous[1]
                local dy = point[2] - previous[2]
                local length = math.sqrt(dx * dx + dy * dy)
                local angle = math.deg(math.atan2(dy, dx))

                line(
                    parent,
                    previous[1],
                    previous[2],
                    length,
                    1,
                    angle,
                    color or P.line,
                    transparency or .9
                )
            end
        end
    end

    -- Keep only quiet perimeter structure.
    for _, x in ipairs({8, 930}) do
        line(art, x, 8, 1, 594, 0, P.line, .2)
    end

    for _, y in ipairs({8, 600}) do
        line(art, 8, y, 922, 1, 0, P.line, .2)
    end

    for _, cornerData in ipairs({
        {15, 15},
        {815, 15},
        {15, 533},
        {815, 533},
    }) do
        line(art, cornerData[1], cornerData[2], 20, 1, 0, P.accent, .28)
        line(art, cornerData[1], cornerData[2], 1, 20, 0, P.accent, .28)
        diamond(art, cornerData[1] + 5, cornerData[2] + 5, 7, P.line, .35)
    end

    -- Header constellation crown.
    orbitArc(art, 421, 42, 66, 205, 335, 16, P.accent2, .78, 1)
    orbitArc(art, 421, 42, 48, 202, 338, 14, P.accent, .84, 1)
    diamond(art, 417, 28, 8, P.accent, .12)
    dot(art, 363, 54, 3, P.glow, .45)
    dot(art, 477, 54, 3, P.glow, .45)

    constellation(art, {
        {352, 47, 3, P.accent2},
        {383, 31, 4, P.glow},
        {421, 28, 5, P.accent},
        {459, 31, 4, P.glow},
        {490, 47, 3, P.accent2},
    }, P.line, .78)

    -- Large upper-left halo group in the main content field.
    ring(art, 225, 104, 154, P.accent2, .91, 1)
    ring(art, 247, 126, 110, P.line, .88, 1)
    ring(art, 270, 149, 64, P.accent, .84, 1)
    orbitArc(art, 302, 181, 93, 18, 152, 20, P.accent2, .84, 1)
    orbitArc(art, 302, 181, 76, 196, 322, 18, P.accent, .88, 1)
    dot(art, 299, 178, 6, P.glow, .5)
    diamond(art, 345, 116, 5, P.accent2, .42)

    constellation(art, {
        {215, 126, 3, P.glow},
        {248, 112, 4, P.accent2},
        {281, 136, 3, P.glow},
        {315, 120, 5, P.accent},
        {350, 145, 3, P.glow},
        {379, 127, 3, P.accent2},
    }, P.line, .88)

    -- Main right-side orrery: all circular, no cross-grid.
    local orbit = make("Frame", art, {
        Name = "CelestialOrrery",
        Position = UDim2.fromOffset(610, 135),
        Size = UDim2.fromOffset(235, 235),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    })

    ring(orbit, 5, 5, 225, P.accent2, .86, 1)
    ring(orbit, 24, 24, 187, P.line, .83, 1)
    ring(orbit, 48, 48, 139, P.accent, .87, 1)
    ring(orbit, 77, 77, 81, P.line, .82, 1)
    ring(orbit, 101, 101, 33, P.glow, .82, 1)

    orbitArc(orbit, 117, 117, 102, 16, 124, 20, P.accent2, .64, 1)
    orbitArc(orbit, 117, 117, 102, 196, 304, 20, P.accent, .68, 1)
    orbitArc(orbit, 117, 117, 73, 116, 250, 18, P.line, .73, 1)
    orbitArc(orbit, 117, 117, 51, 286, 414, 16, P.glow, .8, 1)

    for angle = 0, 330, 30 do
        local radians = math.rad(angle)
        local radius = angle % 60 == 0 and 105 or 91
        local x = 117 + math.cos(radians) * radius
        local y = 117 + math.sin(radians) * radius
        local size = angle % 90 == 0 and 5 or 3

        dot(
            orbit,
            x - size / 2,
            y - size / 2,
            size,
            angle % 60 == 0 and P.accent2 or P.glow,
            angle % 60 == 0 and .36 or .55
        )
    end

    diamond(orbit, 113, 113, 8, P.glow, .34)
    dot(orbit, 72, 52, 4, P.accent, .38)
    dot(orbit, 170, 156, 4, P.accent2, .38)

    constellation(orbit, {
        {36, 154, 3, P.glow},
        {65, 130, 4, P.accent2},
        {96, 145, 3, P.glow},
        {126, 126, 5, P.accent},
        {156, 142, 3, P.glow},
        {190, 118, 4, P.accent2},
    }, P.line, .86)

    -- Lower halo group replacing the old lower lancet/grid region.
    local lowerHalo = make("Frame", art, {
        Name = "LowerHalo",
        Position = UDim2.fromOffset(315, 326),
        Size = UDim2.fromOffset(300, 165),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    })

    ring(lowerHalo, 8, 0, 164, P.accent, .9, 1)
    ring(lowerHalo, 29, 21, 122, P.line, .86, 1)
    ring(lowerHalo, 54, 46, 72, P.accent2, .86, 1)
    orbitArc(lowerHalo, 90, 82, 76, 210, 340, 18, P.accent2, .72, 1)
    orbitArc(lowerHalo, 90, 82, 57, 18, 150, 18, P.accent, .78, 1)

    ring(lowerHalo, 175, 23, 112, P.line, .9, 1)
    orbitArc(lowerHalo, 231, 79, 51, 36, 194, 18, P.accent2, .78, 1)
    orbitArc(lowerHalo, 231, 79, 37, 212, 366, 16, P.accent, .82, 1)
    dot(lowerHalo, 226, 74, 7, P.glow, .47)

    constellation(lowerHalo, {
        {12, 118, 3, P.glow},
        {49, 103, 4, P.accent2},
        {83, 122, 3, P.glow},
        {124, 105, 4, P.accent},
        {163, 127, 3, P.glow},
        {203, 108, 4, P.accent2},
        {245, 126, 3, P.glow},
        {286, 107, 4, P.accent},
    }, P.line, .88)

    -- Left sidebar constellation spine.
    orbitArc(art, 91, 221, 59, 92, 268, 18, P.accent2, .87, 1)
    orbitArc(art, 91, 221, 42, 274, 446, 16, P.accent, .9, 1)

    constellation(art, {
        {31, 118, 3, P.glow},
        {57, 150, 4, P.accent2},
        {38, 190, 3, P.glow},
        {66, 228, 4, P.accent},
        {43, 267, 3, P.glow},
        {70, 306, 4, P.accent2},
        {46, 346, 3, P.glow},
        {78, 381, 4, P.accent},
    }, P.line, .89)

    -- Crescent / moon cluster.
    local crescentHolder = make("Frame", art, {
        Position = UDim2.fromOffset(73, 357),
        Size = UDim2.fromOffset(88, 88),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    })

    ring(crescentHolder, 0, 0, 88, P.accent2, .76, 1)
    ring(crescentHolder, 15, 6, 76, P.bg, .12, 13)
    orbitArc(crescentHolder, 44, 44, 38, 105, 256, 14, P.accent, .62, 1)
    dot(crescentHolder, 14, 59, 5, P.accent, .3)
    dot(crescentHolder, 52, 10, 4, P.glow, .42)

    -- Sparse star scatter; deterministic positions keep the artwork stable.
    local starScatter = {
        {196, 92, 2}, {228, 249, 3}, {267, 294, 2}, {326, 91, 2},
        {391, 173, 3}, {438, 112, 2}, {473, 277, 3}, {515, 191, 2},
        {556, 96, 3}, {585, 292, 2}, {621, 408, 3}, {669, 103, 2},
        {713, 418, 3}, {760, 389, 2}, {801, 94, 3}, {829, 454, 2},
        {245, 423, 3}, {285, 467, 2}, {414, 451, 3}, {523, 434, 2},
        {572, 468, 3}, {681, 462, 2}, {747, 479, 3}, {805, 440, 2},
    }

    for index, star in ipairs(starScatter) do
        local color = index % 5 == 0 and P.accent2
            or index % 3 == 0 and P.accent
            or P.glow

        dot(
            art,
            star[1],
            star[2],
            star[3],
            color,
            .5 + (index % 4) * .08
        )
    end

    -- Footer rail remains as the only strong straight guide across the content.
    line(art, 186, 488, 642, 1, 0, P.line, .55)
    diamond(art, 505, 485, 7, P.accent, .22)
    dot(art, 509, 512, 4, P.glow, .5)

    local contentVeil = make("Frame", window, {
        Name = "ContentGlass",
        Position = UDim2.fromOffset(202, 16),
        Size = UDim2.fromOffset(718, 578),
        BackgroundColor3 = P.card,
        BackgroundTransparency = .68,
        BorderSizePixel = 0,
    })

    make("UIGradient", contentVeil, {
        Rotation = 132,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(14, 20, 37)),
            ColorSequenceKeypoint.new(.48, Color3.fromRGB(9, 12, 25)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 11, 32)),
        }),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, .48),
            NumberSequenceKeypoint.new(.5, .66),
            NumberSequenceKeypoint.new(1, .52),
        }),
    })

    -- Inner content frame with clipped-corner illusion.
    local innerFrame = make("Frame", window, {
        Name = "InnerContentFrame",
        Position = UDim2.fromOffset(214, 68),
        Size = UDim2.fromOffset(697, 474),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    })

    make("UIStroke", innerFrame, {
        Color = P.line,
        Thickness = 1,
        Transparency = .62,
    })

    for _, cornerData in ipairs({
        {0, 0, 1, 1},
        {697, 0, -1, 1},
        {0, 474, 1, -1},
        {697, 474, -1, -1},
    }) do
        local x, y, sx, sy = table.unpack(cornerData)
        line(
            innerFrame,
            x + (sx < 0 and -20 or 0),
            y,
            20,
            1,
            0,
            P.accent,
            .24
        )
        line(
            innerFrame,
            x,
            y + (sy < 0 and -20 or 0),
            1,
            20,
            0,
            P.accent,
            .24
        )
        diamond(
            innerFrame,
            x + (sx < 0 and -8 or 1),
            y + (sy < 0 and -8 or 1),
            6,
            P.line,
            .18
        )
    end

    local header = make("Frame", window, {
        Size = UDim2.fromOffset(746, 62),
        BackgroundTransparency = 1,
        Active = true,
    })

    local titleGlow = text(header, title, 27, 17, 150, 39, 32, P.accent2, Enum.Font.Antique)
    titleGlow.TextTransparency = .78

    local titleLabel = text(header, title, 25, 15, 150, 39, 32, P.text, Enum.Font.Antique)
    local subtitleLabel = text(window, subtitleText, 24, 57, 150, 24, 10, P.text)

    local titleRail = line(window, 24, 86, 141, 1, 0, P.accent2, .55)
    line(window, 24, 89, 87, 1, 0, P.accent, .78)
    diamond(window, 156, 82, 7, P.glow, .42)

    local breadcrumb = text(
        header,
        string.upper(currentPage) .. "  /  " .. string.upper(productName),
        193,
        20,
        490,
        25,
        13,
        P.bright
    )

    -- Header heraldry around the breadcrumb.
    line(header, 188, 12, 1, 39, 0, P.line, .36)
    diamond(header, 184, 27, 8, P.accent, .12)
    line(header, 202, 49, 356, 1, 0, P.line, .62)
    diamond(header, 563, 46, 6, P.line, .28)
    line(header, 574, 49, 91, 1, 0, P.line, .74)

    local function button(parent, buttonTitle, x, y, width, callback)
        local object = make("TextButton", parent, {
            Text = tostring(buttonTitle or ""),
            TextTransparency = 1,
            Position = UDim2.fromOffset(x, y),
            Size = UDim2.fromOffset(width, 30),
            BackgroundColor3 = Color3.fromRGB(12, 16, 31),
            BackgroundTransparency = .06,
            BorderSizePixel = 0,
            Font = Enum.Font.Code,
            TextSize = 12,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
            TextStrokeTransparency = .25,
            AutoButtonColor = false,
            ZIndex = 8,
        })

        local outline = make("UIStroke", object, {
            Color = P.accent,
            Thickness = 1,
            Transparency = .46,
        })

        make("UICorner", object, {
            CornerRadius = UDim.new(0, 7),
        })

        -- Render button copy in its own label. This prevents gradients, decorative
        -- children, or Roblox TextButton draw-order quirks from darkening the text.
        local copyLabel = make("TextLabel", object, {
            Name = "ButtonText",
            Position = UDim2.fromOffset(8, 0),
            Size = UDim2.new(1, -16, 1, 0),
            BackgroundTransparency = 1,
            Text = object.Text,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
            TextStrokeTransparency = .22,
            Font = Enum.Font.Code,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Center,
            ZIndex = 20,
        })

        local topHighlight = make("Frame", object, {
            Position = UDim2.fromOffset(6, 2),
            Size = UDim2.new(1, -12, 0, 1),
            BackgroundColor3 = P.glow,
            BackgroundTransparency = .78,
            BorderSizePixel = 0,
            ZIndex = 9,
        })

        bind(object:GetPropertyChangedSignal("Text"), function()
            copyLabel.Text = object.Text
        end)

        bind(object:GetPropertyChangedSignal("TextColor3"), function()
            local color = object.TextColor3
            local luminance = color.R * .2126 + color.G * .7152 + color.B * .0722
            copyLabel.TextColor3 = luminance < .58
                and Color3.fromRGB(255, 255, 255)
                or color
        end)

        bind(object.MouseEnter, function()
            TweenService:Create(object, TweenInfo.new(.14), {
                BackgroundTransparency = 0,
            }):Play()
            outline.Color = P.accent2
            outline.Transparency = .08
            copyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        end)

        bind(object.MouseLeave, function()
            TweenService:Create(object, TweenInfo.new(.14), {
                BackgroundTransparency = .06,
            }):Play()
            outline.Color = P.accent
            outline.Transparency = .46
            copyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        end)

        if callback then
            bind(object.Activated, callback)
        end

        return object
    end

    button(window, "—", 848, 18, 30, function()
        gui.Enabled = false
    end)

    local Window = {
        Gui = gui,
        Frame = window,
        Scale = scale,
        Palette = P,
        Tabs = tabs,
        Pages = pages,
        Nav = nav,
    }

    function Window:Destroy()
        if not alive then
            return
        end

        alive = false
        safeCall(cfg.OnUnload)

        if self._activeColorPicker then
            pcall(function()
                self._activeColorPicker:Destroy(true)
            end)
            self._activeColorPicker = nil
        end

        for _, connection in ipairs(connections) do
            pcall(function()
                connection:Disconnect()
            end)
        end
        table.clear(connections)

        if gui then
            gui:Destroy()
        end
    end

    button(window, "×", 888, 18, 30, function()
        Window:Destroy()
    end)

    -- Original drag behavior.
    local drag
    local dragStart
    local dragOrigin

    bind(header.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            drag = input
            dragStart = input.Position
            dragOrigin = window.Position
        end
    end)

    bind(Input.InputChanged, function(input)
        if drag and (
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input == drag
        ) then
            local delta = input.Position - dragStart
            window.Position = UDim2.new(
                dragOrigin.X.Scale,
                dragOrigin.X.Offset + delta.X,
                dragOrigin.Y.Scale,
                dragOrigin.Y.Offset + delta.Y
            )
        end
    end)

    bind(Input.InputEnded, function(input)
        if input == drag then
            drag = nil
        end
    end)

    function Window:SetVisible(value)
        gui.Enabled = value == true
    end

    function Window:ToggleVisible()
        gui.Enabled = not gui.Enabled
    end

    function Window:Select(name)
        if not pages[name] then
            return
        end

        for key, page in pairs(pages) do
            local selected = key == name
            page.Visible = selected

            if nav[key] then
                nav[key].TextColor3 = Color3.fromRGB(255, 255, 255)
                nav[key].BackgroundTransparency = selected and .04 or .68

                local visibleText = nav[key]:FindFirstChild("ButtonText")
                if visibleText then
                    visibleText.TextColor3 = Color3.fromRGB(255, 255, 255)
                    visibleText.TextTransparency = 0
                end

                local strokeObject = nav[key]:FindFirstChildOfClass("UIStroke")
                if strokeObject then
                    strokeObject.Color = selected and P.accent2 or P.line
                    strokeObject.Transparency = selected and .08 or .58
                    strokeObject.Thickness = selected and 1.5 or 1
                end
            end
        end

        activeTab = name
        breadcrumb.Text = string.upper(name) .. "  /  " .. string.upper(productName)
    end

    local sidebarGlass = make("Frame", window, {
        Name = "SidebarGlass",
        Position = UDim2.fromOffset(18, 103),
        Size = UDim2.fromOffset(178, 354),
        BackgroundColor3 = P.card,
        BackgroundTransparency = .78,
        BorderSizePixel = 0,
    })
    sidebarGlass.ZIndex = 0

    make("UIStroke", sidebarGlass, {
        Color = P.accent2,
        Thickness = 1,
        Transparency = .76,
    })

    make("UIGradient", sidebarGlass, {
        Rotation = 90,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(16, 27, 47)),
            ColorSequenceKeypoint.new(.5, Color3.fromRGB(8, 13, 27)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(21, 10, 34)),
        }),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, .38),
            NumberSequenceKeypoint.new(.5, .68),
            NumberSequenceKeypoint.new(1, .45),
        }),
    })

    -- No pause button. Only unload and show/hide remain.
    text(
        window,
        "F9  unload\nRShift  hide",
        26,
        514,
        160,
        52,
        11,
        P.muted
    )

    local sidebarStatus = text(
        window,
        "◇  STABLE",
        26,
        476,
        160,
        24,
        11,
        P.bright
    )

    local footerLabel = text(window, "", 225, 552, 683, 42, 11, P.muted)

    local statusText = "STABLE"
    local footerPrimary = versionText
    local footerSecondary = ""

    local function updateFooter()
        sidebarStatus.Text = "◇  " .. tostring(statusText)
        footerLabel.Text = string.format(
            "STATUS  %s    %s\n%s",
            tostring(statusText):sub(1, 24),
            tostring(footerPrimary):sub(1, 42),
            tostring(footerSecondary):sub(1, 90)
        )
    end

    function Window:SetStatus(value)
        statusText = string.upper(tostring(value or "READY"))
        updateFooter()
    end

    function Window:SetFooter(primary, secondary)
        if type(primary) == "table" then
            local data = primary
            footerPrimary = tostring(data.Primary or data.Left or footerPrimary)
            footerSecondary = tostring(data.Secondary or data.Right or footerSecondary)

            if data.Status ~= nil then
                statusText = string.upper(tostring(data.Status))
            end
        else
            if primary ~= nil then
                footerPrimary = tostring(primary)
            end
            if secondary ~= nil then
                footerSecondary = tostring(secondary)
            end
        end

        updateFooter()
    end

    local notifications = make("Frame", window, {
        Name = "Notifications",
        Position = UDim2.fromOffset(578, 72),
        Size = UDim2.fromOffset(244, 390),
        BackgroundTransparency = 1,
        ZIndex = 20,
    })

    make("UIListLayout", notifications, {
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Padding = UDim.new(0, 7),
    })

    function Window:Notify(data)
        if type(data) ~= "table" then
            data = {
                Title = "NOTICE",
                Content = tostring(data or ""),
            }
        end

        local card = make("Frame", notifications, {
            Size = UDim2.new(1, 0, 0, 64),
            BackgroundColor3 = P.card,
            BackgroundTransparency = .05,
            BorderSizePixel = 0,
            ZIndex = 20,
        })

        make("UIStroke", card, {
            Color = P.line,
            Thickness = 1,
        })

        local titleLabel = text(
            card,
            string.upper(tostring(data.Title or "NOTICE")),
            10,
            6,
            224,
            18,
            12,
            P.bright,
            Enum.Font.Antique
        )
        titleLabel.ZIndex = 21

        local body = text(
            card,
            tostring(data.Content or ""),
            10,
            25,
            224,
            32,
            10,
            P.muted
        )
        body.ZIndex = 21
        body.TextYAlignment = Enum.TextYAlignment.Top

        task.delay(tonumber(data.Duration) or 3, function()
            if card and card.Parent then
                card:Destroy()
            end
        end)
    end

    function Window:CreateTab(tabCfg)
        tabCfg = tabCfg or {}

        local name = tostring(tabCfg.Title or ("Tab " .. tostring(#tabs + 1)))
        local indexValue = tabCfg.Index

        if indexValue == nil then
            indexValue = #tabs + 1
        end

        local indexNumber = tonumber(indexValue)
        local indexText = indexNumber and string.format("%02d", indexNumber)
            or tostring(indexValue)

        -- Linoria-style tab body: one selected tab, two independent groupbox columns.
        local page = make("Frame", window, {
            Position = UDim2.fromOffset(225, 82),
            Size = UDim2.fromOffset(683, 448),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Visible = #tabs == 0,
        })

        local columnGap = 11
        local columnWidth = math.floor((683 - columnGap) / 2)

        local function createColumn(x)
            local column = make("ScrollingFrame", page, {
                Position = UDim2.fromOffset(x, 0),
                Size = UDim2.fromOffset(columnWidth, 448),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ScrollBarThickness = 2,
                ScrollBarImageColor3 = P.accent,
                CanvasSize = UDim2.new(),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ScrollingDirection = Enum.ScrollingDirection.Y,
            })

            make("UIPadding", column, {
                PaddingLeft = UDim.new(0, 1),
                PaddingRight = UDim.new(0, 5),
                PaddingBottom = UDim.new(0, 8),
            })

            make("UIListLayout", column, {
                Padding = UDim.new(0, 9),
                SortOrder = Enum.SortOrder.LayoutOrder,
            })

            return column
        end

        local leftColumn = createColumn(0)
        local rightColumn = createColumn(columnWidth + columnGap)

        local splitLine = make("Frame", page, {
            Position = UDim2.fromOffset(columnWidth + math.floor(columnGap / 2), 4),
            Size = UDim2.fromOffset(1, 438),
            BackgroundColor3 = P.line,
            BackgroundTransparency = .88,
            BorderSizePixel = 0,
        })
        splitLine.ZIndex = 2

        pages[name] = page

        local navButton = button(
            window,
            string.format("%s   %s", indexText, name),
            27,
            116 + (#tabs * 52),
            156,
            function()
                Window:Select(name)
            end
        )

        navButton.Size = UDim2.fromOffset(156, 38)
        navButton.BackgroundTransparency = #tabs == 0 and .02 or .62
        navButton.TextColor3 = Color3.fromRGB(255, 255, 255)

        local navCopy = navButton:FindFirstChild("ButtonText")
        if navCopy then
            navCopy.TextColor3 = Color3.fromRGB(255, 255, 255)
            navCopy.TextTransparency = 0
        end

        -- Sidebar tab ornament: rail, rune node, and trailing stitch.
        local navRail = line(navButton, 4, 6, 1, 18, 0, P.accent, #tabs == 0 and .05 or .62)
        local navNode = diamond(navButton, 10, 11, 7, P.line, .2)
        local navTail = line(navButton, 118, 15, 8, 1, 0, P.line, .55)
        local navTailNode = diamond(navButton, 126, 12, 5, P.line, .45)

        navRail.ZIndex = 9
        navNode.ZIndex = 9
        navTail.ZIndex = 9
        navTailNode.ZIndex = 9

        nav[name] = navButton

        local Tab = {
            Window = Window,
            Page = page,
            LeftColumn = leftColumn,
            RightColumn = rightColumn,
            Name = name,
            Sections = {},
            _leftSections = 0,
            _rightSections = 0,
        }

        function Tab:Select()
            Window:Select(name)
        end

        function Tab:CreateSection(secCfg)
            secCfg = secCfg or {}

            -- Section titles are optional. Empty/false titles create clean unlabeled groupboxes.
            local sectionTitle = ""
            if secCfg.Title ~= nil and secCfg.Title ~= false then
                sectionTitle = tostring(secCfg.Title)
            end
            if sectionTitle ~= "" and secCfg.Level ~= nil then
                sectionTitle = sectionTitle .. " · Level " .. tostring(secCfg.Level)
            end

            local requestedSide = secCfg.Position or secCfg.Side or secCfg.Column
            local sideText = string.lower(tostring(requestedSide or ""))
            local sectionParent
            local sideName

            if sideText == "right" or sideText == "2" then
                sectionParent = rightColumn
                sideName = "Right"
                Tab._rightSections += 1
            elseif sideText == "left" or sideText == "1" then
                sectionParent = leftColumn
                sideName = "Left"
                Tab._leftSections += 1
            elseif Tab._leftSections <= Tab._rightSections then
                sectionParent = leftColumn
                sideName = "Left"
                Tab._leftSections += 1
            else
                sectionParent = rightColumn
                sideName = "Right"
                Tab._rightSections += 1
            end

            local card = make("Frame", sectionParent, {
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = P.card,
                BackgroundTransparency = .34,
                BorderSizePixel = 0,
            })

            make("UIStroke", card, {
                Color = P.line,
                Thickness = 1,
                Transparency = .18,
            })

            make("UICorner", card, {
                CornerRadius = UDim.new(0, 3),
            })

            make("UIGradient", card, {
                Rotation = 112,
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(16, 22, 42)),
                    ColorSequenceKeypoint.new(.52, Color3.fromRGB(10, 14, 28)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(21, 12, 37)),
                }),
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, .05),
                    NumberSequenceKeypoint.new(.58, .24),
                    NumberSequenceKeypoint.new(1, .08),
                }),
            })

            -- Compact Linoria-like groupbox header.
            line(card, 10, 29, 72, 1, 0, P.accent2, .62)
            diamond(card, 5, 26, 6, P.accent, .34)

            make("UIPadding", card, {
                PaddingTop = UDim.new(0, 10),
                PaddingBottom = UDim.new(0, 10),
                PaddingLeft = UDim.new(0, 12),
                PaddingRight = UDim.new(0, 12),
            })

            make("UIListLayout", card, {
                Padding = UDim.new(0, 5),
                SortOrder = Enum.SortOrder.LayoutOrder,
            })

            if sectionTitle ~= "" then
                local heading = text(
                    card,
                    string.upper(sectionTitle),
                    0,
                    0,
                    588,
                    22,
                    12,
                    P.bright,
                    Enum.Font.Code
                )
                heading.Size = UDim2.new(1, 0, 0, 22)
            end

            if secCfg.Description and tostring(secCfg.Description) ~= "" then
                local hint = text(
                    card,
                    tostring(secCfg.Description),
                    0,
                    0,
                    588,
                    32,
                    11,
                    P.muted
                )
                hint.Size = UDim2.new(1, 0, 0, 32)
            end

            local Section = {
                Tab = Tab,
                Card = card,
                Side = sideName,
            }

            function Section:CreateToggle(control)
                control = control or {}

                local state = control.Default == true

                local row = make("Frame", card, {
                    Size = UDim2.new(1, 0, 0, 38),
                    BackgroundTransparency = 1,
                })

                local label = text(
                    row,
                    control.Title or "Toggle",
                    0,
                    0,
                    205,
                    38,
                    12,
                    Color3.fromRGB(255, 255, 255)
                )

                local switch = make("TextButton", row, {
                    AnchorPoint = Vector2.new(1, .5),
                    Position = UDim2.new(1, 0, .5, 0),
                    Size = UDim2.fromOffset(82, 28),
                    BackgroundColor3 = P.Base or P.card,
                    BackgroundTransparency = .08,
                    BorderSizePixel = 0,
                    Text = "",
                    AutoButtonColor = false,
                })

                make("UICorner", switch, {
                    CornerRadius = UDim.new(1, 0),
                })

                local switchStroke = make("UIStroke", switch, {
                    Color = P.line,
                    Thickness = 1,
                    Transparency = .28,
                })

                local fill = make("Frame", switch, {
                    Position = UDim2.fromOffset(3, 3),
                    Size = UDim2.new(0, 40, 1, -6),
                    BackgroundColor3 = P.accent,
                    BackgroundTransparency = .16,
                    BorderSizePixel = 0,
                })

                make("UICorner", fill, {
                    CornerRadius = UDim.new(1, 0),
                })

                local knob = make("Frame", switch, {
                    Size = UDim2.fromOffset(20, 20),
                    Position = UDim2.fromOffset(5, 4),
                    BackgroundColor3 = P.text,
                    BorderSizePixel = 0,
                })

                make("UICorner", knob, {
                    CornerRadius = UDim.new(1, 0),
                })

                local knobStroke = make("UIStroke", knob, {
                    Color = P.accent2,
                    Thickness = 1,
                    Transparency = .18,
                })

                local stateLabel = text(
                    switch,
                    "",
                    28,
                    0,
                    49,
                    28,
                    10,
                    Color3.fromRGB(255, 255, 255)
                )
                stateLabel.TextXAlignment = Enum.TextXAlignment.Center

                local Object = {}

                local function unlocked()
                    return not control.Requirement or control.Requirement() == true
                end

                local function render()
                    local available = unlocked()
                    stateLabel.Text = not available and "LOCK" or state and "ON" or "OFF"
                    stateLabel.TextColor3 = P.text

                    local targetX = state and 57 or 5
                    local targetWidth = state and 76 or 40

                    TweenService:Create(knob, TweenInfo.new(.15, Enum.EasingStyle.Quad), {
                        Position = UDim2.fromOffset(targetX, 4),
                    }):Play()

                    TweenService:Create(fill, TweenInfo.new(.15, Enum.EasingStyle.Quad), {
                        Size = UDim2.new(0, targetWidth, 1, -6),
                        BackgroundColor3 = state and P.accent2 or P.accent,
                        BackgroundTransparency = state and .08 or .42,
                    }):Play()

                    switchStroke.Color = state and P.accent2 or P.line
                    switchStroke.Transparency = available and .2 or .62
                    knob.BackgroundTransparency = available and 0 or .42
                end

                local function set(value, fire)
                    if not unlocked() then
                        safeCall(control.OnLocked)
                        render()
                        return
                    end

                    state = value == true
                    Object.Value.Current = state
                    render()

                    if fire then
                        safeCall(control.Callback, state)
                    end
                end

                bind(switch.Activated, function()
                    set(not state, true)
                end)

                Object.Value = proxy(state, function(value)
                    set(value, true)
                end)

                Object.Name = proxy(control.Title or "Toggle", function(value)
                    value = tostring(value)
                    Object.Name.Current = value
                    label.Text = value
                end)

                table.insert(refresh, render)
                render()

                return Object
            end

            function Section:CreateDropdown(control)
                control = control or {}

                local options = control.Options or {}
                local selected = control.Selected or {}
                local multi = control.Multi == true
                local cursor = 0

                if type(selected) ~= "table" then
                    selected = {selected}
                end

                if not multi and selected[1] == nil and options[1] ~= nil then
                    selected = {options[1]}
                end

                local cycleButton = button(card, "", 0, 0, 588, nil)
                cycleButton.Size = UDim2.new(1, 0, 0, 31)

                local Object = {}

                local function emit()
                    Object.Value.Current = selected
                    safeCall(control.Callback, selected)
                end

                bind(cycleButton.Activated, function()
                    if #options == 0 then
                        return
                    end

                    cursor = (cursor % #options) + 1
                    local option = options[cursor]

                    if multi then
                        local found = table.find(selected, option)
                        if found then
                            table.remove(selected, found)
                        else
                            table.insert(selected, option)
                        end
                    else
                        selected = {option}
                    end

                    emit()
                end)

                Object.Value = proxy(selected, function(value)
                    if type(value) ~= "table" then
                        value = {value}
                    end

                    if multi then
                        selected = value
                    else
                        selected = {value[1]}
                    end

                    emit()
                end)

                Object.Options = proxy(options, function(value)
                    options = type(value) == "table" and value or {}
                    Object.Options.Current = options
                    cursor = 0
                end)

                Object.Name = proxy(control.Title or "Dropdown", function(value)
                    Object.Name.Current = tostring(value)
                end)

                table.insert(refresh, function()
                    local display

                    if #selected == 0 then
                        display = "—"
                    elseif multi then
                        display = table.concat(selected, ", ")
                    else
                        display = tostring(selected[1])
                    end

                    cycleButton.Text = tostring(Object.Name.Current)
                        .. ": "
                        .. display
                        .. "   ›"

                    Object.Value.Current = selected
                end)

                return Object
            end

            function Section:CreateInput(control)
                control = control or {}

                local current = control.Default
                if current == nil then
                    current = ""
                end

                local row = make("Frame", card, {
                    Size = UDim2.new(1, 0, 0, 32),
                    BackgroundTransparency = 1,
                })

                local label = text(
                    row,
                    control.Title or "Input",
                    0,
                    0,
                    150,
                    30,
                    12
                )

                local box = make("TextBox", row, {
                    Text = tostring(current),
                    PlaceholderText = tostring(control.Placeholder or ""),
                    Size = UDim2.new(0, 142, 0, 28),
                    Position = UDim2.new(1, -142, 0, 2),
                    BackgroundColor3 = P.bg,
                    BorderSizePixel = 0,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
                    TextStrokeTransparency = .35,
                    PlaceholderColor3 = Color3.fromRGB(205, 214, 236),
                    Font = Enum.Font.Code,
                    TextSize = 12,
                    ClearTextOnFocus = false,
                })

                local Object = {}

                local function normalize(value)
                    if control.Numeric then
                        value = tonumber(value)
                        if value == nil then
                            return nil
                        end

                        if control.Min ~= nil then
                            value = math.max(tonumber(control.Min) or value, value)
                        end

                        if control.Max ~= nil then
                            value = math.min(tonumber(control.Max) or value, value)
                        end

                        if tonumber(control.Increment) and tonumber(control.Increment) > 0 then
                            local step = tonumber(control.Increment)
                            value = math.floor((value / step) + .5) * step
                        end
                    end

                    return value
                end

                local function set(value, fire)
                    local parsed = normalize(value)

                    if parsed == nil and control.Numeric then
                        box.Text = tostring(current)
                        return
                    end

                    current = parsed
                    Object.Value.Current = current
                    box.Text = tostring(current)

                    if fire then
                        safeCall(control.Callback, current)
                    end
                end

                bind(box.FocusLost, function()
                    set(box.Text, true)
                end)

                Object.Value = proxy(current, function(value)
                    set(value, true)
                end)

                Object.Name = proxy(control.Title or "Input", function(value)
                    value = tostring(value)
                    Object.Name.Current = value
                    label.Text = value
                end)

                return Object
            end

            function Section:CreateColorInput(control)
                control = control or {}

                local current = hexToColor(control.Default) or control.Default
                if typeof(current) ~= "Color3" then
                    current = P.accent
                end

                local row = make("Frame", card, {
                    Size = UDim2.new(1, 0, 0, 40),
                    BackgroundTransparency = 1,
                })

                local label = text(
                    row,
                    control.Title or "Color",
                    0,
                    0,
                    150,
                    40,
                    12,
                    Color3.fromRGB(255, 255, 255)
                )

                local selector = make("TextButton", row, {
                    AnchorPoint = Vector2.new(1, .5),
                    Position = UDim2.new(1, 0, .5, 0),
                    Size = UDim2.fromOffset(146, 30),
                    BackgroundColor3 = Color3.fromRGB(8, 11, 23),
                    BackgroundTransparency = .02,
                    BorderSizePixel = 0,
                    Text = "",
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
                    TextStrokeTransparency = .28,
                    Font = Enum.Font.Code,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    AutoButtonColor = false,
                    ZIndex = 12,
                })

                make("UICorner", selector, {
                    CornerRadius = UDim.new(0, 7),
                })

                local selectorStroke = make("UIStroke", selector, {
                    Color = P.line,
                    Thickness = 1,
                    Transparency = .2,
                })

                local hexLabel = text(
                    selector,
                    colorToHex(current),
                    12,
                    0,
                    92,
                    30,
                    12,
                    Color3.fromRGB(255, 255, 255)
                )
                hexLabel.ZIndex = 14

                local swatch = make("Frame", selector, {
                    AnchorPoint = Vector2.new(1, .5),
                    Position = UDim2.new(1, -5, .5, 0),
                    Size = UDim2.fromOffset(32, 20),
                    BackgroundColor3 = current,
                    BorderSizePixel = 0,
                    ZIndex = 14,
                })

                make("UICorner", swatch, {
                    CornerRadius = UDim.new(0, 4),
                })

                make("UIStroke", swatch, {
                    Color = Color3.fromRGB(255, 255, 255),
                    Thickness = 1,
                    Transparency = .42,
                })

                local Object = {}

                local function render()
                    hexLabel.Text = colorToHex(current)
                    swatch.BackgroundColor3 = current
                    Object.Value.Current = current
                end

                local function set(valueToSet, fire)
                    local parsed = hexToColor(valueToSet)
                    if not parsed then
                        render()
                        return false
                    end

                    current = parsed
                    render()

                    if fire then
                        safeCall(control.Callback, current, colorToHex(current))
                    end

                    return true
                end

                local function openPicker()
                    local Picker = getColorPickerModule()
                    if not Picker then
                        Window:Notify({
                            Title = "Color picker",
                            Content = "The popup color picker could not be loaded.",
                            Duration = 3,
                        })
                        return
                    end

                    if Window._activeColorPicker then
                        pcall(function()
                            Window._activeColorPicker:Destroy(true)
                        end)
                        Window._activeColorPicker = nil
                    end

                    local picker
                    picker = Picker.Create({
                        Parent = window,
                        Title = Object.Name:Get(),
                        Color = current,
                        Accent = P.accent,
                        Accent2 = P.accent2,
                        Line = P.line,
                        OnSelect = function(color)
                            set(color, true)
                            if Window._activeColorPicker == picker then
                                Window._activeColorPicker = nil
                            end
                        end,
                        OnCancel = function()
                            if Window._activeColorPicker == picker then
                                Window._activeColorPicker = nil
                            end
                        end,
                    })

                    Window._activeColorPicker = picker
                end

                bind(selector.MouseEnter, function()
                    selectorStroke.Color = P.accent2
                    selectorStroke.Transparency = .02
                end)

                bind(selector.MouseLeave, function()
                    selectorStroke.Color = P.line
                    selectorStroke.Transparency = .2
                end)

                bind(selector.Activated, openPicker)

                Object.Value = proxy(current, function(valueToSet)
                    set(valueToSet, true)
                end)

                Object.Name = proxy(control.Title or "Color", function(valueToSet)
                    valueToSet = tostring(valueToSet)
                    Object.Name.Current = valueToSet
                    label.Text = valueToSet
                end)

                function Object:SetHex(valueToSet)
                    return set(valueToSet, true)
                end

                function Object:GetHex()
                    return colorToHex(current)
                end

                function Object:Open()
                    openPicker()
                end

                function Object:Close()
                    if Window._activeColorPicker then
                        Window._activeColorPicker:Destroy(true)
                        Window._activeColorPicker = nil
                    end
                end

                render()
                return Object
            end

            function Section:CreateSlider(control)
                control = control or {}

                local range = control.Range or {0, 100}
                local minimum = tonumber(range[1]) or 0
                local maximum = tonumber(range[2]) or 100
                local step = tonumber(control.Increment) or 1
                local suffix = tostring(control.Suffix or "")
                local value = math.clamp(tonumber(control.Default) or minimum, minimum, maximum)

                local holder = make("Frame", card, {
                    Size = UDim2.new(1, 0, 0, 48),
                    BackgroundTransparency = 1,
                })

                local label = text(
                    holder,
                    control.Title or "Slider",
                    0,
                    0,
                    205,
                    21,
                    12,
                    Color3.fromRGB(255, 255, 255)
                )

                local valueLabel = text(
                    holder,
                    tostring(value) .. suffix,
                    208,
                    0,
                    92,
                    21,
                    11,
                    Color3.fromRGB(255, 255, 255)
                )
                valueLabel.TextXAlignment = Enum.TextXAlignment.Right

                local track = make("Frame", holder, {
                    Position = UDim2.fromOffset(0, 31),
                    Size = UDim2.new(1, 0, 0, 5),
                    BackgroundColor3 = P.line,
                    BackgroundTransparency = .42,
                    BorderSizePixel = 0,
                })

                make("UICorner", track, {
                    CornerRadius = UDim.new(1, 0),
                })

                local fill = make("Frame", track, {
                    Size = UDim2.fromScale(0, 1),
                    BackgroundColor3 = P.accent2,
                    BorderSizePixel = 0,
                })

                make("UICorner", fill, {
                    CornerRadius = UDim.new(1, 0),
                })

                local knob = make("Frame", track, {
                    AnchorPoint = Vector2.new(.5, .5),
                    Position = UDim2.fromScale(0, .5),
                    Size = UDim2.fromOffset(13, 13),
                    BackgroundColor3 = P.text,
                    BorderSizePixel = 0,
                })

                make("UICorner", knob, {
                    CornerRadius = UDim.new(1, 0),
                })

                make("UIStroke", knob, {
                    Color = P.accent2,
                    Thickness = 2,
                    Transparency = .08,
                })

                local Object = {}
                local draggingSlider = false

                local function normalize(v)
                    v = math.clamp(v, minimum, maximum)
                    if step > 0 then
                        v = math.floor(((v - minimum) / step) + .5) * step + minimum
                    end
                    return math.clamp(v, minimum, maximum)
                end

                local function render(fire)
                    local alpha = maximum == minimum and 0 or (value - minimum) / (maximum - minimum)
                    fill.Size = UDim2.fromScale(alpha, 1)
                    knob.Position = UDim2.fromScale(alpha, .5)
                    valueLabel.Text = tostring(value) .. suffix
                    Object.Value.Current = value

                    if fire then
                        safeCall(control.Callback, value)
                    end
                end

                local function setFromX(x, fire)
                    local width = track.AbsoluteSize.X
                    if width <= 0 then return end
                    local alpha = math.clamp((x - track.AbsolutePosition.X) / width, 0, 1)
                    value = normalize(minimum + (maximum - minimum) * alpha)
                    render(fire)
                end

                bind(track.InputBegan, function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1
                        or input.UserInputType == Enum.UserInputType.Touch then
                        draggingSlider = true
                        setFromX(input.Position.X, true)
                    end
                end)

                bind(Input.InputChanged, function(input)
                    if draggingSlider and (
                        input.UserInputType == Enum.UserInputType.MouseMovement
                        or input.UserInputType == Enum.UserInputType.Touch
                    ) then
                        setFromX(input.Position.X, true)
                    end
                end)

                bind(Input.InputEnded, function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1
                        or input.UserInputType == Enum.UserInputType.Touch then
                        draggingSlider = false
                    end
                end)

                Object.Value = proxy(value, function(newValue)
                    value = normalize(tonumber(newValue) or value)
                    render(true)
                end)

                Object.Name = proxy(control.Title or "Slider", function(newValue)
                    newValue = tostring(newValue)
                    Object.Name.Current = newValue
                    label.Text = newValue
                end)

                render(false)
                return Object
            end

            function Section:CreateButton(control)
                control = control or {}

                local action = button(
                    card,
                    control.Title or "Button",
                    0,
                    0,
                    588,
                    function()
                        safeCall(control.Callback)
                    end
                )
                action.Size = UDim2.new(1, 0, 0, 30)

                local Object = {}

                Object.Name = proxy(control.Title or "Button", function(value)
                    value = tostring(value)
                    Object.Name.Current = value
                    action.Text = value
                end)

                return Object
            end

            function Section:CreateKeybind(control)
                control = control or {}

                local current = control.Default or Enum.KeyCode.K

                local row = make("Frame", card, {
                    Size = UDim2.new(1, 0, 0, 31),
                    BackgroundTransparency = 1,
                })

                local label = text(
                    row,
                    control.Title or "Keybind",
                    0,
                    0,
                    205,
                    30,
                    12
                )

                local keyButton = button(
                    row,
                    current.Name,
                    494,
                    1,
                    80,
                    nil
                )
                keyButton.AnchorPoint = Vector2.new(1, 0)
                keyButton.Position = UDim2.new(1, 0, 0, 1)

                local Object = {}

                bind(keyButton.Activated, function()
                    capturingKey = true
                    keyButton.Text = "PRESS..."
                end)

                Object.Value = proxy(current, function(value)
                    if typeof(value) == "EnumItem" then
                        current = value
                        Object.Value.Current = current
                        keyButton.Text = current.Name
                        safeCall(control.Callback, current)
                    end
                end)

                Object.Name = proxy(control.Title or "Keybind", function(value)
                    value = tostring(value)
                    Object.Name.Current = value
                    label.Text = value
                end)

                Object._capture = function(input)
                    if not capturingKey then
                        return false
                    end

                    if input.KeyCode == Enum.KeyCode.Unknown then
                        return true
                    end

                    capturingKey = false
                    current = input.KeyCode
                    Object.Value.Current = current
                    keyButton.Text = current.Name
                    safeCall(control.Callback, current)

                    return true
                end

                table.insert(Window._keybinds, Object)
                return Object
            end

            function Section:CreateLabel(content)
                local label = text(
                    card,
                    tostring(content or ""),
                    0,
                    0,
                    588,
                    28,
                    11,
                    P.muted
                )
                label.Size = UDim2.new(1, 0, 0, 28)

                local Object = {}

                Object.Value = proxy(content or "", function(value)
                    value = tostring(value)
                    Object.Value.Current = value
                    label.Text = value
                end)

                return Object
            end

            function Section:CreateParagraph(control)
                control = control or {}

                local holder = make("Frame", card, {
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                })

                make("UIListLayout", holder, {
                    Padding = UDim.new(0, 3),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                })

                local titleLabel = text(
                    holder,
                    tostring(control.Title or ""),
                    0,
                    0,
                    588,
                    22,
                    12,
                    P.bright,
                    Enum.Font.Antique
                )
                titleLabel.Size = UDim2.new(1, 0, 0, 22)
                titleLabel.Visible = tostring(control.Title or "") ~= ""

                local contentLabel = text(
                    holder,
                    tostring(control.Content or ""),
                    0,
                    0,
                    588,
                    32,
                    11,
                    P.muted
                )
                contentLabel.Size = UDim2.new(1, 0, 0, 32)
                contentLabel.AutomaticSize = Enum.AutomaticSize.Y
                contentLabel.TextYAlignment = Enum.TextYAlignment.Top

                local Object = {}

                Object.Title = proxy(control.Title or "", function(value)
                    value = tostring(value)
                    Object.Title.Current = value
                    titleLabel.Text = value
                    titleLabel.Visible = value ~= ""
                end)

                Object.Content = proxy(control.Content or "", function(value)
                    value = tostring(value)
                    Object.Content.Current = value
                    contentLabel.Text = value
                end)

                return Object
            end

            function Section:CreateSeparator(control)
                control = control or {}

                local holder = make("Frame", card, {
                    Size = UDim2.new(1, 0, 0, 22),
                    BackgroundTransparency = 1,
                })

                local separator = make("Frame", holder, {
                    Position = UDim2.new(0, 0, .5, 0),
                    Size = UDim2.new(1, 0, 0, 1),
                    BackgroundColor3 = P.line,
                    BackgroundTransparency = .25,
                    BorderSizePixel = 0,
                })

                local titleValue = tostring(control.Title or "")
                if titleValue ~= "" then
                    local titleText = text(
                        holder,
                        " " .. string.upper(titleValue) .. " ",
                        8,
                        0,
                        180,
                        22,
                        10,
                        P.muted
                    )
                    titleText.BackgroundColor3 = P.card
                    titleText.BackgroundTransparency = .15
                    titleText.AutomaticSize = Enum.AutomaticSize.X
                    titleText.ZIndex = separator.ZIndex + 1
                end
            end

            function Section:CreateProgress(control)
                control = control or {}

                local value = math.clamp(tonumber(control.Default) or 0, 0, 1)

                local holder = make("Frame", card, {
                    Size = UDim2.new(1, 0, 0, 34),
                    BackgroundTransparency = 1,
                })

                local label = text(
                    holder,
                    control.Title or "Progress",
                    0,
                    0,
                    588,
                    21,
                    11,
                    P.muted
                )

                local track = make("Frame", holder, {
                    Position = UDim2.new(0, 0, 1, -7),
                    Size = UDim2.new(1, 0, 0, 4),
                    BackgroundColor3 = P.line,
                    BorderSizePixel = 0,
                })

                local fill = make("Frame", track, {
                    Size = UDim2.fromScale(value, 1),
                    BackgroundColor3 = P.accent,
                    BorderSizePixel = 0,
                })

                local Object = {}

                local function set(newValue, fire)
                    value = math.clamp(tonumber(newValue) or value, 0, 1)
                    Object.Value.Current = value
                    fill.Size = UDim2.fromScale(value, 1)

                    if fire then
                        safeCall(control.Callback, value)
                    end
                end

                Object.Value = proxy(value, function(newValue)
                    set(newValue, true)
                end)

                Object.Name = proxy(control.Title or "Progress", function(newValue)
                    newValue = tostring(newValue)
                    Object.Name.Current = newValue
                    label.Text = newValue
                end)

                return Object
            end

            table.insert(Tab.Sections, Section)
            return Section
        end

        function Tab:CreateLeftSection(secCfg)
            secCfg = copy(secCfg or {})
            secCfg.Position = "Left"
            return self:CreateSection(secCfg)
        end

        function Tab:CreateRightSection(secCfg)
            secCfg = copy(secCfg or {})
            secCfg.Position = "Right"
            return self:CreateSection(secCfg)
        end

        table.insert(tabs, Tab)

        if #tabs == 1 then
            Window:Select(name)
        end

        return Tab
    end

    local function sameColor(a, b)
        return math.abs(a.R - b.R) < .0001
            and math.abs(a.G - b.G) < .0001
            and math.abs(a.B - b.B) < .0001
    end

    local function recolorSequence(sequence, oldColor, newColor)
        local points = {}
        local changed = false

        for _, point in ipairs(sequence.Keypoints) do
            local color = point.Value
            if sameColor(color, oldColor) then
                color = newColor
                changed = true
            end
            table.insert(points, ColorSequenceKeypoint.new(point.Time, color))
        end

        return changed and ColorSequence.new(points) or sequence
    end

    local function applyColor(oldColor, newColor)
        for _, object in ipairs(window:GetDescendants()) do
            if object:IsA("GuiObject") and sameColor(object.BackgroundColor3, oldColor) then
                object.BackgroundColor3 = newColor
            end

            if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
                if sameColor(object.TextColor3, oldColor) then
                    object.TextColor3 = newColor
                end
            end

            if object:IsA("UIStroke") and sameColor(object.Color, oldColor) then
                object.Color = newColor
            elseif object:IsA("UIGradient") then
                object.Color = recolorSequence(object.Color, oldColor, newColor)
            end
        end
    end

    function Window:SetPaletteColor(key, value)
        key = tostring(key or "")
        if P[key] == nil then
            return false, "Unknown palette key: " .. key
        end

        local parsed = hexToColor(value)
        if not parsed then
            return false, "Invalid color"
        end

        local old = P[key]
        P[key] = parsed
        applyColor(old, parsed)

        return true, parsed
    end

    function Window:GetPaletteColor(key)
        return P[tostring(key or "")]
    end

    function Window:GetPalette()
        return copy(P)
    end

    function Window:GetPaletteHex()
        local out = {}
        for key, color in pairs(P) do
            out[key] = colorToHex(color)
        end
        return out
    end

    function Window:SavePalette()
        if type(writefile) ~= "function" then
            return false, "writefile is not available in this executor"
        end

        local payload = {
            version = 1,
            colors = self:GetPaletteHex(),
        }

        local okEncode, encoded = pcall(function()
            return HttpService:JSONEncode(payload)
        end)
        if not okEncode then
            return false, encoded
        end

        local okWrite, err = pcall(writefile, paletteFile, encoded)
        if not okWrite then
            return false, err
        end

        return true, paletteFile
    end

    function Window:LoadPalette()
        local saved = readSavedPalette()
        if not saved then
            return false, "No saved palette found"
        end

        for key, value in pairs(saved) do
            self:SetPaletteColor(key, value)
        end

        return true
    end

    function Window:ResetPalette()
        for key, value in pairs(DefaultPalette) do
            self:SetPaletteColor(key, value)
        end
        return self:GetPalette()
    end

    Window._keybinds = {}

    bind(Input.InputBegan, function(input, processed)
        if not alive then
            return
        end

        for _, keybind in ipairs(Window._keybinds) do
            if keybind._capture and keybind._capture(input) then
                return
            end
        end

        if processed or Input:GetFocusedTextBox() then
            return
        end

        if toggleKey and input.KeyCode == toggleKey then
            Window:ToggleVisible()
        elseif unloadKey and input.KeyCode == unloadKey then
            Window:Destroy()
        end
    end)

    task.spawn(function()
        while task.wait(.2) do
            if not alive then
                break
            end

            local camera = workspace.CurrentCamera
            if camera then
                scale.Scale = math.min(
                    1,
                    math.max(.3, (camera.ViewportSize.X - 30) / 940),
                    math.max(.3, (camera.ViewportSize.Y - 70) / 610)
                )
            end

            for _, callback in ipairs(refresh) do
                local ok, err = pcall(callback)
                if not ok then
                    warn("[UI Library] refresh error:", err)
                end
            end
        end
    end)

    local function enforceReadableText()
        for _, object in ipairs(window:GetDescendants()) do
            if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
                if object.TextTransparency < 1 then
                    local c = object.TextColor3
                    local luminance = c.R * .2126 + c.G * .7152 + c.B * .0722

                    if luminance < .72 then
                        object.TextColor3 = Color3.fromRGB(255, 255, 255)
                    end

                    object.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                    object.TextStrokeTransparency = math.min(object.TextStrokeTransparency, .5)
                end
            end
        end
    end

    enforceReadableText()
    task.defer(enforceReadableText)

    task.spawn(function()
        while alive and task.wait(.3) do
            enforceReadableText()

            for _, object in ipairs(window:GetDescendants()) do
                if object.Name == "ButtonText" and object:IsA("TextLabel") then
                    object.TextColor3 = Color3.fromRGB(255, 255, 255)
                    object.TextTransparency = 0
                    object.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                    object.TextStrokeTransparency = .08
                    object.ZIndex = math.max(object.ZIndex, 20)
                end
            end
        end
    end)

    updateFooter()

    -- Slow ambient light sweep; intentionally subtle and limited to a few elements.
    task.spawn(function()
        local direction = 1
        while alive and task.wait(1.8) do
            direction = -direction

            TweenService:Create(windowGradient, TweenInfo.new(1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Rotation = direction > 0 and 126 or 108,
            }):Play()

            TweenService:Create(horizon, TweenInfo.new(1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                BackgroundTransparency = direction > 0 and .72 or .88,
            }):Play()

            TweenService:Create(titleGlow, TweenInfo.new(1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                TextTransparency = direction > 0 and .68 or .84,
            }):Play()
        end
    end)

    return Window
end

return Library
