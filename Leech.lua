--[[
    Leech UI Library
    UI extracted and generalized from the original Leech_Combat.lua HUD.
    The visual/layout code intentionally keeps the original Leech palette,
    gothic tracery, dimensions, navigation, cards, controls, scaling, and hotkeys.
]]

local Players = game:GetService("Players")
local Input = game:GetService("UserInputService")

local Player = Players.LocalPlayer

local Leech = {}
Leech.__index = Leech

local P = {
    bg = Color3.fromRGB(8, 7, 12),
    card = Color3.fromRGB(18, 12, 25),
    line = Color3.fromRGB(77, 48, 101),
    accent = Color3.fromRGB(145, 99, 182),
    bright = Color3.fromRGB(211, 187, 229),
    text = Color3.fromRGB(234, 225, 237),
    muted = Color3.fromRGB(167, 149, 179),
}

local function make(class, parent, props)
    local obj = Instance.new(class)
    for key, value in pairs(props or {}) do
        obj[key] = value
    end
    obj.Parent = parent
    return obj
end

local function connect(bucket, signal, fn)
    local c = signal:Connect(fn)
    table.insert(bucket, c)
    return c
end

local function call(fn, ...)
    if typeof(fn) ~= "function" then
        return
    end
    local args = table.pack(...)
    task.spawn(function()
        local ok, err = pcall(fn, table.unpack(args, 1, args.n))
        if not ok then
            warn("[Leech UI] callback error:", err)
        end
    end)
end

local function proxy(initial, setter)
    local object = {Current = initial}

    function object:Get()
        return self.Current
    end

    function object:Set(value)
        setter(value)
    end

    return object
end

function Leech:CreateWindow(cfg)
    cfg = cfg or {}

    local Window = {
        alive = true,
        connections = {},
        tabs = {},
        refresh = {},
        paused = false,
        activeTab = nil,
        footer = {
            parry = 0,
            dodge = 0,
            filter = 0,
            errors = 0,
            line1 = "Ready",
            line2 = "",
        },
    }

    local parent = cfg.Parent or Player:WaitForChild("PlayerGui")
    local title = cfg.Title or "LEECH"
    local gameTitle = cfg.SubTitle or "D E E P W O K E N"
    local productName = cfg.ProductName or "LEECH"
    local initialPage = string.upper(cfg.CurrentPage or "COMBAT")

    local gui = make("ScreenGui", parent, {
        Name = cfg.Name or "LeechUI",
        ResetOnSpawn = false,
        IgnoreGuiInset = false,
        Enabled = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })
    Window.Gui = gui

    local window = make("Frame", gui, {
        Size = UDim2.fromOffset(850, 566),
        Position = UDim2.new(.5, -425, .5, -283),
        BackgroundColor3 = P.bg,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Active = true,
    })
    Window.Frame = window

    make("UIStroke", window, {
        Color = P.line,
        Thickness = 1,
    })

    local scale = make("UIScale", window, {Scale = 1})
    Window.Scale = scale

    local function text(parentObject, value, x, y, w, h, size, color, font)
        return make("TextLabel", parentObject, {
            Text = value,
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

    -- Native gothic tracery from the original Leech HUD.
    local art = make("Frame", window, {
        Name = "GothicTracery",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
    })

    local function line(parentObject, x, y, w, h, angle, color, opacity)
        return make("Frame", parentObject, {
            Position = UDim2.fromOffset(x, y),
            Size = UDim2.fromOffset(w, h),
            Rotation = angle or 0,
            BackgroundColor3 = color or P.line,
            BackgroundTransparency = opacity or 0,
            BorderSizePixel = 0,
        })
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

    for _, corner in ipairs({
        {15, 15},
        {815, 15},
        {15, 533},
        {815, 533},
    }) do
        line(art, corner[1], corner[2], 20, 1, 0, P.accent, .15)
        line(art, corner[1], corner[2], 1, 20, 0, P.accent, .15)
        line(art, corner[1] + 5, corner[2] + 5, 8, 8, 45, P.line, .1)
    end

    line(art, 89, 83, 1, 17, 0, P.accent, .2)
    line(art, 85, 96, 8, 8, 45, P.accent, 0)
    line(art, 34, 89, 40, 1, 0, P.line, .2)
    line(art, 105, 89, 40, 1, 0, P.line, .2)

    make("Frame", window, {
        Name = "ContentVeil",
        Position = UDim2.fromOffset(174, 12),
        Size = UDim2.fromOffset(662, 542),
        BackgroundColor3 = P.bg,
        BackgroundTransparency = .12,
        BorderSizePixel = 0,
    })

    local header = make("Frame", window, {
        Size = UDim2.fromOffset(746, 62),
        BackgroundTransparency = 1,
        Active = true,
    })

    text(header, title, 25, 15, 144, 39, 32, P.text, Enum.Font.Antique)
    text(window, gameTitle, 24, 57, 145, 24, 10, P.accent)

    local subtitle = text(
        header,
        initialPage .. "  /  " .. productName,
        193,
        20,
        490,
        25,
        13,
        P.bright
    )
    Window.Breadcrumb = subtitle

    local function button(parentObject, buttonTitle, x, y, w, fn)
        local b = make("TextButton", parentObject, {
            Text = buttonTitle,
            Position = UDim2.fromOffset(x, y),
            Size = UDim2.fromOffset(w, 30),
            BackgroundColor3 = P.card,
            BackgroundTransparency = .1,
            BorderSizePixel = 0,
            Font = Enum.Font.Code,
            TextSize = 12,
            TextColor3 = P.text,
            AutoButtonColor = true,
        })
        make("UIStroke", b, {
            Color = P.line,
            Thickness = 1,
        })
        connect(Window.connections, b.Activated, function()
            call(fn)
        end)
        return b
    end

    button(window, "—", 758, 18, 28, function()
        gui.Enabled = false
    end)

    button(window, "×", 797, 18, 28, function()
        Window:Destroy()
    end)

    local drag, start, origin

    connect(Window.connections, header.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            drag = input
            start = input.Position
            origin = window.Position
        end
    end)

    connect(Window.connections, Input.InputChanged, function(input)
        if drag and (
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input == drag
        ) then
            local delta = input.Position - start
            window.Position = UDim2.new(
                origin.X.Scale,
                origin.X.Offset + delta.X,
                origin.Y.Scale,
                origin.Y.Offset + delta.Y
            )
        end
    end)

    connect(Window.connections, Input.InputEnded, function(input)
        if input == drag then
            drag = nil
        end
    end)

    local pages = {}
    local nav = {}

    Window.Pages = pages
    Window.Nav = nav

    function Window:Select(name)
        if not pages[name] then
            return
        end

        for key, page in pairs(pages) do
            page.Visible = key == name
            nav[key].TextColor3 = key == name and P.bright or P.muted
            nav[key].BackgroundTransparency = key == name and 0 or .6
        end

        self.activeTab = name
        subtitle.Text = string.upper(name) .. "  /  " .. productName
    end

    local pause = button(window, "", 24, 405, 133, function()
        Window:SetPaused(not Window.paused)
    end)
    Window.PauseButton = pause

    text(
        window,
        "F6  pause\nF9  unload\nRShift  hide",
        24,
        452,
        142,
        70,
        11,
        P.muted
    )

    local footer = text(window, "", 191, 495, 626, 55, 11, P.muted)
    Window.FooterLabel = footer

    local function updateFooter()
        footer.Text = string.format(
            "PARRY %04d   DODGE %04d   FILTER %04d   ERRORS %d\n%s\n%s",
            tonumber(Window.footer.parry) or 0,
            tonumber(Window.footer.dodge) or 0,
            tonumber(Window.footer.filter) or 0,
            tonumber(Window.footer.errors) or 0,
            tostring(Window.footer.line1 or ""):sub(1, 90),
            tostring(Window.footer.line2 or ""):sub(1, 90)
        )
    end

    function Window:SetFooter(data)
        data = data or {}
        for key, value in pairs(data) do
            if self.footer[key] ~= nil then
                self.footer[key] = value
            end
        end
        updateFooter()
    end

    function Window:SetCounter(name, value)
        name = string.lower(tostring(name))
        if self.footer[name] ~= nil then
            self.footer[name] = tonumber(value) or 0
            updateFooter()
        end
    end

    function Window:SetStatus(line1, line2)
        self.footer.line1 = line1 or ""
        if line2 ~= nil then
            self.footer.line2 = line2
        end
        updateFooter()
    end

    function Window:SetPaused(value)
        self.paused = value == true
        pause.Text = self.paused and "○  PAUSED / RUN" or "●  ACTIVE / PAUSE"
        pause.TextColor3 = self.paused and P.muted or P.bright
        call(cfg.OnPauseChanged, self.paused)
    end

    function Window:SetVisible(value)
        gui.Enabled = value == true
    end

    function Window:ToggleVisible()
        gui.Enabled = not gui.Enabled
    end

    function Window:Destroy()
        if not self.alive then
            return
        end
        self.alive = false

        call(cfg.OnUnload)

        for _, c in ipairs(self.connections) do
            pcall(function()
                c:Disconnect()
            end)
        end
        table.clear(self.connections)

        if gui then
            gui:Destroy()
        end
    end

    function Window:CreateTab(tabCfg)
        tabCfg = tabCfg or {}

        local name = tabCfg.Title or ("Tab " .. tostring(#self.tabs + 1))
        local index = tabCfg.Index

        if index == nil then
            index = string.format("%02d", #self.tabs + 1)
        else
            local numericIndex = tonumber(index)
            if numericIndex then
                index = string.format("%02d", numericIndex)
            else
                index = tostring(index)
            end
        end

        local page = make("ScrollingFrame", window, {
            Position = UDim2.fromOffset(190, 64),
            Size = UDim2.fromOffset(632, 421),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = P.accent,
            CanvasSize = UDim2.new(),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = #self.tabs == 0,
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

        local navButton = button(
            window,
            string.format("%s   %s", index, name),
            24,
            107 + (#self.tabs * 46),
            133,
            function()
                Window:Select(name)
            end
        )

        pages[name] = page
        nav[name] = navButton

        local Tab = {
            Window = self,
            Page = page,
            Name = name,
            Sections = {},
        }

        function Tab:Select()
            Window:Select(name)
        end

        function Tab:CreateSection(secCfg)
            secCfg = secCfg or {}

            local sectionTitle = secCfg.Title or "Section"
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

            if secCfg.Description then
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

            function Section:CreateToggle(c)
                c = c or {}

                local state = c.Default == true
                local row = make("Frame", card, {
                    Size = UDim2.new(1, 0, 0, 31),
                    BackgroundTransparency = 1,
                })

                local label = text(
                    row,
                    c.Title or "Toggle",
                    0,
                    0,
                    420,
                    30,
                    12
                )

                local b = button(row, "", 494, 1, 80, function()
                    if c.Requirement and not c.Requirement() then
                        call(c.OnLocked)
                        return
                    end

                    state = not state
                    call(c.Callback, state)
                end)

                b.AnchorPoint = Vector2.new(1, 0)
                b.Position = UDim2.new(1, 0, 0, 1)

                local object = {}

                object.Value = proxy(state, function(value)
                    state = value == true
                    object.Value.Current = state
                    call(c.Callback, state)
                end)

                object.Name = proxy(c.Title or "Toggle", function(value)
                    value = tostring(value)
                    object.Name.Current = value
                    label.Text = value
                end)

                table.insert(Window.refresh, function()
                    local unlocked = not c.Requirement or c.Requirement()
                    b.Text = not unlocked and "LOCKED"
                        or state and "●  ON"
                        or "○  OFF"
                    b.TextColor3 = unlocked and state and P.bright or P.muted
                    b.AutoButtonColor = unlocked
                    object.Value.Current = state
                end)

                return object
            end

            function Section:CreateDropdown(c)
                c = c or {}

                local values = c.Options or {}
                local selected = c.Selected
                if typeof(selected) == "table" then
                    selected = selected[1]
                end
                if selected == nil then
                    selected = values[1]
                end

                local b = button(card, "", 0, 0, 588, function()
                    if #values == 0 then
                        return
                    end
                    local currentIndex = table.find(values, selected) or 0
                    selected = values[(currentIndex % #values) + 1]
                    call(c.Callback, {selected})
                end)
                b.Size = UDim2.new(1, 0, 0, 31)

                local object = {}

                object.Value = proxy(selected, function(value)
                    if typeof(value) == "table" then
                        value = value[1]
                    end
                    selected = value
                    object.Value.Current = selected
                    call(c.Callback, {selected})
                end)

                object.Options = proxy(values, function(value)
                    values = value or {}
                    object.Options.Current = values
                    if selected ~= nil and not table.find(values, selected) then
                        selected = values[1]
                        object.Value.Current = selected
                    end
                end)

                object.Name = proxy(c.Title or "Dropdown", function(value)
                    object.Name.Current = tostring(value)
                end)

                table.insert(Window.refresh, function()
                    b.Text = tostring(object.Name.Current)
                        .. ": "
                        .. tostring(selected or "—")
                        .. "   ›"
                    object.Value.Current = selected
                end)

                return object
            end

            function Section:CreateInput(c)
                c = c or {}

                local value = c.Default
                if value == nil then
                    value = ""
                end

                local row = make("Frame", card, {
                    Size = UDim2.new(1, 0, 0, 32),
                    BackgroundTransparency = 1,
                })

                local label = text(
                    row,
                    c.Title or "Input",
                    0,
                    0,
                    330,
                    30,
                    12
                )

                local box = make("TextBox", row, {
                    Text = tostring(value),
                    Size = UDim2.new(0, 240, 0, 28),
                    Position = UDim2.new(1, -240, 0, 2),
                    BackgroundColor3 = P.bg,
                    BorderSizePixel = 0,
                    TextColor3 = P.bright,
                    Font = Enum.Font.Code,
                    TextSize = 12,
                    ClearTextOnFocus = false,
                })

                local object = {}

                local function parse(raw)
                    if c.Numeric then
                        return tonumber(raw)
                    end
                    return raw
                end

                local function set(newValue, fire)
                    local parsed = parse(newValue)
                    if parsed == nil and c.Numeric then
                        box.Text = tostring(value)
                        return
                    end

                    if c.Min ~= nil and tonumber(parsed) then
                        parsed = math.max(c.Min, parsed)
                    end
                    if c.Max ~= nil and tonumber(parsed) then
                        parsed = math.min(c.Max, parsed)
                    end

                    value = parsed
                    object.Value.Current = value
                    box.Text = tostring(value)

                    if fire then
                        call(c.Callback, value)
                    end
                end

                object.Value = proxy(value, function(newValue)
                    set(newValue, true)
                end)

                object.Name = proxy(c.Title or "Input", function(newValue)
                    newValue = tostring(newValue)
                    object.Name.Current = newValue
                    label.Text = newValue
                end)

                connect(Window.connections, box.FocusLost, function()
                    set(box.Text, true)
                end)

                return object
            end

            function Section:CreateSlider(c)
                c = c or {}
                local range = c.Range or {0, 100}

                return self:CreateInput({
                    Title = c.Title or "Slider",
                    Default = c.Default ~= nil and c.Default or range[1],
                    Numeric = true,
                    Min = range[1],
                    Max = range[2],
                    Callback = c.Callback,
                })
            end

            function Section:CreateButton(c)
                c = c or {}

                local b = button(card, c.Title or "Button", 0, 0, 588, function()
                    call(c.Callback)
                end)
                b.Size = UDim2.new(1, 0, 0, 30)

                local object = {}
                object.Name = proxy(c.Title or "Button", function(value)
                    value = tostring(value)
                    object.Name.Current = value
                    b.Text = value
                end)

                return object
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

                local object = {}
                object.Value = proxy(content or "", function(value)
                    value = tostring(value)
                    object.Value.Current = value
                    label.Text = value
                end)

                return object
            end

            function Section:CreateParagraph(c)
                c = c or {}

                local wrap = make("Frame", card, {
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                })

                make("UIListLayout", wrap, {
                    Padding = UDim.new(0, 3),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                })

                local titleLabel
                if c.Title and c.Title ~= "" then
                    titleLabel = text(
                        wrap,
                        tostring(c.Title),
                        0,
                        0,
                        588,
                        22,
                        12,
                        P.bright,
                        Enum.Font.Antique
                    )
                    titleLabel.Size = UDim2.new(1, 0, 0, 22)
                end

                local contentLabel = text(
                    wrap,
                    tostring(c.Content or ""),
                    0,
                    0,
                    588,
                    32,
                    11,
                    P.muted
                )
                contentLabel.Size = UDim2.new(1, 0, 0, 32)
                contentLabel.AutomaticSize = Enum.AutomaticSize.Y

                local object = {}

                object.Title = proxy(c.Title or "", function(value)
                    value = tostring(value)
                    object.Title.Current = value

                    if titleLabel then
                        titleLabel.Text = value
                    end
                end)

                object.Content = proxy(c.Content or "", function(value)
                    value = tostring(value)
                    object.Content.Current = value
                    contentLabel.Text = value
                end)

                return object
            end

            table.insert(Tab.Sections, Section)
            return Section
        end

        table.insert(self.tabs, Tab)

        if #self.tabs == 1 then
            self:Select(name)
        end

        return Tab
    end

    connect(Window.connections, Input.InputBegan, function(input, processed)
        if processed or Input:GetFocusedTextBox() then
            return
        end

        local pauseKey = cfg.PauseKey or Enum.KeyCode.F6
        local unloadKey = cfg.UnloadKey or Enum.KeyCode.F9
        local toggleKey = cfg.ToggleKey or Enum.KeyCode.RightShift

        if input.KeyCode == pauseKey then
            Window:SetPaused(not Window.paused)
        elseif input.KeyCode == unloadKey then
            Window:Destroy()
        elseif input.KeyCode == toggleKey and gui then
            gui.Enabled = not gui.Enabled
        end
    end)

    Window:SetPaused(false)
    updateFooter()

    task.spawn(function()
        while task.wait(.2) do
            if not Window.alive then
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

            for _, fn in ipairs(Window.refresh) do
                local ok, err = pcall(fn)
                if not ok then
                    warn("[Leech UI] refresh error:", err)
                end
            end

            pause.Text = Window.paused and "○  PAUSED / RUN" or "●  ACTIVE / PAUSE"
            pause.TextColor3 = Window.paused and P.muted or P.bright
            updateFooter()
        end
    end)

    return Window
end

return Leech
