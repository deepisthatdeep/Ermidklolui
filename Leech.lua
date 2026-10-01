--[[
    Leech UI Library
    Universal Roblox UI framework.
    Design direction: original Leech identity + Project Rain-style layout.
    No game-specific logic is included.
]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")

local LocalPlayer = Players.LocalPlayer

local Leech = {}
Leech.__index = Leech

Leech.Themes = {
    LeechRain = {
        Base = Color3.fromRGB(9, 10, 15),
        Base2 = Color3.fromRGB(12, 14, 20),
        Sidebar = Color3.fromRGB(14, 16, 23),
        Card = Color3.fromRGB(18, 21, 29),
        CardHover = Color3.fromRGB(24, 28, 38),
        Border = Color3.fromRGB(45, 48, 62),
        BorderSoft = Color3.fromRGB(31, 33, 44),
        Text = Color3.fromRGB(234, 231, 241),
        Muted = Color3.fromRGB(145, 149, 168),
        Faint = Color3.fromRGB(91, 94, 111),
        Accent = Color3.fromRGB(151, 105, 207),
        Accent2 = Color3.fromRGB(89, 206, 219),
        Danger = Color3.fromRGB(218, 96, 126),
        Success = Color3.fromRGB(113, 214, 167),
    },
    Rain = {
        Base = Color3.fromRGB(14, 17, 23),
        Base2 = Color3.fromRGB(16, 20, 27),
        Sidebar = Color3.fromRGB(18, 22, 29),
        Card = Color3.fromRGB(23, 28, 37),
        CardHover = Color3.fromRGB(29, 36, 46),
        Border = Color3.fromRGB(36, 44, 56),
        BorderSoft = Color3.fromRGB(28, 34, 44),
        Text = Color3.fromRGB(231, 237, 245),
        Muted = Color3.fromRGB(137, 151, 170),
        Faint = Color3.fromRGB(85, 96, 113),
        Accent = Color3.fromRGB(89, 206, 219),
        Accent2 = Color3.fromRGB(120, 138, 255),
        Danger = Color3.fromRGB(232, 104, 128),
        Success = Color3.fromRGB(115, 214, 167),
    },
    ClassicLeech = {
        Base = Color3.fromRGB(8, 7, 12),
        Base2 = Color3.fromRGB(11, 9, 16),
        Sidebar = Color3.fromRGB(13, 10, 19),
        Card = Color3.fromRGB(18, 12, 25),
        CardHover = Color3.fromRGB(24, 16, 33),
        Border = Color3.fromRGB(77, 48, 101),
        BorderSoft = Color3.fromRGB(48, 31, 62),
        Text = Color3.fromRGB(234, 225, 237),
        Muted = Color3.fromRGB(167, 149, 179),
        Faint = Color3.fromRGB(104, 88, 114),
        Accent = Color3.fromRGB(145, 99, 182),
        Accent2 = Color3.fromRGB(103, 190, 205),
        Danger = Color3.fromRGB(212, 91, 123),
        Success = Color3.fromRGB(110, 208, 157),
    },
}

local function copyTable(source)
    local out = {}
    for k, v in pairs(source or {}) do
        out[k] = v
    end
    return out
end

local function resolveTheme(theme)
    local base = Leech.Themes.LeechRain
    if type(theme) == "string" and Leech.Themes[theme] then
        base = Leech.Themes[theme]
    end
    local out = copyTable(base)
    if type(theme) == "table" then
        for k, v in pairs(theme) do
            out[k] = v
        end
    end
    return out
end

local function new(className, parent, props)
    local object = Instance.new(className)
    for key, value in pairs(props or {}) do
        object[key] = value
    end
    object.Parent = parent
    return object
end

local function corner(parent, radius)
    return new("UICorner", parent, {
        CornerRadius = UDim.new(0, radius or 8),
    })
end

local function stroke(parent, color, thickness, transparency)
    return new("UIStroke", parent, {
        Color = color,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
    })
end

local function padding(parent, left, right, top, bottom)
    return new("UIPadding", parent, {
        PaddingLeft = UDim.new(0, left or 0),
        PaddingRight = UDim.new(0, right or 0),
        PaddingTop = UDim.new(0, top or 0),
        PaddingBottom = UDim.new(0, bottom or 0),
    })
end

local function list(parent, gap)
    return new("UIListLayout", parent, {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, gap or 6),
    })
end

local function tween(object, properties, duration)
    local t = TweenService:Create(
        object,
        TweenInfo.new(duration or 0.14, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        properties
    )
    t:Play()
    return t
end

local function safeCall(callback, ...)
    if typeof(callback) ~= "function" then
        return
    end
    local args = table.pack(...)
    task.spawn(function()
        local ok, err = pcall(callback, table.unpack(args, 1, args.n))
        if not ok then
            warn("[Leech UI] callback error:", err)
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

local function textLabel(parent, textValue, size, position, color, font, textSize)
    return new("TextLabel", parent, {
        BackgroundTransparency = 1,
        Size = size,
        Position = position or UDim2.new(),
        Text = tostring(textValue or ""),
        TextColor3 = color,
        Font = font or Enum.Font.Gotham,
        TextSize = textSize or 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextTruncate = Enum.TextTruncate.AtEnd,
    })
end

function Leech:CreateWindow(cfg)
    cfg = cfg or {}

    local Theme = resolveTheme(cfg.Theme)
    local connections = {}
    local refreshers = {}
    local destroyed = false
    local minimized = false
    local tabs = {}
    local activeTab = nil

    local width = tonumber(cfg.Width) or 780
    local height = tonumber(cfg.Height) or 550
    local title = tostring(cfg.Title or "LEECH")
    local subtitleText = tostring(cfg.SubTitle or "UNIVERSAL INTERFACE")
    local versionText = tostring(cfg.Version or "UI LIBRARY")
    local toggleKey = cfg.ToggleKey == false and nil or (cfg.ToggleKey or Enum.KeyCode.RightShift)
    local unloadKey = cfg.UnloadKey == false and nil or (cfg.UnloadKey or Enum.KeyCode.F9)

    local function bind(signal, callback)
        local connection = signal:Connect(callback)
        table.insert(connections, connection)
        return connection
    end

    local gui = new("ScreenGui", cfg.Parent or defaultParent(), {
        Name = tostring(cfg.Name or "LeechUI"),
        ResetOnSpawn = false,
        IgnoreGuiInset = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = tonumber(cfg.DisplayOrder) or 100,
    })

    pcall(function()
        if syn and syn.protect_gui then
            syn.protect_gui(gui)
        end
    end)

    local shadow = new("Frame", gui, {
        Name = "Shadow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 7, 0.5, 9),
        Size = UDim2.fromOffset(width, height),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.48,
        BorderSizePixel = 0,
        ZIndex = 0,
    })
    corner(shadow, 14)

    local main = new("Frame", gui, {
        Name = "Window",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(width, height),
        BackgroundColor3 = Theme.Base,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Active = true,
        ZIndex = 1,
    })
    corner(main, 13)
    stroke(main, Theme.Border, 1, 0.05)

    local gradient = new("UIGradient", main, {
        Rotation = 25,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Theme.Base),
            ColorSequenceKeypoint.new(0.52, Theme.Base2),
            ColorSequenceKeypoint.new(1, Theme.Base),
        }),
    })

    local scale = new("UIScale", main, {Scale = 1})

    -- Intricate native background: architectural grid + rain streaks + Leech tracery.
    local art = new("Frame", main, {
        Name = "BackgroundArt",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        ZIndex = 1,
    })

    for x = 28, width, 54 do
        new("Frame", art, {
            Position = UDim2.fromOffset(x, 0),
            Size = UDim2.fromOffset(1, height),
            BorderSizePixel = 0,
            BackgroundColor3 = Theme.BorderSoft,
            BackgroundTransparency = 0.78,
            ZIndex = 1,
        })
    end

    for y = 32, height, 44 do
        new("Frame", art, {
            Position = UDim2.fromOffset(0, y),
            Size = UDim2.fromOffset(width, 1),
            BorderSizePixel = 0,
            BackgroundColor3 = Theme.BorderSoft,
            BackgroundTransparency = 0.82,
            ZIndex = 1,
        })
    end

    for i = 0, 9 do
        local streak = new("Frame", art, {
            Position = UDim2.fromOffset(110 + i * 82, -70 + (i % 3) * 28),
            Size = UDim2.fromOffset(1, height + 170),
            Rotation = 20,
            BorderSizePixel = 0,
            BackgroundColor3 = i % 2 == 0 and Theme.Accent or Theme.Accent2,
            BackgroundTransparency = 0.9,
            ZIndex = 1,
        })
        new("UIGradient", streak, {
            Rotation = 90,
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1),
                NumberSequenceKeypoint.new(0.25, 0.25),
                NumberSequenceKeypoint.new(0.72, 0.65),
                NumberSequenceKeypoint.new(1, 1),
            }),
        })
    end

    for i = 0, 4 do
        local x = 32 + i * 155
        new("Frame", art, {
            Position = UDim2.fromOffset(x, 176),
            Size = UDim2.fromOffset(1, height - 210),
            BorderSizePixel = 0,
            BackgroundColor3 = Theme.Accent,
            BackgroundTransparency = 0.89,
            ZIndex = 1,
        })
        new("Frame", art, {
            Position = UDim2.fromOffset(x - 10, 132),
            Size = UDim2.fromOffset(78, 1),
            Rotation = -48,
            BorderSizePixel = 0,
            BackgroundColor3 = Theme.Accent,
            BackgroundTransparency = 0.82,
            ZIndex = 1,
        })
        new("Frame", art, {
            Position = UDim2.fromOffset(x + 45, 132),
            Size = UDim2.fromOffset(78, 1),
            Rotation = 48,
            BorderSizePixel = 0,
            BackgroundColor3 = Theme.Accent,
            BackgroundTransparency = 0.82,
            ZIndex = 1,
        })
    end

    for _, point in ipairs({
        {16, 16}, {width - 24, 16}, {16, height - 24}, {width - 24, height - 24},
        {168, 79}, {width - 42, 79},
    }) do
        local diamond = new("Frame", art, {
            Position = UDim2.fromOffset(point[1], point[2]),
            Size = UDim2.fromOffset(8, 8),
            Rotation = 45,
            BorderSizePixel = 0,
            BackgroundColor3 = Theme.Accent,
            BackgroundTransparency = 0.34,
            ZIndex = 1,
        })
        stroke(diamond, Theme.Accent2, 1, 0.5)
    end

    local innerVeil = new("Frame", main, {
        Position = UDim2.fromOffset(8, 8),
        Size = UDim2.new(1, -16, 1, -16),
        BackgroundColor3 = Theme.Base,
        BackgroundTransparency = 0.28,
        BorderSizePixel = 0,
        ZIndex = 2,
    })
    corner(innerVeil, 10)

    local header = new("Frame", main, {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 64),
        BackgroundTransparency = 1,
        Active = true,
        ZIndex = 5,
    })

    new("Frame", header, {
        Position = UDim2.fromOffset(18, 19),
        Size = UDim2.fromOffset(4, 24),
        BorderSizePixel = 0,
        BackgroundColor3 = Theme.Accent,
        ZIndex = 6,
    })

    local titleLabel = textLabel(
        header,
        title,
        UDim2.fromOffset(155, 24),
        UDim2.fromOffset(32, 12),
        Theme.Text,
        Enum.Font.GothamBold,
        16
    )
    titleLabel.ZIndex = 6

    local subLabel = textLabel(
        header,
        subtitleText,
        UDim2.fromOffset(260, 16),
        UDim2.fromOffset(32, 37),
        Theme.Muted,
        Enum.Font.GothamMedium,
        9
    )
    subLabel.ZIndex = 6

    local statusChip = new("Frame", header, {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -88, 0, 18),
        Size = UDim2.fromOffset(100, 27),
        BackgroundColor3 = Theme.Card,
        BorderSizePixel = 0,
        ZIndex = 6,
    })
    corner(statusChip, 7)
    stroke(statusChip, Theme.Border, 1, 0.35)

    local statusDot = new("Frame", statusChip, {
        Position = UDim2.fromOffset(10, 10),
        Size = UDim2.fromOffset(7, 7),
        BackgroundColor3 = Theme.Accent2,
        BorderSizePixel = 0,
        ZIndex = 7,
    })
    corner(statusDot, 99)

    local statusText = textLabel(
        statusChip,
        "READY",
        UDim2.new(1, -27, 1, 0),
        UDim2.fromOffset(24, 0),
        Theme.Muted,
        Enum.Font.GothamMedium,
        9
    )
    statusText.ZIndex = 7

    local function headerButton(textValue, rightOffset)
        local b = new("TextButton", header, {
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, rightOffset, 0, 18),
            Size = UDim2.fromOffset(27, 27),
            Text = textValue,
            Font = Enum.Font.GothamMedium,
            TextSize = 14,
            TextColor3 = Theme.Muted,
            BackgroundColor3 = Theme.Card,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Selectable = false,
            ZIndex = 7,
        })
        corner(b, 7)
        stroke(b, Theme.Border, 1, 0.35)
        return b
    end

    local minimizeButton = headerButton("−", -49)
    local closeButton = headerButton("×", -16)

    new("Frame", main, {
        Position = UDim2.fromOffset(16, 63),
        Size = UDim2.new(1, -32, 0, 1),
        BorderSizePixel = 0,
        BackgroundColor3 = Theme.Border,
        BackgroundTransparency = 0.22,
        ZIndex = 5,
    })

    local body = new("Frame", main, {
        Name = "Body",
        Position = UDim2.fromOffset(0, 64),
        Size = UDim2.new(1, 0, 1, -94),
        BackgroundTransparency = 1,
        ZIndex = 4,
    })

    local sidebar = new("Frame", body, {
        Name = "Sidebar",
        Position = UDim2.fromOffset(12, 12),
        Size = UDim2.new(0, 165, 1, -24),
        BackgroundColor3 = Theme.Sidebar,
        BackgroundTransparency = 0.08,
        BorderSizePixel = 0,
        ZIndex = 5,
    })
    corner(sidebar, 10)
    stroke(sidebar, Theme.BorderSoft, 1, 0.12)

    local workspaceLabel = textLabel(
        sidebar,
        "WORKSPACE",
        UDim2.new(1, -24, 0, 16),
        UDim2.fromOffset(14, 12),
        Theme.Faint,
        Enum.Font.GothamBold,
        9
    )
    workspaceLabel.ZIndex = 6

    local navHolder = new("Frame", sidebar, {
        Position = UDim2.fromOffset(8, 38),
        Size = UDim2.new(1, -16, 1, -100),
        BackgroundTransparency = 1,
        ZIndex = 6,
    })
    list(navHolder, 6)

    local libraryBadge = new("Frame", sidebar, {
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 10, 1, -10),
        Size = UDim2.new(1, -20, 0, 50),
        BackgroundColor3 = Theme.Card,
        BorderSizePixel = 0,
        ZIndex = 6,
    })
    corner(libraryBadge, 8)

    local badgeTop = textLabel(
        libraryBadge,
        versionText,
        UDim2.new(1, -20, 0, 18),
        UDim2.fromOffset(10, 7),
        Theme.Muted,
        Enum.Font.GothamBold,
        9
    )
    badgeTop.ZIndex = 7

    local badgeBottom = textLabel(
        libraryBadge,
        "UNIVERSAL  /  READY",
        UDim2.new(1, -20, 0, 18),
        UDim2.fromOffset(10, 25),
        Theme.Faint,
        Enum.Font.Gotham,
        9
    )
    badgeBottom.ZIndex = 7

    local content = new("Frame", body, {
        Name = "Content",
        Position = UDim2.fromOffset(192, 12),
        Size = UDim2.new(1, -204, 1, -24),
        BackgroundTransparency = 1,
        ZIndex = 5,
    })

    local pageTitle = textLabel(
        content,
        "Overview",
        UDim2.new(1, -20, 0, 28),
        UDim2.fromOffset(0, 0),
        Theme.Text,
        Enum.Font.GothamBold,
        20
    )
    pageTitle.ZIndex = 6

    local pageSubtitle = textLabel(
        content,
        "Select a workspace",
        UDim2.new(1, -20, 0, 18),
        UDim2.fromOffset(0, 30),
        Theme.Muted,
        Enum.Font.Gotham,
        11
    )
    pageSubtitle.ZIndex = 6

    local pagesHolder = new("Frame", content, {
        Position = UDim2.fromOffset(0, 58),
        Size = UDim2.new(1, 0, 1, -58),
        BackgroundTransparency = 1,
        ZIndex = 6,
    })

    local footer = new("Frame", main, {
        Name = "Footer",
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 0, 1, 0),
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1,
        ZIndex = 5,
    })

    local footerLeft = textLabel(
        footer,
        versionText,
        UDim2.fromOffset(300, 16),
        UDim2.fromOffset(18, 7),
        Theme.Faint,
        Enum.Font.GothamMedium,
        9
    )
    footerLeft.ZIndex = 6

    local keyHint = toggleKey and ((toggleKey.Name or tostring(toggleKey)) .. "  SHOW / HIDE") or ""
    if unloadKey then
        keyHint ..= (keyHint ~= "" and "     " or "") .. (unloadKey.Name or tostring(unloadKey)) .. "  UNLOAD"
    end

    local footerRight = textLabel(
        footer,
        keyHint,
        UDim2.fromOffset(330, 16),
        UDim2.new(1, -348, 0, 7),
        Theme.Faint,
        Enum.Font.GothamMedium,
        9
    )
    footerRight.TextXAlignment = Enum.TextXAlignment.Right
    footerRight.ZIndex = 6

    local Window = {}

    function Window:SetStatus(textValue, color)
        statusText.Text = string.upper(tostring(textValue or "READY"))
        statusDot.BackgroundColor3 = color or Theme.Accent2
    end

    function Window:SetFooter(leftText, rightText)
        if leftText ~= nil then
            footerLeft.Text = tostring(leftText)
        end
        if rightText ~= nil then
            footerRight.Text = tostring(rightText)
        end
    end

    function Window:SetVisible(value)
        gui.Enabled = value == true
    end

    function Window:ToggleVisible()
        gui.Enabled = not gui.Enabled
    end

    function Window:SetTheme(theme)
        -- Runtime theme mutation is intentionally conservative; the next window
        -- can use any preset/custom table without rebuilding existing objects.
        cfg.Theme = theme
    end

    function Window:Destroy()
        if destroyed then
            return
        end
        destroyed = true
        safeCall(cfg.OnUnload)

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

    function Window:Notify(notificationCfg)
        notificationCfg = notificationCfg or {}
        local notice = new("Frame", main, {
            AnchorPoint = Vector2.new(1, 1),
            Position = UDim2.new(1, -16, 1, -42),
            Size = UDim2.fromOffset(290, 76),
            BackgroundColor3 = Theme.Card,
            BorderSizePixel = 0,
            ZIndex = 30,
        })
        corner(notice, 9)
        stroke(notice, Theme.Border, 1, 0.1)

        local stripe = new("Frame", notice, {
            Size = UDim2.fromOffset(3, 52),
            Position = UDim2.fromOffset(10, 12),
            BackgroundColor3 = notificationCfg.Color or Theme.Accent,
            BorderSizePixel = 0,
            ZIndex = 31,
        })
        corner(stripe, 3)

        local nTitle = textLabel(
            notice,
            notificationCfg.Title or "Notification",
            UDim2.new(1, -36, 0, 20),
            UDim2.fromOffset(24, 11),
            Theme.Text,
            Enum.Font.GothamBold,
            11
        )
        nTitle.ZIndex = 31

        local nBody = textLabel(
            notice,
            notificationCfg.Content or "",
            UDim2.new(1, -36, 0, 34),
            UDim2.fromOffset(24, 33),
            Theme.Muted,
            Enum.Font.Gotham,
            10
        )
        nBody.TextWrapped = true
        nBody.TextTruncate = Enum.TextTruncate.None
        nBody.TextYAlignment = Enum.TextYAlignment.Top
        nBody.ZIndex = 31

        notice.Position = UDim2.new(1, 320, 1, -42)
        tween(notice, {Position = UDim2.new(1, -16, 1, -42)}, 0.22)

        task.delay(tonumber(notificationCfg.Duration) or 3, function()
            if notice and notice.Parent then
                local out = tween(notice, {Position = UDim2.new(1, 320, 1, -42)}, 0.2)
                task.delay(0.22, function()
                    if notice and notice.Parent then
                        notice:Destroy()
                    end
                end)
            end
        end)
    end

    local function selectTab(tab)
        activeTab = tab

        for _, entry in ipairs(tabs) do
            local selected = entry == tab
            entry.Page.Visible = selected
            entry.Button.BackgroundColor3 = selected and Theme.CardHover or Theme.Sidebar
            entry.Button.TextColor3 = selected and Theme.Text or Theme.Muted
            entry.Marker.Visible = selected
            entry.IndexLabel.TextColor3 = selected and Theme.Accent2 or Theme.Faint
        end

        pageTitle.Text = tab.Title
        pageSubtitle.Text = tab.Description
    end

    function Window:CreateTab(tabCfg)
        tabCfg = tabCfg or {}

        local indexNumber = #tabs + 1
        local titleValue = tostring(tabCfg.Title or ("Tab " .. indexNumber))
        local description = tostring(tabCfg.Description or "Workspace controls")
        local displayIndex = tabCfg.Index ~= nil and tostring(tabCfg.Index) or string.format("%02d", indexNumber)

        if tonumber(displayIndex) then
            displayIndex = string.format("%02d", tonumber(displayIndex))
        end

        local button = new("TextButton", navHolder, {
            LayoutOrder = indexNumber,
            Size = UDim2.new(1, 0, 0, 38),
            BackgroundColor3 = Theme.Sidebar,
            BorderSizePixel = 0,
            Text = "      " .. titleValue,
            TextColor3 = Theme.Muted,
            Font = Enum.Font.GothamMedium,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            AutoButtonColor = false,
            Selectable = false,
            ZIndex = 7,
        })
        corner(button, 7)

        local marker = new("Frame", button, {
            Name = "Marker",
            Position = UDim2.fromOffset(1, 9),
            Size = UDim2.fromOffset(2, 20),
            BackgroundColor3 = Theme.Accent,
            BorderSizePixel = 0,
            Visible = false,
            ZIndex = 8,
        })
        corner(marker, 2)

        local indexLabel = textLabel(
            button,
            displayIndex,
            UDim2.fromOffset(26, 18),
            UDim2.fromOffset(11, 10),
            Theme.Faint,
            Enum.Font.GothamBold,
            9
        )
        indexLabel.ZIndex = 8

        local page = new("ScrollingFrame", pagesHolder, {
            Name = titleValue,
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.Border,
            CanvasSize = UDim2.new(),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollingDirection = Enum.ScrollingDirection.Y,
            Visible = false,
            ZIndex = 7,
        })
        list(page, 8)
        padding(page, 0, 6, 0, 10)

        local Tab = {
            Window = Window,
            Title = titleValue,
            Description = description,
            Button = button,
            Marker = marker,
            IndexLabel = indexLabel,
            Page = page,
            Sections = {},
        }

        function Tab:Select()
            selectTab(self)
        end

        bind(button.Activated, function()
            selectTab(Tab)
        end)

        function Tab:CreateSection(sectionCfg)
            sectionCfg = sectionCfg or {}

            local sectionTitle = tostring(sectionCfg.Title or "Section")
            local sectionDescription = sectionCfg.Description
            local layoutOrder = tonumber(sectionCfg.LayoutOrder) or (#self.Sections + 1)

            local card = new("Frame", page, {
                LayoutOrder = layoutOrder,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = Theme.Card,
                BackgroundTransparency = 0.04,
                BorderSizePixel = 0,
                ZIndex = 8,
            })
            corner(card, 9)
            stroke(card, Theme.BorderSoft, 1, 0.05)
            padding(card, 14, 14, 12, 13)
            list(card, 7)

            local topAccent = new("Frame", card, {
                LayoutOrder = -100,
                Size = UDim2.new(1, 0, 0, 2),
                BackgroundColor3 = Theme.Accent,
                BackgroundTransparency = 0.42,
                BorderSizePixel = 0,
                ZIndex = 9,
            })
            new("UIGradient", topAccent, {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Theme.Accent),
                    ColorSequenceKeypoint.new(0.55, Theme.Accent2),
                    ColorSequenceKeypoint.new(1, Theme.Card),
                }),
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0.1),
                    NumberSequenceKeypoint.new(1, 1),
                }),
            })

            local headingText = sectionTitle
            if sectionCfg.Level ~= nil then
                headingText ..= "   /   LEVEL " .. tostring(sectionCfg.Level)
            end

            local heading = textLabel(
                card,
                string.upper(headingText),
                UDim2.new(1, 0, 0, 20),
                nil,
                Theme.Text,
                Enum.Font.GothamBold,
                11
            )
            heading.LayoutOrder = -90
            heading.ZIndex = 9

            if sectionDescription and sectionDescription ~= "" then
                local hint = textLabel(
                    card,
                    tostring(sectionDescription),
                    UDim2.new(1, 0, 0, 0),
                    nil,
                    Theme.Muted,
                    Enum.Font.Gotham,
                    10
                )
                hint.LayoutOrder = -80
                hint.AutomaticSize = Enum.AutomaticSize.Y
                hint.TextWrapped = true
                hint.TextTruncate = Enum.TextTruncate.None
                hint.TextYAlignment = Enum.TextYAlignment.Top
                hint.ZIndex = 9
            end

            local Section = {
                Tab = Tab,
                Card = card,
            }

            local function controlRow(height)
                return new("Frame", card, {
                    Size = UDim2.new(1, 0, 0, height or 38),
                    BackgroundTransparency = 1,
                    ZIndex = 9,
                })
            end

            local function rowLabel(row, value, widthScale)
                local label = textLabel(
                    row,
                    value,
                    UDim2.new(widthScale or 0.62, 0, 1, 0),
                    nil,
                    Theme.Text,
                    Enum.Font.Gotham,
                    11
                )
                label.ZIndex = 10
                return label
            end

            function Section:CreateToggle(controlCfg)
                controlCfg = controlCfg or {}
                local state = controlCfg.Default == true
                local row = controlRow(38)
                local label = rowLabel(row, controlCfg.Title or "Toggle", 0.72)

                local switch = new("TextButton", row, {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.fromOffset(44, 22),
                    BackgroundColor3 = Theme.BorderSoft,
                    BorderSizePixel = 0,
                    Text = "",
                    AutoButtonColor = false,
                    Selectable = false,
                    ZIndex = 10,
                })
                corner(switch, 99)

                local knob = new("Frame", switch, {
                    Position = UDim2.fromOffset(3, 3),
                    Size = UDim2.fromOffset(16, 16),
                    BackgroundColor3 = Theme.Muted,
                    BorderSizePixel = 0,
                    ZIndex = 11,
                })
                corner(knob, 99)

                local object = {}

                local function render()
                    tween(switch, {
                        BackgroundColor3 = state and Theme.Accent or Theme.BorderSoft,
                    }, 0.13)
                    tween(knob, {
                        Position = state and UDim2.fromOffset(25, 3) or UDim2.fromOffset(3, 3),
                        BackgroundColor3 = state and Theme.Text or Theme.Muted,
                    }, 0.13)
                end

                local function set(value, fire)
                    state = value == true
                    object.Value.Current = state
                    render()
                    if fire then
                        safeCall(controlCfg.Callback, state)
                    end
                end

                object.Value = proxy(state, function(value)
                    set(value, true)
                end)
                object.Name = proxy(controlCfg.Title or "Toggle", function(value)
                    value = tostring(value)
                    object.Name.Current = value
                    label.Text = value
                end)

                bind(switch.Activated, function()
                    set(not state, true)
                end)

                render()
                return object
            end

            function Section:CreateButton(controlCfg)
                controlCfg = controlCfg or {}

                local buttonObject = new("TextButton", card, {
                    Size = UDim2.new(1, 0, 0, 34),
                    BackgroundColor3 = Theme.Base2,
                    BorderSizePixel = 0,
                    Text = tostring(controlCfg.Title or "Button"),
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.GothamMedium,
                    TextSize = 11,
                    AutoButtonColor = false,
                    Selectable = false,
                    ZIndex = 10,
                })
                corner(buttonObject, 7)
                stroke(buttonObject, Theme.BorderSoft, 1, 0.05)

                bind(buttonObject.MouseEnter, function()
                    tween(buttonObject, {BackgroundColor3 = Theme.CardHover}, 0.12)
                end)
                bind(buttonObject.MouseLeave, function()
                    tween(buttonObject, {BackgroundColor3 = Theme.Base2}, 0.12)
                end)
                bind(buttonObject.Activated, function()
                    safeCall(controlCfg.Callback)
                end)

                local object = {}
                object.Name = proxy(controlCfg.Title or "Button", function(value)
                    value = tostring(value)
                    object.Name.Current = value
                    buttonObject.Text = value
                end)
                return object
            end

            function Section:CreateInput(controlCfg)
                controlCfg = controlCfg or {}
                local value = controlCfg.Default
                if value == nil then
                    value = ""
                end

                local row = controlRow(42)
                local label = rowLabel(row, controlCfg.Title or "Input", 0.48)

                local box = new("TextBox", row, {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.new(0.48, 0, 0, 30),
                    BackgroundColor3 = Theme.Base2,
                    BorderSizePixel = 0,
                    Text = tostring(value),
                    PlaceholderText = tostring(controlCfg.Placeholder or ""),
                    TextColor3 = Theme.Text,
                    PlaceholderColor3 = Theme.Faint,
                    Font = Enum.Font.Gotham,
                    TextSize = 10,
                    ClearTextOnFocus = false,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 10,
                })
                corner(box, 7)
                stroke(box, Theme.BorderSoft, 1, 0.1)
                padding(box, 10, 10, 0, 0)

                local object = {}

                local function normalize(raw)
                    if controlCfg.Numeric then
                        local number = tonumber(raw)
                        if number == nil then
                            return nil
                        end
                        if controlCfg.Min ~= nil then
                            number = math.max(controlCfg.Min, number)
                        end
                        if controlCfg.Max ~= nil then
                            number = math.min(controlCfg.Max, number)
                        end
                        return number
                    end
                    return tostring(raw)
                end

                local function set(raw, fire)
                    local normalized = normalize(raw)
                    if normalized == nil then
                        box.Text = tostring(value)
                        return
                    end
                    value = normalized
                    object.Value.Current = value
                    box.Text = tostring(value)
                    if fire then
                        safeCall(controlCfg.Callback, value)
                    end
                end

                object.Value = proxy(value, function(newValue)
                    set(newValue, true)
                end)
                object.Name = proxy(controlCfg.Title or "Input", function(newValue)
                    newValue = tostring(newValue)
                    object.Name.Current = newValue
                    label.Text = newValue
                end)

                bind(box.FocusLost, function()
                    set(box.Text, true)
                end)

                return object
            end

            function Section:CreateSlider(controlCfg)
                controlCfg = controlCfg or {}

                local range = controlCfg.Range or {0, 100}
                local minValue = tonumber(range[1]) or 0
                local maxValue = tonumber(range[2]) or 100
                local increment = tonumber(controlCfg.Increment) or 1
                local suffix = tostring(controlCfg.Suffix or "")
                local value = tonumber(controlCfg.Default)
                if value == nil then
                    value = minValue
                end
                value = math.clamp(value, minValue, maxValue)

                local row = controlRow(58)
                local label = rowLabel(row, controlCfg.Title or "Slider", 0.66)

                local valueText = textLabel(
                    row,
                    tostring(value) .. suffix,
                    UDim2.fromOffset(110, 20),
                    UDim2.new(1, -110, 0, 0),
                    Theme.Muted,
                    Enum.Font.GothamMedium,
                    10
                )
                valueText.TextXAlignment = Enum.TextXAlignment.Right
                valueText.ZIndex = 10

                local track = new("TextButton", row, {
                    Position = UDim2.new(0, 0, 1, -16),
                    Size = UDim2.new(1, 0, 0, 5),
                    BackgroundColor3 = Theme.BorderSoft,
                    BorderSizePixel = 0,
                    Text = "",
                    AutoButtonColor = false,
                    Selectable = false,
                    ZIndex = 10,
                })
                corner(track, 99)

                local fill = new("Frame", track, {
                    Size = UDim2.fromScale(0, 1),
                    BackgroundColor3 = Theme.Accent,
                    BorderSizePixel = 0,
                    ZIndex = 11,
                })
                corner(fill, 99)

                local knob = new("Frame", track, {
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.fromScale(0, 0.5),
                    Size = UDim2.fromOffset(12, 12),
                    BackgroundColor3 = Theme.Text,
                    BorderSizePixel = 0,
                    ZIndex = 12,
                })
                corner(knob, 99)
                stroke(knob, Theme.Accent, 2, 0)

                local dragging = false
                local object = {}

                local function snap(number)
                    number = math.clamp(number, minValue, maxValue)
                    local snapped = math.floor(((number - minValue) / increment) + 0.5) * increment + minValue
                    return math.clamp(snapped, minValue, maxValue)
                end

                local function render()
                    local alpha = (value - minValue) / math.max(0.0001, maxValue - minValue)
                    fill.Size = UDim2.fromScale(alpha, 1)
                    knob.Position = UDim2.fromScale(alpha, 0.5)
                    valueText.Text = tostring(value) .. suffix
                end

                local function set(number, fire)
                    number = tonumber(number)
                    if not number then
                        return
                    end
                    value = snap(number)
                    object.Value.Current = value
                    render()
                    if fire then
                        safeCall(controlCfg.Callback, value)
                    end
                end

                local function fromPointer(x)
                    local alpha = math.clamp(
                        (x - track.AbsolutePosition.X) / math.max(1, track.AbsoluteSize.X),
                        0,
                        1
                    )
                    set(minValue + (maxValue - minValue) * alpha, true)
                end

                object.Value = proxy(value, function(newValue)
                    set(newValue, true)
                end)
                object.Name = proxy(controlCfg.Title or "Slider", function(newValue)
                    newValue = tostring(newValue)
                    object.Name.Current = newValue
                    label.Text = newValue
                end)

                bind(track.InputBegan, function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1
                        or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        fromPointer(input.Position.X)
                    end
                end)

                bind(UIS.InputChanged, function(input)
                    if dragging and (
                        input.UserInputType == Enum.UserInputType.MouseMovement
                        or input.UserInputType == Enum.UserInputType.Touch
                    ) then
                        fromPointer(input.Position.X)
                    end
                end)

                bind(UIS.InputEnded, function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1
                        or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)

                render()
                return object
            end

            function Section:CreateDropdown(controlCfg)
                controlCfg = controlCfg or {}

                local options = controlCfg.Options or {}
                local multi = controlCfg.Multi == true
                local selected = controlCfg.Selected or {}
                if typeof(selected) ~= "table" then
                    selected = {selected}
                end

                local row = controlRow(42)
                local label = rowLabel(row, controlCfg.Title or "Dropdown", 0.46)

                local selectButton = new("TextButton", row, {
                    AnchorPoint = Vector2.new(1, 0),
                    Position = UDim2.new(1, 0, 0, 5),
                    Size = UDim2.new(0.5, 0, 0, 30),
                    BackgroundColor3 = Theme.Base2,
                    BorderSizePixel = 0,
                    Text = "",
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 10,
                    AutoButtonColor = false,
                    Selectable = false,
                    ZIndex = 10,
                })
                corner(selectButton, 7)
                stroke(selectButton, Theme.BorderSoft, 1, 0.1)

                local choices = new("Frame", row, {
                    Position = UDim2.new(0.5, 0, 0, 38),
                    Size = UDim2.new(0.5, 0, 0, 0),
                    BackgroundColor3 = Theme.Base2,
                    BorderSizePixel = 0,
                    ClipsDescendants = true,
                    Visible = false,
                    ZIndex = 20,
                })
                corner(choices, 7)
                stroke(choices, Theme.Border, 1, 0.08)

                local open = false
                local optionButtons = {}
                local object = {}

                local function displaySelection()
                    if #selected == 0 then
                        selectButton.Text = "Select   ▾"
                    else
                        selectButton.Text = table.concat(selected, ", ") .. "   ▾"
                    end
                end

                local function setOpen(value)
                    open = value == true
                    choices.Visible = open
                    local optionHeight = #options * 29 + 6
                    choices.Size = UDim2.new(0.5, 0, 0, open and optionHeight or 0)
                    row.Size = UDim2.new(1, 0, 0, open and (44 + optionHeight) or 42)
                    selectButton.Text = string.gsub(selectButton.Text, open and "▾" or "▴", open and "▴" or "▾")
                end

                local function emit()
                    object.Value.Current = copyTable(selected)
                    displaySelection()
                    safeCall(controlCfg.Callback, copyTable(selected))
                end

                local function contains(value)
                    return table.find(selected, value)
                end

                local function rebuild()
                    for _, buttonObject in ipairs(optionButtons) do
                        if buttonObject and buttonObject.Parent then
                            buttonObject:Destroy()
                        end
                    end
                    table.clear(optionButtons)

                    for index, option in ipairs(options) do
                        local optionValue = tostring(option)
                        local optionButton = new("TextButton", choices, {
                            Position = UDim2.fromOffset(3, 3 + (index - 1) * 29),
                            Size = UDim2.new(1, -6, 0, 26),
                            BackgroundColor3 = contains(option) and Theme.CardHover or Theme.Base2,
                            BorderSizePixel = 0,
                            Text = "   " .. optionValue,
                            TextColor3 = contains(option) and Theme.Accent2 or Theme.Muted,
                            Font = Enum.Font.Gotham,
                            TextSize = 10,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            AutoButtonColor = false,
                            Selectable = false,
                            ZIndex = 21,
                        })
                        corner(optionButton, 5)
                        table.insert(optionButtons, optionButton)

                        bind(optionButton.Activated, function()
                            if multi then
                                local at = table.find(selected, option)
                                if at then
                                    table.remove(selected, at)
                                else
                                    table.insert(selected, option)
                                end
                            else
                                selected = {option}
                                setOpen(false)
                            end
                            rebuild()
                            emit()
                        end)
                    end

                    if open then
                        setOpen(true)
                    end
                end

                object.Value = proxy(copyTable(selected), function(value)
                    if typeof(value) == "table" then
                        selected = copyTable(value)
                    else
                        selected = {value}
                    end
                    rebuild()
                    emit()
                end)

                object.Options = proxy(copyTable(options), function(value)
                    options = value or {}
                    object.Options.Current = copyTable(options)
                    rebuild()
                end)

                object.Name = proxy(controlCfg.Title or "Dropdown", function(value)
                    value = tostring(value)
                    object.Name.Current = value
                    label.Text = value
                end)

                bind(selectButton.Activated, function()
                    setOpen(not open)
                end)

                rebuild()
                displaySelection()
                return object
            end

            function Section:CreateKeybind(controlCfg)
                controlCfg = controlCfg or {}

                local current = controlCfg.Default or Enum.KeyCode.RightShift
                local listening = false
                local row = controlRow(40)
                local label = rowLabel(row, controlCfg.Title or "Keybind", 0.62)

                local keyButton = new("TextButton", row, {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.fromOffset(120, 30),
                    BackgroundColor3 = Theme.Base2,
                    BorderSizePixel = 0,
                    Text = current.Name,
                    TextColor3 = Theme.Muted,
                    Font = Enum.Font.GothamMedium,
                    TextSize = 10,
                    AutoButtonColor = false,
                    Selectable = false,
                    ZIndex = 10,
                })
                corner(keyButton, 7)
                stroke(keyButton, Theme.BorderSoft, 1, 0.1)

                local object = {}

                local function set(value, fire)
                    if typeof(value) ~= "EnumItem" then
                        return
                    end
                    current = value
                    object.Value.Current = current
                    keyButton.Text = current.Name
                    keyButton.TextColor3 = Theme.Muted
                    if fire then
                        safeCall(controlCfg.Callback, current)
                    end
                end

                object.Value = proxy(current, function(value)
                    set(value, true)
                end)
                object.Name = proxy(controlCfg.Title or "Keybind", function(value)
                    value = tostring(value)
                    object.Name.Current = value
                    label.Text = value
                end)

                bind(keyButton.Activated, function()
                    listening = true
                    keyButton.Text = "PRESS A KEY"
                    keyButton.TextColor3 = Theme.Accent2
                end)

                bind(UIS.InputBegan, function(input, processed)
                    if not listening then
                        return
                    end
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        listening = false
                        set(input.KeyCode, true)
                    end
                end)

                return object
            end

            function Section:CreateLabel(contentValue)
                local label = textLabel(
                    card,
                    tostring(contentValue or ""),
                    UDim2.new(1, 0, 0, 24),
                    nil,
                    Theme.Muted,
                    Enum.Font.Gotham,
                    10
                )
                label.ZIndex = 10

                local object = {}
                object.Value = proxy(contentValue or "", function(value)
                    value = tostring(value)
                    object.Value.Current = value
                    label.Text = value
                end)
                return object
            end

            function Section:CreateParagraph(controlCfg)
                controlCfg = controlCfg or {}

                local holder = new("Frame", card, {
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundColor3 = Theme.Base2,
                    BorderSizePixel = 0,
                    ZIndex = 9,
                })
                corner(holder, 7)
                padding(holder, 11, 11, 9, 10)
                list(holder, 4)

                local pTitle
                if controlCfg.Title and controlCfg.Title ~= "" then
                    pTitle = textLabel(
                        holder,
                        controlCfg.Title,
                        UDim2.new(1, 0, 0, 18),
                        nil,
                        Theme.Text,
                        Enum.Font.GothamBold,
                        10
                    )
                    pTitle.ZIndex = 10
                end

                local pBody = textLabel(
                    holder,
                    controlCfg.Content or "",
                    UDim2.new(1, 0, 0, 0),
                    nil,
                    Theme.Muted,
                    Enum.Font.Gotham,
                    10
                )
                pBody.AutomaticSize = Enum.AutomaticSize.Y
                pBody.TextWrapped = true
                pBody.TextTruncate = Enum.TextTruncate.None
                pBody.TextYAlignment = Enum.TextYAlignment.Top
                pBody.ZIndex = 10

                local object = {}
                object.Title = proxy(controlCfg.Title or "", function(value)
                    value = tostring(value)
                    object.Title.Current = value
                    if pTitle then
                        pTitle.Text = value
                    end
                end)
                object.Content = proxy(controlCfg.Content or "", function(value)
                    value = tostring(value)
                    object.Content.Current = value
                    pBody.Text = value
                end)
                return object
            end

            function Section:CreateSeparator(controlCfg)
                controlCfg = controlCfg or {}

                local holder = controlRow(controlCfg.Title and 26 or 12)
                local rule = new("Frame", holder, {
                    AnchorPoint = Vector2.new(0, 0.5),
                    Position = UDim2.new(0, 0, 0.5, 0),
                    Size = UDim2.new(1, 0, 0, 1),
                    BackgroundColor3 = Theme.BorderSoft,
                    BorderSizePixel = 0,
                    ZIndex = 10,
                })

                if controlCfg.Title then
                    local badge = textLabel(
                        holder,
                        string.upper(tostring(controlCfg.Title)),
                        UDim2.fromOffset(120, 18),
                        UDim2.fromOffset(0, 4),
                        Theme.Faint,
                        Enum.Font.GothamBold,
                        8
                    )
                    badge.BackgroundTransparency = 0
                    badge.BackgroundColor3 = Theme.Card
                    badge.ZIndex = 11
                end

                return {Frame = holder}
            end

            function Section:CreateProgress(controlCfg)
                controlCfg = controlCfg or {}
                local value = math.clamp(tonumber(controlCfg.Default) or 0, 0, 1)

                local row = controlRow(54)
                local label = rowLabel(row, controlCfg.Title or "Progress", 0.72)

                local percent = textLabel(
                    row,
                    string.format("%d%%", math.floor(value * 100 + 0.5)),
                    UDim2.fromOffset(90, 20),
                    UDim2.new(1, -90, 0, 0),
                    Theme.Muted,
                    Enum.Font.GothamMedium,
                    10
                )
                percent.TextXAlignment = Enum.TextXAlignment.Right
                percent.ZIndex = 10

                local track = new("Frame", row, {
                    Position = UDim2.new(0, 0, 1, -13),
                    Size = UDim2.new(1, 0, 0, 4),
                    BackgroundColor3 = Theme.BorderSoft,
                    BorderSizePixel = 0,
                    ZIndex = 10,
                })
                corner(track, 99)

                local fill = new("Frame", track, {
                    Size = UDim2.fromScale(value, 1),
                    BackgroundColor3 = Theme.Accent2,
                    BorderSizePixel = 0,
                    ZIndex = 11,
                })
                corner(fill, 99)

                local object = {}
                object.Value = proxy(value, function(newValue)
                    value = math.clamp(tonumber(newValue) or 0, 0, 1)
                    object.Value.Current = value
                    tween(fill, {Size = UDim2.fromScale(value, 1)}, 0.16)
                    percent.Text = string.format("%d%%", math.floor(value * 100 + 0.5))
                    safeCall(controlCfg.Callback, value)
                end)
                object.Name = proxy(controlCfg.Title or "Progress", function(newValue)
                    newValue = tostring(newValue)
                    object.Name.Current = newValue
                    label.Text = newValue
                end)
                return object
            end

            table.insert(self.Sections, Section)
            return Section
        end

        table.insert(tabs, Tab)

        if not activeTab then
            selectTab(Tab)
        end

        return Tab
    end

    bind(minimizeButton.Activated, function()
        minimized = not minimized
        body.Visible = not minimized
        footer.Visible = not minimized
        statusChip.Visible = not minimized
        subLabel.Visible = not minimized

        local targetHeight = minimized and 64 or height
        main.Size = UDim2.fromOffset(width, targetHeight)
        shadow.Size = UDim2.fromOffset(width, targetHeight)
        minimizeButton.Text = minimized and "+" or "−"
    end)

    bind(closeButton.Activated, function()
        Window:Destroy()
    end)

    local dragInput
    local dragStart
    local startPosition

    bind(header.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
            dragStart = input.Position
            startPosition = main.Position
        end
    end)

    bind(UIS.InputEnded, function(input)
        if input == dragInput then
            dragInput = nil
        end
    end)

    bind(UIS.InputChanged, function(input)
        if dragInput and (
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input == dragInput
        ) then
            local delta = input.Position - dragStart
            local newPosition = UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + delta.X,
                startPosition.Y.Scale,
                startPosition.Y.Offset + delta.Y
            )
            main.Position = newPosition
            shadow.Position = UDim2.new(
                newPosition.X.Scale,
                newPosition.X.Offset + 7,
                newPosition.Y.Scale,
                newPosition.Y.Offset + 9
            )
        end
    end)

    bind(UIS.InputBegan, function(input, processed)
        if processed or UIS:GetFocusedTextBox() then
            return
        end

        if toggleKey and input.KeyCode == toggleKey then
            Window:ToggleVisible()
        elseif unloadKey and input.KeyCode == unloadKey then
            Window:Destroy()
        end
    end)

    local function fit()
        local camera = workspace.CurrentCamera
        if not camera then
            return
        end

        local viewport = camera.ViewportSize
        scale.Scale = math.max(
            0.25,
            math.min(1, (viewport.X - 26) / width, (viewport.Y - 26) / height)
        )
    end

    fit()

    if workspace.CurrentCamera then
        bind(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"), fit)
    end

    return Window
end

return Leech
