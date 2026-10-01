--[[
    Leech UI Library
    Standalone Roblox UI framework inspired by the Leech interface.
]]

local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local Leech = {}
Leech.__index = Leech

local Theme = {
    Background = Color3.fromRGB(8, 7, 12),
    Panel = Color3.fromRGB(12, 10, 17),
    Panel2 = Color3.fromRGB(15, 12, 21),
    Stroke = Color3.fromRGB(91, 55, 121),
    StrokeSoft = Color3.fromRGB(54, 35, 72),
    Accent = Color3.fromRGB(183, 129, 219),
    Accent2 = Color3.fromRGB(132, 83, 166),
    Text = Color3.fromRGB(231, 220, 239),
    SubText = Color3.fromRGB(153, 134, 166),
    DimText = Color3.fromRGB(103, 88, 115),
    Danger = Color3.fromRGB(210, 98, 126),
    Good = Color3.fromRGB(184, 136, 214),
}

local function New(className, props, children)
    local obj = Instance.new(className)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    for _, child in ipairs(children or {}) do
        child.Parent = obj
    end
    return obj
end

local function Corner(radius)
    return New("UICorner", {CornerRadius = UDim.new(0, radius or 4)})
end

local function Stroke(color, thickness, transparency)
    return New("UIStroke", {
        Color = color or Theme.Stroke,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
    })
end

local function Pad(l, r, t, b)
    return New("UIPadding", {
        PaddingLeft = UDim.new(0, l or 0),
        PaddingRight = UDim.new(0, r or 0),
        PaddingTop = UDim.new(0, t or 0),
        PaddingBottom = UDim.new(0, b or 0),
    })
end

local function List(spacing)
    return New("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, spacing or 6),
    })
end

local function tween(obj, props, time)
    TweenService:Create(obj, TweenInfo.new(time or 0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

local function safeCallback(cb, ...)
    if typeof(cb) == "function" then
        task.spawn(function(...)
            local ok, err = pcall(cb, ...)
            if not ok then
                warn("[Leech UI] callback error:", err)
            end
        end, ...)
    end
end

local function makeSignalValue(initial)
    local holder = {Current = initial}
    function holder:Get()
        return self.Current
    end
    return holder
end

local function parentGui()
    if gethui then
        local ok, gui = pcall(gethui)
        if ok and gui then return gui end
    end
    return CoreGui
end

function Leech:CreateWindow(cfg)
    cfg = cfg or {}

    local Window = {
        Connections = {},
        Tabs = {},
        Paused = false,
        Visible = true,
        CurrentTab = nil,
        Counters = {parry = 0, dodge = 0, filter = 0, errors = 0},
    }

    local width = cfg.Width or 840
    local height = cfg.Height or 560
    local title = cfg.Title or "Leech"
    local subtitle = cfg.SubTitle or "DEEPWOKEN"
    local product = cfg.ProductName or "LEECH"
    local initialPage = cfg.CurrentPage or "HOME"
    local toggleKey = cfg.ToggleKey or Enum.KeyCode.RightShift
    local pauseKey = cfg.PauseKey or Enum.KeyCode.F6
    local unloadKey = cfg.UnloadKey or Enum.KeyCode.F9

    local Gui = New("ScreenGui", {
        Name = "LeechUI_" .. tostring(math.random(1000, 9999)),
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = parentGui(),
    })

    local Root = New("Frame", {
        Name = "Root",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(width, height),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Parent = Gui,
    }, {Corner(3), Stroke(Theme.StrokeSoft, 1, 0.1)})

    local Header = New("Frame", {
        Size = UDim2.new(1, 0, 0, 72),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Parent = Root,
    })

    New("TextLabel", {
        Position = UDim2.fromOffset(20, 14),
        Size = UDim2.fromOffset(145, 27),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Theme.Text,
        Font = Enum.Font.Code,
        TextSize = 24,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Header,
    })

    New("TextLabel", {
        Position = UDim2.fromOffset(20, 43),
        Size = UDim2.fromOffset(150, 17),
        BackgroundTransparency = 1,
        Text = "D E E P W O K E N",
        TextColor3 = Theme.Accent,
        Font = Enum.Font.Code,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Header,
    })

    local Breadcrumb = New("TextLabel", {
        Position = UDim2.fromOffset(186, 22),
        Size = UDim2.new(1, -320, 0, 24),
        BackgroundTransparency = 1,
        Text = initialPage .. "   /   " .. product,
        TextColor3 = Theme.Text,
        Font = Enum.Font.Code,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Header,
    })

    local Minimize = New("TextButton", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -51, 0, 14),
        Size = UDim2.fromOffset(30, 30),
        BackgroundColor3 = Theme.Panel,
        BorderSizePixel = 0,
        Text = "−",
        TextColor3 = Theme.SubText,
        Font = Enum.Font.Code,
        TextSize = 17,
        AutoButtonColor = false,
        Parent = Header,
    }, {Corner(2)})

    local Close = New("TextButton", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -14, 0, 14),
        Size = UDim2.fromOffset(30, 30),
        BackgroundColor3 = Theme.Panel,
        BorderSizePixel = 0,
        Text = "×",
        TextColor3 = Theme.Accent,
        Font = Enum.Font.Code,
        TextSize = 15,
        AutoButtonColor = false,
        Parent = Header,
    }, {Corner(2)})

    local Sidebar = New("Frame", {
        Position = UDim2.fromOffset(0, 72),
        Size = UDim2.new(0, 170, 1, -72),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Parent = Root,
    })

    local Nav = New("Frame", {
        Position = UDim2.fromOffset(18, 30),
        Size = UDim2.new(1, -36, 1, -150),
        BackgroundTransparency = 1,
        Parent = Sidebar,
    }, {List(8)})

    local PauseButton = New("TextButton", {
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 18, 1, -64),
        Size = UDim2.new(1, -36, 0, 38),
        BackgroundColor3 = Theme.Panel,
        BorderSizePixel = 0,
        Text = "  •  ACTIVE  /  PAUSE",
        TextColor3 = Theme.Text,
        Font = Enum.Font.Code,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutoButtonColor = false,
        Parent = Sidebar,
    }, {Corner(2)})

    local KeyHints = New("TextLabel", {
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 18, 1, -8),
        Size = UDim2.new(1, -36, 0, 46),
        BackgroundTransparency = 1,
        Text = "F6  pause\nF9  unload\nRShift  hide",
        TextColor3 = Theme.SubText,
        Font = Enum.Font.Code,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = Sidebar,
    })

    local Body = New("Frame", {
        Position = UDim2.fromOffset(170, 72),
        Size = UDim2.new(1, -170, 1, -112),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = Root,
    })

    local Bottom = New("Frame", {
        Position = UDim2.new(0, 170, 1, -40),
        Size = UDim2.new(1, -170, 0, 40),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Parent = Root,
    })

    local CounterLabel = New("TextLabel", {
        Position = UDim2.fromOffset(15, 4),
        Size = UDim2.new(1, -30, 0, 16),
        BackgroundTransparency = 1,
        Text = "PARRY 0000   DODGE 0000   FILTER 0000   ERRORS 0",
        TextColor3 = Theme.SubText,
        Font = Enum.Font.Code,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Bottom,
    })

    local StatusLabel = New("TextLabel", {
        Position = UDim2.fromOffset(15, 20),
        Size = UDim2.new(1, -30, 0, 16),
        BackgroundTransparency = 1,
        Text = "Ready",
        TextColor3 = Theme.DimText,
        Font = Enum.Font.Code,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Bottom,
    })

    New("Frame", {
        Position = UDim2.fromOffset(169, 72),
        Size = UDim2.new(0, 1, 1, -72),
        BackgroundColor3 = Theme.StrokeSoft,
        BorderSizePixel = 0,
        Parent = Root,
    })

    local dragging = false
    local dragStart, startPos

    table.insert(Window.Connections, Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Root.Position
        end
    end))

    table.insert(Window.Connections, UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Root.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end))

    table.insert(Window.Connections, UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end))

    local function updateCounters()
        CounterLabel.Text = string.format(
            "PARRY %04d   DODGE %04d   FILTER %04d   ERRORS %d",
            Window.Counters.parry or 0,
            Window.Counters.dodge or 0,
            Window.Counters.filter or 0,
            Window.Counters.errors or 0
        )
    end

    function Window:SetCounter(name, value)
        name = string.lower(tostring(name))
        if self.Counters[name] ~= nil then
            self.Counters[name] = tonumber(value) or 0
            updateCounters()
        end
    end

    function Window:SetStatus(text)
        StatusLabel.Text = tostring(text)
    end

    function Window:SetPaused(value)
        self.Paused = value == true
        PauseButton.Text = self.Paused and "  ○  PAUSED  /  RESUME" or "  •  ACTIVE  /  PAUSE"
        PauseButton.TextColor3 = self.Paused and Theme.DimText or Theme.Text
        StatusLabel.Text = self.Paused and "Paused" or "Ready"
    end

    function Window:ToggleVisible()
        self.Visible = not self.Visible
        Root.Visible = self.Visible
    end

    function Window:Destroy()
        for _, c in ipairs(self.Connections) do
            pcall(function() c:Disconnect() end)
        end
        if Gui then Gui:Destroy() end
    end

    table.insert(Window.Connections, PauseButton.MouseButton1Click:Connect(function()
        Window:SetPaused(not Window.Paused)
    end))

    table.insert(Window.Connections, Minimize.MouseButton1Click:Connect(function()
        Window:ToggleVisible()
    end))

    table.insert(Window.Connections, Close.MouseButton1Click:Connect(function()
        Window:Destroy()
    end))

    table.insert(Window.Connections, UIS.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == toggleKey then
            Window:ToggleVisible()
        elseif input.KeyCode == pauseKey then
            Window:SetPaused(not Window.Paused)
        elseif input.KeyCode == unloadKey then
            Window:Destroy()
        end
    end))

    function Window:CreateTab(tabCfg)
        tabCfg = tabCfg or {}
        local index = tostring(tabCfg.Index or string.format("%02d", #self.Tabs + 1))
        local titleText = tabCfg.Title or "Tab"

        local Tab = {
            Window = self,
            Sections = {},
            Title = titleText,
        }

        local NavButton = New("TextButton", {
            Size = UDim2.new(1, 0, 0, 38),
            BackgroundColor3 = Theme.Background,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
            Parent = Nav,
        }, {Corner(2)})

        local IndexLabel = New("TextLabel", {
            Position = UDim2.fromOffset(10, 0),
            Size = UDim2.fromOffset(30, 38),
            BackgroundTransparency = 1,
            Text = index,
            TextColor3 = Theme.DimText,
            Font = Enum.Font.Code,
            TextSize = 10,
            Parent = NavButton,
        })

        local NavTitle = New("TextLabel", {
            Position = UDim2.fromOffset(42, 0),
            Size = UDim2.new(1, -48, 1, 0),
            BackgroundTransparency = 1,
            Text = titleText,
            TextColor3 = Theme.SubText,
            Font = Enum.Font.Code,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = NavButton,
        })

        local Page = New("ScrollingFrame", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            CanvasSize = UDim2.fromOffset(0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.Stroke,
            Visible = false,
            Parent = Body,
        }, {Pad(16, 20, 0, 18), List(8)})

        function Tab:Select()
            for _, other in ipairs(Window.Tabs) do
                local active = other == self
                other.Page.Visible = active
                tween(other.NavButton, {BackgroundColor3 = active and Theme.Panel or Theme.Background}, 0.12)
                other.NavTitle.TextColor3 = active and Theme.Text or Theme.SubText
                other.IndexLabel.TextColor3 = active and Theme.Accent or Theme.DimText
            end
            Window.CurrentTab = self
            Breadcrumb.Text = string.upper(self.Title) .. "   /   " .. product
        end

        function Tab:CreateSection(secCfg)
            secCfg = secCfg or {}
            local Section = {}

            local Container = New("Frame", {
                Size = UDim2.new(1, -2, 0, 100),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = Theme.Panel,
                BorderSizePixel = 0,
                Parent = Page,
            }, {Stroke(Theme.Stroke, 1, 0.18), Pad(12, 12, 12, 12)})

            local Holder = New("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Parent = Container,
            }, {List(9)})

            local headText = tostring(secCfg.Title or "SECTION")
            if secCfg.Level ~= nil then
                headText = headText .. "  ·  LEVEL " .. tostring(secCfg.Level)
            end

            New("TextLabel", {
                Size = UDim2.new(1, 0, 0, 18),
                BackgroundTransparency = 1,
                Text = headText,
                TextColor3 = Theme.Accent,
                Font = Enum.Font.Code,
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Holder,
            })

            if secCfg.Description and secCfg.Description ~= "" then
                New("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 30),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    Text = tostring(secCfg.Description),
                    TextWrapped = true,
                    TextColor3 = Theme.SubText,
                    Font = Enum.Font.Code,
                    TextSize = 10,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Top,
                    Parent = Holder,
                })
            end

            local Controls = New("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Parent = Holder,
            }, {List(6)})

            local function rowBase(title, height)
                local Row = New("Frame", {
                    Size = UDim2.new(1, 0, 0, height or 34),
                    BackgroundTransparency = 1,
                    Parent = Controls,
                })
                local Label = New("TextLabel", {
                    Size = UDim2.new(0.58, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = title or "",
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.Code,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Row,
                })
                return Row, Label
            end

            function Section:CreateToggle(c)
                c = c or {}
                local state = c.Default == true
                local Row, Label = rowBase(c.Title or "Toggle", 34)

                local Toggle = New("TextButton", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.fromOffset(72, 26),
                    BackgroundColor3 = Theme.Background,
                    BorderSizePixel = 0,
                    Text = "",
                    AutoButtonColor = false,
                    Parent = Row,
                }, {Corner(2)})

                local Dot = New("TextLabel", {
                    Position = UDim2.fromOffset(8, 0),
                    Size = UDim2.fromOffset(12, 26),
                    BackgroundTransparency = 1,
                    Text = "•",
                    TextColor3 = Theme.Accent,
                    Font = Enum.Font.Code,
                    TextSize = 18,
                    Parent = Toggle,
                })

                local StateText = New("TextLabel", {
                    Position = UDim2.fromOffset(23, 0),
                    Size = UDim2.new(1, -27, 1, 0),
                    BackgroundTransparency = 1,
                    Text = state and "ON" or "OFF",
                    TextColor3 = state and Theme.Text or Theme.DimText,
                    Font = Enum.Font.Code,
                    TextSize = 10,
                    Parent = Toggle,
                })

                local Object = {
                    Value = makeSignalValue(state),
                    Name = makeSignalValue(c.Title or "Toggle"),
                }

                local function set(v, fire)
                    state = v == true
                    Object.Value.Current = state
                    StateText.Text = state and "ON" or "OFF"
                    StateText.TextColor3 = state and Theme.Text or Theme.DimText
                    Dot.TextColor3 = state and Theme.Accent or Theme.DimText
                    if fire then safeCallback(c.Callback, state) end
                end

                function Object.Value:Set(v)
                    set(v, true)
                end

                function Object.Name:Set(v)
                    self.Current = tostring(v)
                    Label.Text = self.Current
                end

                Toggle.MouseButton1Click:Connect(function()
                    set(not state, true)
                end)

                return Object
            end

            function Section:CreateButton(c)
                c = c or {}
                local Row = New("TextButton", {
                    Size = UDim2.new(1, 0, 0, 32),
                    BackgroundColor3 = Theme.Background,
                    BorderSizePixel = 0,
                    Text = tostring(c.Title or "Button"),
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.Code,
                    TextSize = 11,
                    AutoButtonColor = false,
                    Parent = Controls,
                }, {Corner(2), Stroke(Theme.StrokeSoft, 1, 0.25)})

                local Object = {Name = makeSignalValue(c.Title or "Button")}
                function Object.Name:Set(v)
                    self.Current = tostring(v)
                    Row.Text = self.Current
                end

                Row.MouseEnter:Connect(function()
                    tween(Row, {BackgroundColor3 = Theme.Panel2}, 0.12)
                end)
                Row.MouseLeave:Connect(function()
                    tween(Row, {BackgroundColor3 = Theme.Background}, 0.12)
                end)
                Row.MouseButton1Click:Connect(function()
                    safeCallback(c.Callback)
                end)

                return Object
            end

            function Section:CreateSlider(c)
                c = c or {}
                local range = c.Range or {0, 100}
                local min, max = tonumber(range[1]) or 0, tonumber(range[2]) or 100
                local increment = tonumber(c.Increment) or 1
                local suffix = tostring(c.Suffix or "")
                local value = math.clamp(tonumber(c.Default) or min, min, max)

                local Row, Label = rowBase(c.Title or "Slider", 40)

                local Box = New("TextBox", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.fromOffset(240, 28),
                    BackgroundColor3 = Theme.Background,
                    BorderSizePixel = 0,
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.Code,
                    TextSize = 10,
                    ClearTextOnFocus = false,
                    Text = tostring(value) .. suffix,
                    Parent = Row,
                }, {Corner(2)})

                local Object = {
                    Value = makeSignalValue(value),
                    Name = makeSignalValue(c.Title or "Slider"),
                }

                local function roundToInc(v)
                    return math.floor((v / increment) + 0.5) * increment
                end

                local function set(v, fire)
                    v = tonumber(v) or value
                    v = math.clamp(roundToInc(v), min, max)
                    value = v
                    Object.Value.Current = v
                    Box.Text = tostring(v) .. suffix
                    if fire then safeCallback(c.Callback, v) end
                end

                function Object.Value:Set(v)
                    set(v, true)
                end

                function Object.Name:Set(v)
                    self.Current = tostring(v)
                    Label.Text = self.Current
                end

                Box.FocusLost:Connect(function()
                    local raw = string.gsub(Box.Text, suffix, "")
                    set(tonumber(raw) or value, true)
                end)

                return Object
            end

            function Section:CreateDropdown(c)
                c = c or {}
                local options = c.Options or {}
                local multi = c.Multi == true
                local selected = c.Selected or {}
                if typeof(selected) ~= "table" then selected = {selected} end

                local Row, Label = rowBase(c.Title or "Dropdown", 40)

                local Button = New("TextButton", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.fromOffset(240, 28),
                    BackgroundColor3 = Theme.Background,
                    BorderSizePixel = 0,
                    Text = selected[1] and tostring(selected[1]) or "Select",
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.Code,
                    TextSize = 10,
                    AutoButtonColor = false,
                    Parent = Row,
                }, {Corner(2)})

                local Object = {
                    Value = makeSignalValue(selected),
                    Options = makeSignalValue(options),
                    Name = makeSignalValue(c.Title or "Dropdown"),
                }

                local cursor = 1
                for i, v in ipairs(options) do
                    if selected[1] == v then cursor = i break end
                end

                local function emit()
                    Object.Value.Current = selected
                    Button.Text = #selected > 0 and table.concat(selected, ", ") or "Select"
                    safeCallback(c.Callback, selected)
                end

                function Object.Value:Set(v)
                    if multi then
                        selected = typeof(v) == "table" and v or {v}
                    else
                        selected = {typeof(v) == "table" and v[1] or v}
                    end
                    emit()
                end

                function Object.Options:Set(v)
                    self.Current = v or {}
                    options = self.Current
                    cursor = 1
                end

                function Object.Name:Set(v)
                    self.Current = tostring(v)
                    Label.Text = self.Current
                end

                Button.MouseButton1Click:Connect(function()
                    if #options == 0 then return end
                    if multi then
                        cursor = cursor % #options + 1
                        local candidate = options[cursor]
                        local found = table.find(selected, candidate)
                        if found then
                            table.remove(selected, found)
                        else
                            table.insert(selected, candidate)
                        end
                    else
                        cursor = cursor % #options + 1
                        selected = {options[cursor]}
                    end
                    emit()
                end)

                return Object
            end

            function Section:CreateLabel(content)
                local Label = New("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 24),
                    BackgroundTransparency = 1,
                    Text = tostring(content or ""),
                    TextColor3 = Theme.SubText,
                    Font = Enum.Font.Code,
                    TextSize = 10,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Controls,
                })
                local Object = {Value = makeSignalValue(content or "")}
                function Object.Value:Set(v)
                    self.Current = tostring(v)
                    Label.Text = self.Current
                end
                return Object
            end

            function Section:CreateParagraph(c)
                c = c or {}
                local Wrap = New("Frame", {
                    Size = UDim2.new(1, 0, 0, 52),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    Parent = Controls,
                }, {List(3)})

                local T = New("TextLabel", {
                    Size = UDim2.new(1, 0, 0, c.Title and c.Title ~= "" and 18 or 0),
                    BackgroundTransparency = 1,
                    Text = tostring(c.Title or ""),
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.Code,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Visible = c.Title ~= nil and c.Title ~= "",
                    Parent = Wrap,
                })

                local C = New("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 30),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    Text = tostring(c.Content or ""),
                    TextWrapped = true,
                    TextColor3 = Theme.SubText,
                    Font = Enum.Font.Code,
                    TextSize = 10,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Top,
                    Parent = Wrap,
                })

                local Object = {
                    Title = makeSignalValue(c.Title or ""),
                    Content = makeSignalValue(c.Content or ""),
                }

                function Object.Title:Set(v)
                    self.Current = tostring(v)
                    T.Text = self.Current
                    T.Visible = self.Current ~= ""
                    T.Size = UDim2.new(1, 0, 0, T.Visible and 18 or 0)
                end

                function Object.Content:Set(v)
                    self.Current = tostring(v)
                    C.Text = self.Current
                end

                return Object
            end

            table.insert(self.Sections, Section)
            return Section
        end

        Tab.NavButton = NavButton
        Tab.NavTitle = NavTitle
        Tab.IndexLabel = IndexLabel
        Tab.Page = Page

        table.insert(self.Tabs, Tab)

        NavButton.MouseButton1Click:Connect(function()
            Tab:Select()
        end)

        if #self.Tabs == 1 then
            Tab:Select()
        end

        return Tab
    end

    return Window
end

return Leech
