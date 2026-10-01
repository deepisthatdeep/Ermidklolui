# Leech UI Library

A reusable Roblox UI library extracted from the **actual Leech HUD code** used in `Leech_Combat.lua`.

This repository now reuses the original Leech interface implementation rather than approximating the screenshot. The palette, 850×566 window, gothic background tracery, Antique headings, sidebar placement, content coordinates, cards, toggle buttons, scrolling pages, drag behavior, responsive `UIScale`, footer format, and F6/F9/RightShift hotkeys are based directly on the original HUD.

---

## Loading

```lua
local Leech = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/deepisthatdeep/Ermidklolui/main/Leech.lua"
))()
```

## Quick start

```lua
local Leech = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/deepisthatdeep/Ermidklolui/main/Leech.lua"
))()

local Window = Leech:CreateWindow({
    Title = "LEECH",
    SubTitle = "D E E P W O K E N",
    CurrentPage = "COMBAT",
    ProductName = "LEECH",
})

local Combat = Window:CreateTab({
    Title = "Combat",
    Index = 1,
})

local Parry = Combat:CreateSection({
    Title = "Autoparry",
    Level = 1,
    Description = "Base autoparry uses attack timings and range. Prediction levels below add validation.",
})

Parry:CreateToggle({
    Title = "Autoparry",
    Default = true,
    Callback = function(value)
        print("Autoparry:", value)
    end,
})
```

---

## Original Leech details preserved

The library keeps the HUD values from the original script:

```lua
bg     = Color3.fromRGB(8, 7, 12)
card   = Color3.fromRGB(18, 12, 25)
line   = Color3.fromRGB(77, 48, 101)
accent = Color3.fromRGB(145, 99, 182)
bright = Color3.fromRGB(211, 187, 229)
text   = Color3.fromRGB(234, 225, 237)
muted  = Color3.fromRGB(167, 149, 179)
```

The original positions are also retained:

- Window: `850 × 566`
- Content pages: `632 × 421` at `190, 64`
- Sidebar tabs: `133 × 30` starting at `24, 107`
- Sidebar spacing: `46 px`
- Pause button: `24, 405`
- Key hints: `24, 452`
- Footer: `191, 495`
- Close/minimize controls: original top-right positions
- Responsive scaling formula from the original Leech HUD

---

## Window API

### `Leech:CreateWindow(Cfg)`

| Field | Type | Default |
|---|---|---|
| `Title` | string | `"LEECH"` |
| `SubTitle` | string | `"D E E P W O K E N"` |
| `CurrentPage` | string | `"COMBAT"` |
| `ProductName` | string | `"LEECH"` |
| `Parent` | Instance | `LocalPlayer.PlayerGui` |
| `PauseKey` | KeyCode | `F6` |
| `UnloadKey` | KeyCode | `F9` |
| `ToggleKey` | KeyCode | `RightShift` |
| `OnPauseChanged` | function | optional |
| `OnUnload` | function | optional |

### Methods

```lua
Window:SetPaused(true)
Window:SetVisible(true)
Window:ToggleVisible()
Window:SetStatus("Ready", "Second status line")
Window:SetCounter("parry", 12)
Window:SetCounter("dodge", 4)
Window:SetCounter("filter", 19)
Window:SetCounter("errors", 0)

Window:SetFooter({
    parry = 12,
    dodge = 4,
    filter = 19,
    errors = 0,
    line1 = "Ready",
    line2 = "Runtime connected",
})

Window:Destroy()
```

---

## Tabs

```lua
local Combat = Window:CreateTab({
    Title = "Combat",
    Index = 1,
})
```

The common Leech sidebar can be reproduced with:

```lua
local Tabs = {
    Combat = Window:CreateTab({Title = "Combat", Index = 1}),
    Breakers = Window:CreateTab({Title = "Breakers", Index = 2}),
    Automation = Window:CreateTab({Title = "Automation", Index = 3}),
    Targeting = Window:CreateTab({Title = "Targeting", Index = 4}),
    Vision = Window:CreateTab({Title = "Vision", Index = 5}),
    Settings = Window:CreateTab({Title = "Settings", Index = 6}),
}
```

---

## Sections

```lua
local Air = Combat:CreateSection({
    Title = "Air Prediction",
    Level = 2,
    Description = "Uses normal game direction checks. No AI runtime is needed for this level.",
})
```

A `Level` automatically renders as `TITLE · LEVEL N`, matching the old HUD.

---

## Components

### Toggle

Uses the original Leech `● ON / ○ OFF / LOCKED` button design.

```lua
local Toggle = Air:CreateToggle({
    Title = "Air Prediction",
    Default = true,
    Callback = function(value)
        print(value)
    end,
})

Toggle.Value:Set(false)
print(Toggle.Value:Get())
```

Optional dependency:

```lua
Visual:CreateToggle({
    Title = "Visual Prediction",
    Default = false,
    Requirement = function()
        return Toggle.Value:Get()
    end,
    OnLocked = function()
        Window:SetStatus("Enable Air Prediction / Level 2 first")
    end,
    Callback = function(value)
        print(value)
    end,
})
```

### Dropdown / cycle row

The original Leech HUD used a full-width cycle button instead of a popup list. `CreateDropdown` intentionally preserves that interaction.

```lua
Section:CreateDropdown({
    Title = "Mode",
    Options = {"Standard", "Experimental", "Mira"},
    Selected = {"Standard"},
    Callback = function(selected)
        print(selected[1])
    end,
})
```

### Input

Uses the original right-side `TextBox` layout.

```lua
Section:CreateInput({
    Title = "Maximum distance",
    Default = 160,
    Numeric = true,
    Min = 0,
    Max = 500,
    Callback = function(value)
        print(value)
    end,
})
```

### Slider

The old Leech interface did not use draggable slider bars. To keep the same UI, `CreateSlider` uses the same numeric TextBox style as the original `edit()` control.

```lua
Section:CreateSlider({
    Title = "Facing enter angle · degrees",
    Range = {0, 180},
    Default = 50,
    Callback = function(value)
        print(value)
    end,
})
```

### Button

```lua
Section:CreateButton({
    Title = "Save settings",
    Callback = function()
        Window:SetStatus("Settings saved")
    end,
})
```

### Label and paragraph

```lua
local Label = Section:CreateLabel("Runtime: OFFLINE")
Label.Value:Set("Runtime: CONNECTED")

local Paragraph = Section:CreateParagraph({
    Title = "Status",
    Content = "Reusable text content.",
})
```

---

## Hotkeys

- **F6** — pause / resume
- **F9** — unload
- **RightShift** — hide / show

These are the same defaults as the original Leech script.

---

## Example

See [Example.lua](./Example.lua) for a full six-page setup using the original Leech UI code and layout.

The repository contains the UI framework only. Feature callbacks are intentionally separate so the same interface can be reused by other scripts.
