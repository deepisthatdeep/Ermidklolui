local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/deepisthatdeep/Ermidklolui/main/Library.lua?rev=288182c"
))()

local Window = Library:CreateWindow({
    Title = "N/A",
    SubTitle = "N / A",
    ProductName = "N/A",
    CurrentPage = "N/A",
    Version = "N/A",
    PaletteFile = "GenericUI_palette_v2.json",
    AutoLoadPalette = true,
})

local General = Window:CreateTab({
    Title = "General",
    Index = 1,
})

local Player = Window:CreateTab({
    Title = "Player",
    Index = 2,
})

local World = Window:CreateTab({
    Title = "World",
    Index = 3,
})

local Visuals = Window:CreateTab({
    Title = "Visuals",
    Index = 4,
})

local Misc = Window:CreateTab({
    Title = "Misc",
    Index = 5,
})

local Settings = Window:CreateTab({
    Title = "Settings",
    Index = 6,
})

local GeneralSection = General:CreateSection({
    Title = "General",
    Description = "Primary feature controls.",
    Position = "Left",
})

GeneralSection:CreateToggle({
    Title = "Enabled",
    Default = false,
    Callback = function(value)
        print("Enabled:", value)
    end,
})

GeneralSection:CreateDropdown({
    Title = "Mode",
    Options = {"N/A"},
    Selected = {"N/A"},
    Callback = function(selected)
        print("Mode:", selected[1])
    end,
})

GeneralSection:CreateInput({
    Title = "Status",
    Default = "N/A",
    Placeholder = "N/A",
    Callback = function(value)
        print("Status:", value)
    end,
})

local GeneralTuning = General:CreateSection({
    Title = "Feature Tuning",
    Description = "Separate right-side groupbox for sliders and values.",
    Position = "Right",
})

GeneralTuning:CreateSlider({
    Title = "Strength",
    Range = {0, 100},
    Default = 50,
    Increment = 1,
    Suffix = "%",
    Callback = function(value)
        print("Strength:", value)
    end,
})

GeneralTuning:CreateSlider({
    Title = "Delay",
    Range = {0, 2},
    Default = 0.25,
    Increment = 0.05,
    Suffix = "s",
    Callback = function(value)
        print("Delay:", value)
    end,
})

local PlayerSection = Player:CreateSection({
    Title = "Movement",
    Description = "Feature toggles.",
    Position = "Left",
})

PlayerSection:CreateToggle({
    Title = "Walk Speed",
    Default = false,
    Callback = function(value)
        print("Walk Speed:", value)
    end,
})

local PlayerTuning = Player:CreateSection({
    Title = "Movement Values",
    Description = "Numeric tuning is kept in the right column.",
    Position = "Right",
})

PlayerTuning:CreateSlider({
    Title = "Walk Speed Value",
    Range = {0, 100},
    Default = 0,
    Increment = 1,
    Callback = function(value)
        print("Walk Speed Value:", value)
    end,
})

PlayerSection:CreateToggle({
    Title = "Jump Power",
    Default = false,
    Callback = function(value)
        print("Jump Power:", value)
    end,
})

PlayerTuning:CreateSlider({
    Title = "Jump Power Value",
    Range = {0, 150},
    Default = 0,
    Increment = 1,
    Callback = function(value)
        print("Jump Power Value:", value)
    end,
})

PlayerSection:CreateToggle({
    Title = "Fly",
    Default = false,
    Callback = function(value)
        print("Fly:", value)
    end,
})

PlayerSection:CreateToggle({
    Title = "Noclip",
    Default = false,
    Callback = function(value)
        print("Noclip:", value)
    end,
})

local WorldSection = World:CreateSection({
    Title = "World",
    Description = "N/A",
})

WorldSection:CreateToggle({
    Title = "Auto Interact",
    Default = false,
    Callback = function(value)
        print("Auto Interact:", value)
    end,
})

WorldSection:CreateToggle({
    Title = "Auto Collect",
    Default = false,
    Callback = function(value)
        print("Auto Collect:", value)
    end,
})

WorldSection:CreateDropdown({
    Title = "Target",
    Options = {"N/A"},
    Selected = {"N/A"},
    Callback = function(selected)
        print("Target:", selected[1])
    end,
})

WorldSection:CreateInput({
    Title = "Range",
    Default = "N/A",
    Placeholder = "N/A",
    Callback = function(value)
        print("Range:", value)
    end,
})

local VisualSection = Visuals:CreateSection({
    Title = "Visuals",
    Description = "N/A",
})

VisualSection:CreateToggle({
    Title = "ESP",
    Default = false,
    Callback = function(value)
        print("ESP:", value)
    end,
})

VisualSection:CreateToggle({
    Title = "Player Names",
    Default = false,
    Callback = function(value)
        print("Player Names:", value)
    end,
})

VisualSection:CreateToggle({
    Title = "Boxes",
    Default = false,
    Callback = function(value)
        print("Boxes:", value)
    end,
})

VisualSection:CreateToggle({
    Title = "Fullbright",
    Default = false,
    Callback = function(value)
        print("Fullbright:", value)
    end,
})

VisualSection:CreateSlider({
    Title = "Field Of View",
    Range = {0, 120},
    Default = 0,
    Increment = 1,
    Callback = function(value)
        print("Field Of View:", value)
    end,
})

local MiscSection = Misc:CreateSection({
    Title = "Miscellaneous",
    Description = "N/A",
})

MiscSection:CreateToggle({
    Title = "Anti AFK",
    Default = false,
    Callback = function(value)
        print("Anti AFK:", value)
    end,
})

MiscSection:CreateButton({
    Title = "Rejoin",
    Callback = function()
        Window:SetStatus("N/A")
        Window:SetFooter("N/A", "N/A")
    end,
})

MiscSection:CreateButton({
    Title = "Server Hop",
    Callback = function()
        Window:SetStatus("N/A")
        Window:SetFooter("N/A", "N/A")
    end,
})

MiscSection:CreateParagraph({
    Title = "Information",
    Content = "N/A",
})

local SettingsSection = Settings:CreateSection({
    Title = "Settings",
    Description = "General configuration.",
    Position = "Left",
})

SettingsSection:CreateKeybind({
    Title = "Keybind",
    Default = Enum.KeyCode.K,
    Callback = function(key)
        print("Keybind:", key.Name)
    end,
})

SettingsSection:CreateInput({
    Title = "Configuration",
    Default = "N/A",
    Placeholder = "N/A",
    Callback = function(value)
        print("Configuration:", value)
    end,
})

local ColorSection = Settings:CreateSection({
    Title = "Colors",
    Description = "Theme configuration.",
    Position = "Right",
})

local ColorControls = {}
local ColorRows = {
    {"Background", "bg"},
    {"Panel", "card"},
    {"Border", "line"},
    {"Primary Accent", "accent"},
    {"Secondary Accent", "accent2"},
    {"Glow", "glow"},
    {"Highlight Text", "bright"},
    {"Text", "text"},
    {"Muted Text", "muted"},
}

for _, row in ipairs(ColorRows) do
    local label, key = row[1], row[2]

    ColorControls[key] = ColorSection:CreateColorInput({
        Title = label,
        Default = Window:GetPaletteColor(key),
        Callback = function(color)
            Window:SetPaletteColor(key, color)
            Window:SetStatus("N/A")
        end,
    })
end

ColorSection:CreateButton({
    Title = "Save Colors",
    Callback = function()
        Window:SavePalette()
        Window:SetStatus("N/A")
        Window:SetFooter("N/A", "N/A")
    end,
})

ColorSection:CreateButton({
    Title = "Load Colors",
    Callback = function()
        local ok = Window:LoadPalette()

        if ok then
            for key, control in pairs(ColorControls) do
                control.Value:Set(Window:GetPaletteColor(key))
            end
        end

        Window:SetStatus("N/A")
        Window:SetFooter("N/A", "N/A")
    end,
})

ColorSection:CreateButton({
    Title = "Reset Colors",
    Callback = function()
        Window:ResetPalette()

        for key, control in pairs(ColorControls) do
            control.Value:Set(Window:GetPaletteColor(key))
        end

        Window:SetStatus("N/A")
        Window:SetFooter("N/A", "N/A")
    end,
})

SettingsSection:CreateButton({
    Title = "Save Settings",
    Callback = function()
        Window:SetStatus("N/A")
        Window:SetFooter("N/A", "N/A")
    end,
})

SettingsSection:CreateParagraph({
    Title = "Information",
    Content = "N/A",
})

Window:SetStatus("N/A")
Window:SetFooter("N/A", "N/A")
