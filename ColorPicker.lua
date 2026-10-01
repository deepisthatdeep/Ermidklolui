--[[
    Popup HSV color picker used by the UI library.
    Pure Roblox UI; no external image assets.
]]

local UserInputService = game:GetService("UserInputService")

local Picker = {}

local function new(className, parent, props)
    local object = Instance.new(className)
    for key, value in pairs(props or {}) do
        object[key] = value
    end
    object.Parent = parent
    return object
end

local function hex(color)
    return string.format(
        "#%02X%02X%02X",
        math.floor(color.R * 255 + .5),
        math.floor(color.G * 255 + .5),
        math.floor(color.B * 255 + .5)
    )
end

local function parseHex(value)
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

local function round(parent, radius)
    return new("UICorner", parent, {
        CornerRadius = UDim.new(0, radius or 6),
    })
end

local function stroke(parent, color, transparency, thickness)
    return new("UIStroke", parent, {
        Color = color,
        Transparency = transparency or 0,
        Thickness = thickness or 1,
    })
end

local function label(parent, value, props)
    props = props or {}
    return new("TextLabel", parent, {
        Position = props.Position or UDim2.new(),
        Size = props.Size or UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1,
        Text = tostring(value or ""),
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
        TextStrokeTransparency = .3,
        Font = props.Font or Enum.Font.Code,
        TextSize = props.TextSize or 12,
        TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        ZIndex = props.ZIndex or 103,
    })
end

function Picker.Create(cfg)
    cfg = cfg or {}

    local parent = assert(cfg.Parent, "ColorPicker Parent is required")
    local accent = cfg.Accent or Color3.fromRGB(255, 255, 255)
    local accent2 = cfg.Accent2 or Color3.fromRGB(255, 255, 255)
    local line = cfg.Line or Color3.fromRGB(255, 255, 255)
    local initial = parseHex(cfg.Color) or Color3.fromRGB(255, 255, 255)

    local connections = {}
    local alive = true
    local draggingSV = false
    local draggingHue = false

    local hue, saturation, value = Color3.toHSV(initial)
    local draft = initial

    local function bind(signal, fn)
        local connection = signal:Connect(fn)
        table.insert(connections, connection)
        return connection
    end

    local overlay = new("Frame", parent, {
        Name = "PalettePickerOverlay",
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = .52,
        BorderSizePixel = 0,
        ZIndex = 90,
    })

    local popup = new("Frame", overlay, {
        Name = "PalettePicker",
        AnchorPoint = Vector2.new(.5, .5),
        Position = UDim2.fromScale(.5, .5),
        Size = UDim2.fromOffset(348, 364),
        BackgroundColor3 = Color3.fromRGB(7, 10, 21),
        BackgroundTransparency = .01,
        BorderSizePixel = 0,
        ZIndex = 100,
    })
    round(popup, 10)
    stroke(popup, accent2, .08, 1)

    new("UIGradient", popup, {
        Rotation = 120,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(16, 22, 43)),
            ColorSequenceKeypoint.new(.48, Color3.fromRGB(7, 10, 21)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(22, 12, 37)),
        }),
    })

    local beam = new("Frame", popup, {
        Position = UDim2.fromOffset(12, 8),
        Size = UDim2.new(1, -24, 0, 2),
        BackgroundColor3 = accent2,
        BorderSizePixel = 0,
        ZIndex = 101,
    })

    new("UIGradient", beam, {
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(.18, 0),
            NumberSequenceKeypoint.new(.5, .15),
            NumberSequenceKeypoint.new(.82, 0),
            NumberSequenceKeypoint.new(1, 1),
        }),
    })

    label(popup, string.upper(tostring(cfg.Title or "COLOR")), {
        Position = UDim2.fromOffset(16, 13),
        Size = UDim2.fromOffset(274, 26),
        Font = Enum.Font.Antique,
        TextSize = 13,
    })

    local closeButton = new("TextButton", popup, {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -11, 0, 11),
        Size = UDim2.fromOffset(26, 26),
        BackgroundColor3 = Color3.fromRGB(13, 17, 32),
        BorderSizePixel = 0,
        Text = "×",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
        TextStrokeTransparency = .3,
        Font = Enum.Font.Code,
        TextSize = 14,
        AutoButtonColor = false,
        ZIndex = 104,
    })
    round(closeButton, 6)
    stroke(closeButton, line, .22, 1)

    local svSquare = new("Frame", popup, {
        Position = UDim2.fromOffset(16, 49),
        Size = UDim2.fromOffset(316, 166),
        BackgroundColor3 = Color3.fromHSV(hue, 1, 1),
        BorderSizePixel = 0,
        Active = true,
        ZIndex = 101,
    })
    round(svSquare, 6)
    stroke(svSquare, Color3.fromRGB(255, 255, 255), .65, 1)

    local saturationLayer = new("Frame", svSquare, {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        ZIndex = 102,
    })
    round(saturationLayer, 6)
    new("UIGradient", saturationLayer, {
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 1),
        }),
    })

    local valueLayer = new("Frame", svSquare, {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        ZIndex = 103,
    })
    round(valueLayer, 6)
    new("UIGradient", valueLayer, {
        Rotation = 90,
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(1, 0),
        }),
    })

    local svCursor = new("Frame", svSquare, {
        AnchorPoint = Vector2.new(.5, .5),
        Position = UDim2.fromScale(saturation, 1 - value),
        Size = UDim2.fromOffset(14, 14),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 106,
    })
    round(svCursor, 7)
    stroke(svCursor, Color3.fromRGB(255, 255, 255), 0, 2)

    local hueBar = new("Frame", popup, {
        Position = UDim2.fromOffset(16, 228),
        Size = UDim2.fromOffset(316, 12),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Active = true,
        ZIndex = 101,
    })
    round(hueBar, 6)

    new("UIGradient", hueBar, {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
            ColorSequenceKeypoint.new(1/6, Color3.fromHSV(1/6, 1, 1)),
            ColorSequenceKeypoint.new(2/6, Color3.fromHSV(2/6, 1, 1)),
            ColorSequenceKeypoint.new(3/6, Color3.fromHSV(3/6, 1, 1)),
            ColorSequenceKeypoint.new(4/6, Color3.fromHSV(4/6, 1, 1)),
            ColorSequenceKeypoint.new(5/6, Color3.fromHSV(5/6, 1, 1)),
            ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1)),
        }),
    })

    local hueCursor = new("Frame", hueBar, {
        AnchorPoint = Vector2.new(.5, .5),
        Position = UDim2.fromScale(hue, .5),
        Size = UDim2.fromOffset(8, 20),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        ZIndex = 106,
    })
    round(hueCursor, 4)
    stroke(hueCursor, Color3.fromRGB(0, 0, 0), .22, 1)

    local preview = new("Frame", popup, {
        Position = UDim2.fromOffset(16, 253),
        Size = UDim2.fromOffset(109, 39),
        BackgroundColor3 = draft,
        BorderSizePixel = 0,
        ZIndex = 101,
    })
    round(preview, 6)
    stroke(preview, Color3.fromRGB(255, 255, 255), .58, 1)

    local hexBox = new("TextBox", popup, {
        Position = UDim2.fromOffset(137, 253),
        Size = UDim2.fromOffset(195, 39),
        BackgroundColor3 = Color3.fromRGB(12, 16, 30),
        BackgroundTransparency = .01,
        BorderSizePixel = 0,
        Text = hex(draft),
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
        TextStrokeTransparency = .3,
        Font = Enum.Font.Code,
        TextSize = 12,
        ClearTextOnFocus = false,
        ZIndex = 103,
    })
    round(hexBox, 6)
    stroke(hexBox, line, .22, 1)

    local selectButton = new("TextButton", popup, {
        Position = UDim2.fromOffset(16, 305),
        Size = UDim2.fromOffset(316, 42),
        BackgroundColor3 = accent2,
        BackgroundTransparency = .13,
        BorderSizePixel = 0,
        Text = "SELECT",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
        TextStrokeTransparency = .2,
        Font = Enum.Font.Code,
        TextSize = 12,
        AutoButtonColor = false,
        ZIndex = 103,
    })
    round(selectButton, 7)
    stroke(selectButton, Color3.fromRGB(255, 255, 255), .62, 1)

    local function render()
        draft = Color3.fromHSV(hue, saturation, value)
        svSquare.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
        svCursor.Position = UDim2.fromScale(saturation, 1 - value)
        hueCursor.Position = UDim2.fromScale(hue, .5)
        preview.BackgroundColor3 = draft
        hexBox.Text = hex(draft)

        if typeof(cfg.OnPreview) == "function" then
            task.spawn(cfg.OnPreview, draft, hex(draft))
        end
    end

    local function fromSV(input)
        local width = svSquare.AbsoluteSize.X
        local height = svSquare.AbsoluteSize.Y
        if width <= 0 or height <= 0 then
            return
        end

        saturation = math.clamp(
            (input.Position.X - svSquare.AbsolutePosition.X) / width,
            0,
            1
        )

        value = 1 - math.clamp(
            (input.Position.Y - svSquare.AbsolutePosition.Y) / height,
            0,
            1
        )

        render()
    end

    local function fromHue(input)
        local width = hueBar.AbsoluteSize.X
        if width <= 0 then
            return
        end

        hue = math.clamp(
            (input.Position.X - hueBar.AbsolutePosition.X) / width,
            0,
            1
        )

        render()
    end

    local Object = {}

    function Object:Destroy(cancelled)
        if not alive then
            return
        end

        alive = false

        for _, connection in ipairs(connections) do
            pcall(function()
                connection:Disconnect()
            end)
        end

        table.clear(connections)

        if overlay then
            overlay:Destroy()
        end

        if cancelled and typeof(cfg.OnCancel) == "function" then
            task.spawn(cfg.OnCancel)
        end
    end

    function Object:GetColor()
        return draft
    end

    function Object:GetHex()
        return hex(draft)
    end

    bind(closeButton.Activated, function()
        Object:Destroy(true)
    end)

    bind(selectButton.Activated, function()
        if typeof(cfg.OnSelect) == "function" then
            task.spawn(cfg.OnSelect, draft, hex(draft))
        end
        Object:Destroy(false)
    end)

    bind(svSquare.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            draggingSV = true
            fromSV(input)
        end
    end)

    bind(hueBar.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            draggingHue = true
            fromHue(input)
        end
    end)

    bind(UserInputService.InputChanged, function(input)
        if draggingSV and (
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        ) then
            fromSV(input)
        elseif draggingHue and (
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        ) then
            fromHue(input)
        end
    end)

    bind(UserInputService.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            draggingSV = false
            draggingHue = false
        end
    end)

    bind(hexBox.FocusLost, function()
        local parsed = parseHex(hexBox.Text)
        if parsed then
            draft = parsed
            hue, saturation, value = Color3.toHSV(parsed)
            render()
        else
            hexBox.Text = hex(draft)
        end
    end)

    render()
    return Object
end

return Picker

