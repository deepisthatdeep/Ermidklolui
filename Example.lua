local Leech = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/deepisthatdeep/Ermidklolui/main/Leech.lua"
))()

local Window = Leech:CreateWindow({
    Title = "LEECH",
    SubTitle = "UNIVERSAL INTERFACE",
    Version = "EXAMPLE BUILD",
    Theme = "LeechRain",
})

local Main = Window:CreateTab({
    Title = "Main",
    Index = 1,
    Description = "Primary script controls and live state",
})

local Combat = Window:CreateTab({
    Title = "Combat",
    Index = 2,
    Description = "Combat-related options for your script",
})

local Visuals = Window:CreateTab({
    Title = "Visuals",
    Index = 3,
    Description = "Visual overlays and display preferences",
})

local Settings = Window:CreateTab({
    Title = "Settings",
    Index = 4,
    Description = "Configuration, keybinds, and diagnostics",
})

local General = Main:CreateSection({
    Title = "General",
    Description = "Every control is callback-driven, so this library can be used by any script.",
})

General:CreateToggle({
    Title = "Enabled",
    Default = true,
    Callback = function(value)
        Window:SetStatus(value and "ACTIVE" or "IDLE")
        print("Enabled:", value)
    end,
})

General:CreateSlider({
    Title = "Speed",
    Range = {0, 100},
    Default = 50,
    Increment = 1,
    Suffix = "%",
    Callback = function(value)
        print("Speed:", value)
    end,
})

General:CreateDropdown({
    Title = "Mode",
    Options = {"Balanced", "Aggressive", "Safe"},
    Selected = {"Balanced"},
    Callback = function(selected)
        print("Mode:", selected[1])
    end,
})

local Status = Main:CreateSection({
    Title = "Runtime",
    Description = "Labels, progress bars, paragraphs, and notifications are available for live script state.",
})

local RuntimeLabel = Status:CreateLabel("Runtime: ready")

local Progress = Status:CreateProgress({
    Title = "Task progress",
    Default = 0.35,
})

Status:CreateButton({
    Title = "Demo notification",
    Callback = function()
        Window:Notify({
            Title = "Leech UI",
            Content = "This notification works from any script callback.",
            Duration = 3,
        })
    end,
})

Status:CreateButton({
    Title = "Advance progress",
    Callback = function()
        local nextValue = math.clamp(Progress.Value:Get() + 0.1, 0, 1)
        Progress.Value:Set(nextValue)
        RuntimeLabel.Value:Set("Runtime: progress updated")
    end,
})

local CombatSection = Combat:CreateSection({
    Title = "Combat controls",
    Level = 1,
    Description = "These are only UI examples. Connect the callbacks to your own logic.",
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

CombatSection:CreateSeparator({Title = "Advanced"})

CombatSection:CreateDropdown({
    Title = "Targets",
    Options = {"Players", "NPCs", "Projectiles"},
    Selected = {"Players", "NPCs"},
    Multi = true,
    Callback = function(selected)
        print("Selected targets:", table.concat(selected, ", "))
    end,
})

local VisualSection = Visuals:CreateSection({
    Title = "Overlay",
    Description = "The default theme blends Leech purple with Project Rain's clean card layout.",
})

VisualSection:CreateToggle({
    Title = "Show overlay",
    Default = true,
    Callback = function(value)
        print("Overlay:", value)
    end,
})

VisualSection:CreateSlider({
    Title = "Opacity",
    Range = {0, 1},
    Default = 0.8,
    Increment = 0.05,
    Callback = function(value)
        print("Opacity:", value)
    end,
})

VisualSection:CreateParagraph({
    Title = "Design",
    Content = "The background is built entirely with native Roblox UI: layered gradients, architectural grid lines, diagonal rain streaks, Leech tracery, and accent nodes.",
})

local Config = Settings:CreateSection({
    Title = "Configuration",
})

Config:CreateKeybind({
    Title = "Example keybind",
    Default = Enum.KeyCode.K,
    Callback = function(key)
        print("New key:", key.Name)
    end,
})

Config:CreateInput({
    Title = "Profile name",
    Default = "Default",
    Placeholder = "Profile",
    Callback = function(value)
        print("Profile:", value)
    end,
})

Config:CreateButton({
    Title = "Save settings",
    Callback = function()
        Window:SetStatus("SAVED")
        Window:Notify({
            Title = "Settings",
            Content = "Example save callback fired.",
        })
    end,
})

Config:CreateParagraph({
    Title = "Global window hotkeys",
    Content = "RightShift toggles visibility. F9 unloads the UI. There is no pause system.",
})

Window:SetStatus("READY")
