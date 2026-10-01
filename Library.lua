--[[
    Universal UI Library
    Reusable Roblox UI framework based on the original interface layout.
    Neutral branding, no game-specific logic, no pause system.
]]

local Players = game:GetService("Players")
local Input = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

local Library = {}
Library.__index = Library

Library.Palette = {
    bg = Color3.fromRGB(8, 7, 12),
    card = Color3.fromRGB(18, 12, 25),
    line = Color3.fromRGB(77, 48, 101),
    accent = Color3.fromRGB(145, 99, 182),
    bright = Color3.fromRGB(211, 187, 229),
    text = Color3.fromRGB(234, 225, 237),
    muted = Color3.fromRGB(167, 149, 179),
}

local function copy(source)
    local out = {}
    for key, value in pairs(source or {}) do
        out[key] = value
    end
    return out
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
    local connections = {}
    local refresh = {}
    local tabs = {}
    local pages = {}
    local nav = {}
    local alive = true
    local activeTab = nil
    local capturingKey = false

    local title = tostring(cfg.Title or "INTERFACE")
    local subtitleText = tostring(cfg.SubTitle or "U N I V E R S A L")
    local productName = tostring(cfg.ProductName or "SYSTEM")
    local currentPage = tostring(cfg.CurrentPage or "MAIN")
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
        Size = UDim2.fromOffset(850, 566),
        Position = UDim2.new(.5, -425, .5, -283),
        BackgroundColor3 = P.bg,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Active = true,
    })

    make("UIStroke", window, {
        Color = P.line,
        Thickness = 1,
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
            Font = font or Enum.Font.Code,
            TextSize = size or 12,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
        })
    end

    -- Original architectural/gothic background geometry.
    local art = make("Frame", window, {
        Name = "GothicTracery",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
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

    for i = 0, 5 do
        local x = 24 + i * 153
        line(art, x, 177, 1, 360, 0, P.line, .78)
        line(art, x + 112, 177, 1, 360, 0, P.line, .78)
        line(art, x - 13, 132, 80, 1, -48, P.line, .65)
        line(art, x + 44, 132, 80, 1, 48, P.line, .65)
        line(art, x + 55, 102, 1, 435, 0, P.line, .86)
    end

    for _, x in ipairs({8, 840}) do
        line(art, x, 8, 1, 550, 0, P.line, .1)
    end

    for _, y in ipairs({8, 556}) do
        line(art, 8, y, 832, 1, 0, P.line, .1)
    end

    for _, cornerData in ipairs({
        {15, 15},
        {815, 15},
        {15, 533},
        {815, 533},
    }) do
        line(art, cornerData[1], cornerData[2], 20, 1, 0, P.accent, .15)
        line(art, cornerData[1], cornerData[2], 1, 20, 0, P.accent, .15)
        line(art, cornerData[1] + 5, cornerData[2] + 5, 8, 8, 45, P.line, .1)
    end

    line(art, 89, 83, 1, 17, 0, P.accent, .2)
    line(art, 85, 96, 8, 8, 45, P.accent, 0)
    line(art, 34, 89, 40, 1, 0, P.line, .2)
    line(art, 105, 89, 40, 1, 0, P.line, .2)

    -- Layered frame-within-frame ornamentation.
    for inset = 0, 2 do
        local offset = 13 + inset * 5
        local alpha = .52 + inset * .11

        line(art, offset, offset, 850 - offset * 2, 1, 0, P.line, alpha)
        line(art, offset, 566 - offset - 1, 850 - offset * 2, 1, 0, P.line, alpha)
        line(art, offset, offset, 1, 566 - offset * 2, 0, P.line, alpha)
        line(art, 850 - offset - 1, offset, 1, 566 - offset * 2, 0, P.line, alpha)
    end

    -- Crown detail above the content header.
    line(art, 262, 34, 126, 1, 0, P.line, .35)
    line(art, 462, 34, 126, 1, 0, P.line, .35)
    line(art, 388, 34, 37, 1, -42, P.accent, .18)
    line(art, 425, 34, 37, 1, 42, P.accent, .18)
    diamond(art, 421, 28, 8, P.accent, .05)
    diamond(art, 397, 31, 5, P.line, .28)
    diamond(art, 445, 31, 5, P.line, .28)

    -- Rose-window motif centered behind the main content.
    local roseX, roseY = 673, 287
    ring(art, roseX, roseY, 104, P.line, .78, 1)
    ring(art, roseX + 12, roseY + 12, 80, P.line, .82, 1)
    ring(art, roseX + 31, roseY + 31, 42, P.accent, .84, 1)

    for angle = 0, 150, 30 do
        line(
            art,
            roseX + 51,
            roseY + 17,
            1,
            70,
            angle,
            P.line,
            .84
        )
    end

    diamond(art, roseX + 48, roseY + 48, 8, P.accent, .72)

    -- Sidebar spine and ornamental joints.
    line(art, 18, 102, 1, 282, 0, P.line, .32)
    line(art, 164, 102, 1, 282, 0, P.line, .58)

    for i = 0, 6 do
        local y = 102 + i * 46
        diamond(art, 14, y - 3, 7, i == 0 and P.accent or P.line, .2)
        line(art, 22, y, 11, 1, 0, P.line, .5)
    end

    -- Footer rail and suspended center ornament.
    line(art, 186, 488, 642, 1, 0, P.line, .36)
    line(art, 186, 491, 642, 1, 0, P.line, .78)
    diamond(art, 505, 485, 7, P.accent, .18)
    line(art, 509, 492, 1, 27, 0, P.line, .72)
    diamond(art, 506, 518, 6, P.line, .42)

    -- Small repeating lancets behind the lower content field.
    for x = 205, 790, 73 do
        line(art, x, 453, 24, 1, -53, P.line, .86)
        line(art, x + 17, 453, 24, 1, 53, P.line, .86)
        line(art, x + 9, 439, 1, 37, 0, P.line, .9)
    end

    make("Frame", window, {
        Name = "ContentVeil",
        Position = UDim2.fromOffset(174, 12),
        Size = UDim2.fromOffset(662, 542),
        BackgroundColor3 = P.bg,
        BackgroundTransparency = .12,
        BorderSizePixel = 0,
    })

    -- Inner content frame with clipped-corner illusion.
    local innerFrame = make("Frame", window, {
        Name = "InnerContentFrame",
        Position = UDim2.fromOffset(181, 57),
        Size = UDim2.fromOffset(648, 435),
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
        {648, 0, -1, 1},
        {0, 435, 1, -1},
        {648, 435, -1, -1},
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

    text(header, title, 25, 15, 144, 39, 32, P.text, Enum.Font.Antique)
    text(window, subtitleText, 24, 57, 145, 24, 10, P.accent)

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
            Position = UDim2.fromOffset(x, y),
            Size = UDim2.fromOffset(width, 30),
            BackgroundColor3 = P.card,
            BackgroundTransparency = .1,
            BorderSizePixel = 0,
            Font = Enum.Font.Code,
            TextSize = 12,
            TextColor3 = P.text,
            AutoButtonColor = true,
        })

        make("UIStroke", object, {
            Color = P.line,
            Thickness = 1,
        })

        if callback then
            bind(object.Activated, callback)
        end

        return object
    end

    button(window, "—", 758, 18, 28, function()
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

    button(window, "×", 797, 18, 28, function()
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
                nav[key].TextColor3 = selected and P.bright or P.muted
                nav[key].BackgroundTransparency = selected and 0 or .6
            end
        end

        activeTab = name
        breadcrumb.Text = string.upper(name) .. "  /  " .. string.upper(productName)
    end

    -- No pause button. Only unload and show/hide remain.
    text(
        window,
        "F9  unload\nRShift  hide",
        24,
        431,
        142,
        52,
        11,
        P.muted
    )

    local sidebarStatus = text(
        window,
        "●  READY",
        24,
        398,
        142,
        24,
        11,
        P.bright
    )

    local footerLabel = text(window, "", 191, 495, 626, 55, 11, P.muted)

    local statusText = "READY"
    local footerPrimary = versionText
    local footerSecondary = ""

    local function updateFooter()
        sidebarStatus.Text = "●  " .. tostring(statusText)
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

        local page = make("ScrollingFrame", window, {
            Position = UDim2.fromOffset(190, 64),
            Size = UDim2.fromOffset(632, 421),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = P.accent,
            CanvasSize = UDim2.new(),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = #tabs == 0,
        })

        make("UIPadding", page, {
            PaddingLeft = UDim.new(0, 2),
            PaddingRight = UDim.new(0, 7),
            PaddingBottom = UDim.new(0, 8),
        })

        make("UIListLayout", page, {
            Padding = UDim.new(0, 9),
            SortOrder = Enum.SortOrder.LayoutOrder,
        })

        pages[name] = page

        local navButton = button(
            window,
            string.format("%s   %s", indexText, name),
            24,
            107 + (#tabs * 46),
            133,
            function()
                Window:Select(name)
            end
        )

        navButton.BackgroundTransparency = #tabs == 0 and 0 or .6
        navButton.TextColor3 = #tabs == 0 and P.bright or P.muted

        -- Sidebar tab ornament: rail, rune node, and trailing stitch.
        line(navButton, 4, 6, 1, 18, 0, P.accent, #tabs == 0 and .05 or .62)
        diamond(navButton, 10, 11, 7, P.line, .2)
        line(navButton, 118, 15, 8, 1, 0, P.line, .55)
        diamond(navButton, 126, 12, 5, P.line, .45)

        nav[name] = navButton

        local Tab = {
            Window = Window,
            Page = page,
            Name = name,
            Sections = {},
        }

        function Tab:Select()
            Window:Select(name)
        end

        function Tab:CreateSection(secCfg)
            secCfg = secCfg or {}

            local sectionTitle = tostring(secCfg.Title or "Section")
            if secCfg.Level ~= nil then
                sectionTitle = sectionTitle .. " · Level " .. tostring(secCfg.Level)
            end

            local card = make("Frame", page, {
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = P.card,
                BackgroundTransparency = .15,
                BorderSizePixel = 0,
            })

            make("UIStroke", card, {
                Color = P.line,
                Thickness = 1,
            })

            -- Ornamental card joints and double-line header rail.
            line(card, 8, 6, 38, 1, 0, P.line, .42)
            diamond(card, 4, 3, 7, P.accent, .18)
            line(card, 49, 6, 1, 10, 0, P.line, .72)

            local rightJoint = make("Frame", card, {
                AnchorPoint = Vector2.new(1, 0),
                Position = UDim2.new(1, -8, 0, 6),
                Size = UDim2.fromOffset(38, 1),
                BackgroundColor3 = P.line,
                BackgroundTransparency = .42,
                BorderSizePixel = 0,
            })

            local rightDiamond = make("Frame", card, {
                AnchorPoint = Vector2.new(1, 0),
                Position = UDim2.new(1, -4, 0, 3),
                Size = UDim2.fromOffset(7, 7),
                Rotation = 45,
                BackgroundColor3 = P.accent,
                BackgroundTransparency = .18,
                BorderSizePixel = 0,
            })

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

            local heading = text(
                card,
                string.upper(sectionTitle),
                0,
                0,
                588,
                22,
                15,
                P.bright,
                Enum.Font.Antique
            )
            heading.Size = UDim2.new(1, 0, 0, 22)

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
            }

            function Section:CreateToggle(control)
                control = control or {}

                local state = control.Default == true

                local row = make("Frame", card, {
                    Size = UDim2.new(1, 0, 0, 31),
                    BackgroundTransparency = 1,
                })

                local label = text(
                    row,
                    control.Title or "Toggle",
                    0,
                    0,
                    420,
                    30,
                    12
                )

                local toggleButton = button(row, "", 494, 1, 80, nil)
                toggleButton.AnchorPoint = Vector2.new(1, 0)
                toggleButton.Position = UDim2.new(1, 0, 0, 1)

                local Object = {}

                local function unlocked()
                    return not control.Requirement or control.Requirement() == true
                end

                local function set(value, fire)
                    if not unlocked() then
                        safeCall(control.OnLocked)
                        return
                    end

                    state = value == true
                    Object.Value.Current = state

                    if fire then
                        safeCall(control.Callback, state)
                    end
                end

                bind(toggleButton.Activated, function()
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

                table.insert(refresh, function()
                    local available = unlocked()

                    toggleButton.Text = not available and "LOCKED"
                        or state and "●  ON"
                        or "○  OFF"

                    toggleButton.TextColor3 = available and state and P.bright
                        or P.muted

                    toggleButton.AutoButtonColor = available
                    Object.Value.Current = state
                end)

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
                    330,
                    30,
                    12
                )

                local box = make("TextBox", row, {
                    Text = tostring(current),
                    PlaceholderText = tostring(control.Placeholder or ""),
                    Size = UDim2.new(0, 240, 0, 28),
                    Position = UDim2.new(1, -240, 0, 2),
                    BackgroundColor3 = P.bg,
                    BorderSizePixel = 0,
                    TextColor3 = P.bright,
                    PlaceholderColor3 = P.muted,
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

            function Section:CreateSlider(control)
                control = control or {}
                local range = control.Range or {0, 100}
                local suffix = tostring(control.Suffix or "")
                local current = tonumber(control.Default) or tonumber(range[1]) or 0
                local step = tonumber(control.Increment) or 1

                local row = make("Frame", card, {
                    Size = UDim2.new(1, 0, 0, 32),
                    BackgroundTransparency = 1,
                })

                local label = text(
                    row,
                    control.Title or "Slider",
                    0,
                    0,
                    330,
                    30,
                    12
                )

                local box = make("TextBox", row, {
                    Text = tostring(current) .. suffix,
                    Size = UDim2.new(0, 240, 0, 28),
                    Position = UDim2.new(1, -240, 0, 2),
                    BackgroundColor3 = P.bg,
                    BorderSizePixel = 0,
                    TextColor3 = P.bright,
                    Font = Enum.Font.Code,
                    TextSize = 12,
                    ClearTextOnFocus = false,
                })

                local Object = {}

                local function set(value, fire)
                    if type(value) == "string" and suffix ~= "" then
                        value = string.gsub(value, suffix, "")
                    end

                    value = tonumber(value)

                    if value == nil then
                        box.Text = tostring(current) .. suffix
                        return
                    end

                    value = math.clamp(
                        value,
                        tonumber(range[1]) or value,
                        tonumber(range[2]) or value
                    )

                    if step > 0 then
                        value = math.floor((value / step) + .5) * step
                    end

                    current = value
                    Object.Value.Current = current
                    box.Text = tostring(current) .. suffix

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

                Object.Name = proxy(control.Title or "Slider", function(value)
                    value = tostring(value)
                    Object.Name.Current = value
                    label.Text = value
                end)

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
                    420,
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

        table.insert(tabs, Tab)

        if #tabs == 1 then
            Window:Select(name)
        end

        return Tab
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
                    math.max(.3, (camera.ViewportSize.X - 30) / 850),
                    math.max(.3, (camera.ViewportSize.Y - 70) / 566)
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

    updateFooter()

    return Window
end

return Library
