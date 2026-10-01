local Leech = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/deepisthatdeep/Ermidklolui/main/Leech.lua"
))()

local Window = Leech:CreateWindow({
    Title = "Leech",
    SubTitle = "DEEPWOKEN",
    CurrentPage = "COMBAT",
    ProductName = "LEECH",
})

local Tabs = {
    Combat = Window:CreateTab({Title = "Combat", Index = "01"}),
    Breakers = Window:CreateTab({Title = "Breakers", Index = "02"}),
    Automation = Window:CreateTab({Title = "Automation", Index = "03"}),
    Targeting = Window:CreateTab({Title = "Targeting", Index = "04"}),
    Vision = Window:CreateTab({Title = "Vision", Index = "05"}),
    Settings = Window:CreateTab({Title = "Settings", Index = "06"}),
}

local AutoParry = Tabs.Combat:CreateSection({
    Title = "AUTOPARRY",
    Level = 1,
    Description = "Base autoparry uses attack timings and range. Prediction levels below add validation.",
})

AutoParry:CreateToggle({
    Title = "Autoparry",
    Default = true,
    Callback = function(v)
        print("Autoparry:", v)
    end,
})

local Air = Tabs.Combat:CreateSection({
    Title = "AIR PREDICTION",
    Level = 2,
    Description = "Uses normal game direction checks. No AI runtime is needed for this level.",
})

Air:CreateToggle({
    Title = "Air Prediction",
    Default = true,
    Callback = function(v)
        print("Air Prediction:", v)
    end,
})

Air:CreateSlider({
    Title = "Facing enter angle · degrees",
    Range = {0, 180},
    Default = 50,
    Increment = 1,
    Callback = function(v)
        print("Facing enter angle:", v)
    end,
})

Air:CreateSlider({
    Title = "Facing exit angle · degrees",
    Range = {0, 180},
    Default = 60,
    Increment = 1,
    Callback = function(v)
        print("Facing exit angle:", v)
    end,
})

local Visual = Tabs.Combat:CreateSection({
    Title = "VISUAL PREDICTION",
    Level = 3,
    Description = "Requires Level 2. Adds fresh, confident visual facing validation to the normal direction checks.",
})

Visual:CreateToggle({
    Title = "Visual Prediction",
    Default = false,
    Callback = function(v)
        print("Visual Prediction:", v)
    end,
})

local BreakerSec = Tabs.Breakers:CreateSection({
    Title = "BREAKERS",
    Level = 1,
    Description = "Example controls for breaker-related settings.",
})

BreakerSec:CreateDropdown({
    Title = "Breaker mode",
    Options = {"Balanced", "Strict", "Loose"},
    Selected = {"Balanced"},
    Callback = function(sel)
        print("Breaker mode:", sel[1])
    end,
})

local AutoSec = Tabs.Automation:CreateSection({
    Title = "AUTOMATION",
    Level = 1,
    Description = "UI showcase section. Connect these controls to your own runtime.",
})

AutoSec:CreateToggle({
    Title = "Enabled",
    Default = false,
    Callback = function(v)
        Window:SetStatus(v and "Automation enabled" or "Automation disabled")
    end,
})

local TargetSec = Tabs.Targeting:CreateSection({
    Title = "TARGETING",
    Level = 1,
    Description = "Target selection and filtering controls.",
})

TargetSec:CreateDropdown({
    Title = "Priority",
    Options = {"Nearest", "Lowest health", "Manual"},
    Selected = {"Nearest"},
    Callback = function(sel)
        print("Priority:", sel[1])
    end,
})

TargetSec:CreateSlider({
    Title = "Max distance",
    Range = {10, 300},
    Default = 160,
    Increment = 5,
    Callback = function(v)
        print("Distance:", v)
    end,
})

local VisionSec = Tabs.Vision:CreateSection({
    Title = "VISION",
    Level = 1,
    Description = "Visual preferences for the Leech interface.",
})

VisionSec:CreateToggle({
    Title = "Show status counters",
    Default = true,
    Callback = function(v)
        print("Counters visible:", v)
    end,
})

local SettingsSec = Tabs.Settings:CreateSection({
    Title = "SETTINGS",
    Description = "Library controls and runtime demo actions.",
})

SettingsSec:CreateButton({
    Title = "Increment demo counters",
    Callback = function()
        Window:SetCounter("parry", math.random(0, 999))
        Window:SetCounter("dodge", math.random(0, 999))
        Window:SetCounter("filter", math.random(0, 999))
        Window:SetCounter("errors", math.random(0, 9))
        Window:SetStatus("Counters updated")
    end,
})

SettingsSec:CreateButton({
    Title = "Reset counters",
    Callback = function()
        Window:SetCounter("parry", 0)
        Window:SetCounter("dodge", 0)
        Window:SetCounter("filter", 0)
        Window:SetCounter("errors", 0)
        Window:SetStatus("Ready")
    end,
})

SettingsSec:CreateParagraph({
    Title = "Hotkeys",
    Content = "F6 pauses, F9 unloads, and RightShift hides or shows the window.",
})
