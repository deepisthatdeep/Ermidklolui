local Leech = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/deepisthatdeep/Ermidklolui/main/Leech.lua"
))()

local Window = Leech:CreateWindow({
    Title = "LEECH",
    SubTitle = "D E E P W O K E N",
    CurrentPage = "COMBAT",
    ProductName = "LEECH",
})

local Tabs = {
    Combat = Window:CreateTab({Title = "Combat", Index = 1}),
    Breakers = Window:CreateTab({Title = "Breakers", Index = 2}),
    Automation = Window:CreateTab({Title = "Automation", Index = 3}),
    Targeting = Window:CreateTab({Title = "Targeting", Index = 4}),
    Vision = Window:CreateTab({Title = "Vision", Index = 5}),
    Settings = Window:CreateTab({Title = "Settings", Index = 6}),
}

local Base = Tabs.Combat:CreateSection({
    Title = "Autoparry",
    Level = 1,
    Description = "Base autoparry uses attack timings and range. Prediction levels below add validation.",
})

Base:CreateToggle({
    Title = "Autoparry",
    Default = true,
    Callback = function(value)
        print("Autoparry:", value)
    end,
})

local Air = Tabs.Combat:CreateSection({
    Title = "Air Prediction",
    Level = 2,
    Description = "Uses normal game direction checks. No AI runtime is needed for this level.",
})

local AirToggle = Air:CreateToggle({
    Title = "Air Prediction",
    Default = true,
    Callback = function(value)
        print("Air Prediction:", value)
    end,
})

Air:CreateSlider({
    Title = "Facing enter angle · degrees",
    Range = {0, 180},
    Default = 50,
    Callback = function(value)
        print("Facing enter angle:", value)
    end,
})

Air:CreateSlider({
    Title = "Facing exit angle · degrees",
    Range = {0, 180},
    Default = 60,
    Callback = function(value)
        print("Facing exit angle:", value)
    end,
})

local Visual = Tabs.Combat:CreateSection({
    Title = "Visual Prediction",
    Level = 3,
    Description = "Requires Level 2. Adds fresh, confident AI facing validation to the normal direction checks.",
})

Visual:CreateToggle({
    Title = "Visual Prediction",
    Default = false,
    Requirement = function()
        return AirToggle.Value:Get()
    end,
    OnLocked = function()
        Window:SetStatus("Enable Air Prediction / Level 2 first")
    end,
    Callback = function(value)
        print("Visual Prediction:", value)
    end,
})

Visual:CreateInput({
    Title = "Minimum confidence",
    Default = 0.72,
    Numeric = true,
    Min = 0,
    Max = 1,
    Callback = function(value)
        print("Confidence:", value)
    end,
})

Visual:CreateInput({
    Title = "Maximum result age · seconds",
    Default = 0.25,
    Numeric = true,
    Min = 0,
    Callback = function(value)
        print("Result age:", value)
    end,
})

local BaseFeatures = Tabs.Combat:CreateSection({
    Title = "Base combat features",
    Description = "Breakers and defensive dodge are independent of the AI model.",
})

BaseFeatures:CreateToggle({
    Title = "Autoparry breaker",
    Default = false,
    Callback = function(value)
        print("Autoparry breaker:", value)
    end,
})

BaseFeatures:CreateToggle({
    Title = "Anti-autoparry breaker",
    Default = true,
    Callback = function(value)
        print("Anti-autoparry breaker:", value)
    end,
})

BaseFeatures:CreateToggle({
    Title = "Defensive dodge",
    Default = true,
    Callback = function(value)
        print("Defensive dodge:", value)
    end,
})

local BreakerSection = Tabs.Breakers:CreateSection({
    Title = "Offensive breaker",
    Description = "Cycle controls use the same full-width row style as the original Leech HUD.",
})

BreakerSection:CreateDropdown({
    Title = "Mode",
    Options = {"Standard", "Experimental", "Mira"},
    Selected = {"Standard"},
    Callback = function(selected)
        print("Mode:", selected[1])
    end,
})

BreakerSection:CreateInput({
    Title = "Decoys per second",
    Default = 8,
    Numeric = true,
    Min = 0,
    Callback = function(value)
        print("Rate:", value)
    end,
})

local AutomationSection = Tabs.Automation:CreateSection({
    Title = "Combat assistance",
    Description = "Example UI controls using the original Leech card and toggle code.",
})

AutomationSection:CreateToggle({
    Title = "Auto helper",
    Default = false,
    Callback = function(value)
        print("Auto helper:", value)
    end,
})

local TargetingSection = Tabs.Targeting:CreateSection({
    Title = "Threat sources & selection",
})

TargetingSection:CreateToggle({
    Title = "Players",
    Default = true,
    Callback = function(value)
        print("Players:", value)
    end,
})

TargetingSection:CreateToggle({
    Title = "NPCs",
    Default = true,
    Callback = function(value)
        print("NPCs:", value)
    end,
})

TargetingSection:CreateDropdown({
    Title = "Selection",
    Options = {"Distance", "FOV"},
    Selected = {"Distance"},
    Callback = function(selected)
        print("Selection:", selected[1])
    end,
})

local VisionSection = Tabs.Vision:CreateSection({
    Title = "Vision",
    Description = "Status labels and full-width buttons retain the original Leech spacing.",
})

local Runtime = VisionSection:CreateLabel("Runtime: OFFLINE    Backbone: NOT READY")
VisionSection:CreateButton({
    Title = "Set up vision",
    Callback = function()
        Runtime.Value:Set("Runtime: demo action pressed")
    end,
})

local SettingsSection = Tabs.Settings:CreateSection({
    Title = "Timing & persistence",
})

SettingsSection:CreateInput({
    Title = "Timing offset · seconds",
    Default = 0,
    Numeric = true,
    Callback = function(value)
        print("Timing offset:", value)
    end,
})

SettingsSection:CreateButton({
    Title = "Save settings",
    Callback = function()
        Window:SetStatus("Settings saved")
    end,
})

Window:SetFooter({
    parry = 0,
    dodge = 0,
    filter = 0,
    errors = 0,
    line1 = "Ready",
    line2 = "Leech UI library loaded",
})
