local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/deepisthatdeep/Ermidklolui/main/Library.lua?rev=2ff2be4"
))()

local Window = Library:CreateWindow({
    Title = "AETHER",
    SubTitle = "S P E C T R A L",
    ProductName = "PRISM",
    CurrentPage = "OVERVIEW",
    Version = "NIGHTFALL BUILD",
})

local Main = Window:CreateTab({
    Title = "Overview",
    Index = 1,
})

local Combat = Window:CreateTab({
    Title = "Signal",
    Index = 2,
})

local Automation = Window:CreateTab({
    Title = "Flow",
    Index = 3,
})

local Targeting = Window:CreateTab({
    Title = "Focus",
    Index = 4,
})

local Vision = Window:CreateTab({
    Title = "Optics",
    Index = 5,
})

local Settings = Window:CreateTab({
    Title = "Settings",
    Index = 6,
})

local General = Main:CreateSection({
    Title = "General",
    Level = 1,
    Description = "Primary controls using the original gothic card layout.",
})

General:CreateToggle({
    Title = "Enabled",
    Default = true,
    Callback = function(value)
        Window:SetStatus(value and "READY" or "IDLE")
        print("Enabled:", value)
    end,
})

General:CreateSlider({
    Title = "Intensity",
    Range = {0, 100},
    Default = 50,
    Increment = 1,
    Suffix = "%",
    Callback = function(value)
        print("Intensity:", value)
    end,
})

General:CreateDropdown({
    Title = "Mode",
    Options = {"Balanced", "Fast", "Safe"},
    Selected = {"Balanced"},
    Callback = function(selected)
        print("Mode:", selected[1])
    end,
})

local Runtime = Main:CreateSection({
    Title = "Runtime",
    Description = "Status text, progress, notifications, and actions.",
})

local RuntimeLabel = Runtime:CreateLabel("Runtime: ready")

local Progress = Runtime:CreateProgress({
    Title = "Task progress",
    Default = 0.35,
})

Runtime:CreateButton({
    Title = "Advance progress",
    Callback = function()
        local nextValue = math.clamp(Progress.Value:Get() + 0.1, 0, 1)
        Progress.Value:Set(nextValue)
        RuntimeLabel.Value:Set("Runtime: progress updated")
    end,
})

Runtime:CreateButton({
    Title = "Show notification",
    Callback = function()
        Window:Notify({
            Title = "Notice",
            Content = "This notification uses the same dark bordered style.",
            Duration = 3,
        })
    end,
})

local CombatSection = Combat:CreateSection({
    Title = "Combat controls",
    Level = 1,
    Description = "UI-only example controls. Connect callbacks to your own code.",
})

CombatSection:CreateToggle({
    Title = "Primary feature",
    Default = false,
    Callback = function(value)
        print("Primary feature:", value)
    end,
})

CombatSection:CreateInput({
    Title = "Range",
    Default = 120,
    Numeric = true,
    Min = 0,
    Max = 1000,
    Callback = function(value)
        print("Range:", value)
    end,
})

CombatSection:CreateSeparator({
    Title = "Advanced",
})

CombatSection:CreateDropdown({
    Title = "Targets",
    Options = {"Players", "NPCs", "Projectiles"},
    Selected = {"Players", "NPCs"},
    Multi = true,
    Callback = function(selected)
        print("Selected:", table.concat(selected, ", "))
    end,
})

local AutomationSection = Automation:CreateSection({
    Title = "Automation",
    Description = "Example automation controls only.",
})

AutomationSection:CreateToggle({
    Title = "Automatic action",
    Default = false,
    Callback = function(value)
        print("Automatic action:", value)
    end,
})

AutomationSection:CreateSlider({
    Title = "Delay",
    Range = {0, 2},
    Default = 0.2,
    Increment = 0.05,
    Suffix = "s",
    Callback = function(value)
        print("Delay:", value)
    end,
})

local TargetSection = Targeting:CreateSection({
    Title = "Selection",
    Description = "Target and filtering UI examples.",
})

TargetSection:CreateDropdown({
    Title = "Priority",
    Options = {"Distance", "FOV", "Manual"},
    Selected = {"Distance"},
    Callback = function(selected)
        print("Priority:", selected[1])
    end,
})

TargetSection:CreateInput({
    Title = "Maximum distance",
    Default = 160,
    Numeric = true,
    Min = 0,
    Max = 1000,
    Callback = function(value)
        print("Maximum distance:", value)
    end,
})

local VisionSection = Vision:CreateSection({
    Title = "Display",
    Description = "Visual settings and status display.",
})

VisionSection:CreateToggle({
    Title = "Show overlay",
    Default = true,
    Callback = function(value)
        print("Show overlay:", value)
    end,
})

VisionSection:CreateParagraph({
    Title = "Design",
    Content = "The interface uses layered glass, orbital geometry, refractive latticework, luminous switches, white typography, and animated spectral accents.",
})

local SettingsSection = Settings:CreateSection({
    Title = "Configuration",
})

local ColorSection = Settings:CreateSection({
    Title = "Color Matrix",
    Description = "Edit every interface color manually with hex values. Saved colors load automatically next time.",
})

local ColorControls = {}
local ColorRows = {
    {"Background", "bg"},
    {"Panel", "card"},
    {"Border", "line"},
    {"Primary accent", "accent"},
    {"Secondary accent", "accent2"},
    {"Glow", "glow"},
    {"Highlight text", "bright"},
    {"Text", "text"},
    {"Muted text", "muted"},
}

for _, row in ipairs(ColorRows) do
    local label, key = row[1], row[2]

    ColorControls[key] = ColorSection:CreateColorInput({
        Title = label,
        Default = Window:GetPaletteColor(key),
        Callback = function(color)
            Window:SetPaletteColor(key, color)
            Window:SetStatus("EDITING")
        end,
    })
end

ColorSection:CreateButton({
    Title = "Save color setup",
    Callback = function()
        local ok, result = Window:SavePalette()
        Window:SetStatus(ok and "SAVED" or "SAVE ERROR")
        Window:SetFooter(
            "NIGHTFALL BUILD",
            ok and ("Saved to " .. tostring(result)) or tostring(result)
        )
    end,
})

ColorSection:CreateButton({
    Title = "Reload saved colors",
    Callback = function()
        local ok, result = Window:LoadPalette()
        if ok then
            for key, control in pairs(ColorControls) do
                control.Value:Set(Window:GetPaletteColor(key))
            end
        end

        Window:SetStatus(ok and "LOADED" or "LOAD ERROR")
        Window:SetFooter("NIGHTFALL BUILD", ok and "Saved colors restored" or tostring(result))
    end,
})

ColorSection:CreateButton({
    Title = "Reset colors",
    Callback = function()
        Window:ResetPalette()

        for key, control in pairs(ColorControls) do
            control.Value:Set(Window:GetPaletteColor(key))
        end

        Window:SetStatus("RESET")
        Window:SetFooter("NIGHTFALL BUILD", "Default colors restored")
    end,
})

SettingsSection:CreateKeybind({
    Title = "Example keybind",
    Default = Enum.KeyCode.K,
    Callback = function(key)
        print("Keybind:", key.Name)
    end,
})

SettingsSection:CreateInput({
    Title = "Profile name",
    Default = "Default",
    Placeholder = "Profile",
    Callback = function(value)
        print("Profile:", value)
    end,
})

SettingsSection:CreateButton({
    Title = "Save settings",
    Callback = function()
        Window:SetStatus("SAVED")
        Window:SetFooter("EXAMPLE BUILD", "Settings callback fired")
    end,
})

SettingsSection:CreateParagraph({
    Title = "Hotkeys",
    Content = "F9 unloads the interface. RightShift hides or shows it. There is no pause control.",
})

Window:SetStatus("STABLE")
Window:SetFooter("NIGHTFALL BUILD", "Spectral interface online")
