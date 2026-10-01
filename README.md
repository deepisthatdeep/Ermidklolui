# Universal UI Library

A reusable Roblox UI library using the same core visual layout as the original interface this project was based on, but with neutral branding and no game-specific logic.

## What changed

This build intentionally keeps the original interface structure:

- 850 × 566 main window
- dark purple/black palette
- thin purple borders
- gothic architectural tracery in the background
- Antique-font section headings
- fixed numbered sidebar navigation
- right-aligned ON / OFF controls
- right-side text input controls
- compact full-width cycle rows
- original scrolling-page dimensions
- original draggable-header behavior
- original responsive scaling formula
- compact bottom status/footer strip

It intentionally removes:

- the pause button
- F6 pause handling
- `ACTIVE / PAUSE` wording
- game-specific branding
- game-specific feature logic

---

## Load

```lua
local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/deepisthatdeep/Ermidklolui/main/Library.lua"
))()
```

Launch the showcase:

```lua
loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/deepisthatdeep/Ermidklolui/main/Example.lua"
))()
```

---

## Create a window

```lua
local Window = Library:CreateWindow({
    Title = "INTERFACE",
    SubTitle = "U N I V E R S A L",
    ProductName = "SYSTEM",
    CurrentPage = "MAIN",
    Version = "v1.0",
})
```

### Window fields

| Field | Type | Default |
|---|---|---|
| `Title` | string | `"INTERFACE"` |
| `SubTitle` | string | `"U N I V E R S A L"` |
| `ProductName` | string | `"SYSTEM"` |
| `CurrentPage` | string | `"MAIN"` |
| `Version` | string | `"UI LIBRARY"` |
| `Palette` | table | original purple palette |
| `ToggleKey` | KeyCode/false | `RightShift` |
| `UnloadKey` | KeyCode/false | `F9` |
| `Parent` | Instance | `gethui()` or `PlayerGui` |
| `DisplayOrder` | number | `100` |
| `OnUnload` | function | optional |

---

## Original palette

```lua
bg     = Color3.fromRGB(8, 7, 12)
card   = Color3.fromRGB(18, 12, 25)
line   = Color3.fromRGB(77, 48, 101)
accent = Color3.fromRGB(145, 99, 182)
bright = Color3.fromRGB(211, 187, 229)
text   = Color3.fromRGB(234, 225, 237)
muted  = Color3.fromRGB(167, 149, 179)
```

You can override any of those through `Palette = {...}`.

---

## Window methods

```lua
Window:SetStatus("READY")
Window:SetVisible(true)
Window:ToggleVisible()
Window:SetFooter("v1.0", "Loaded")
Window:Destroy()

Window:Notify({
    Title = "Saved",
    Content = "Configuration saved.",
    Duration = 3,
})
```

There is deliberately no pause state, no `SetPaused`, and no F6 binding.

---

## Tabs

```lua
local Main = Window:CreateTab({
    Title = "Main",
    Index = 1,
})
```

A six-page layout can be created with:

```lua
local Tabs = {
    Main = Window:CreateTab({Title = "Main", Index = 1}),
    Combat = Window:CreateTab({Title = "Combat", Index = 2}),
    Automation = Window:CreateTab({Title = "Automation", Index = 3}),
    Targeting = Window:CreateTab({Title = "Targeting", Index = 4}),
    Vision = Window:CreateTab({Title = "Vision", Index = 5}),
    Settings = Window:CreateTab({Title = "Settings", Index = 6}),
}
```

---

## Sections

```lua
local General = Main:CreateSection({
    Title = "General",
    Level = 1,
    Description = "Primary script controls.",
})
```

If `Level` is provided, the heading becomes:

```text
GENERAL · LEVEL 1
```

---

## Toggle

```lua
local Toggle = General:CreateToggle({
    Title = "Enabled",
    Default = true,
    Callback = function(value)
        print(value)
    end,
})

Toggle.Value:Set(false)
print(Toggle.Value:Get())
```

Supports optional locking:

```lua
General:CreateToggle({
    Title = "Advanced feature",
    Default = false,
    Requirement = function()
        return true
    end,
    OnLocked = function()
        Window:SetStatus("LOCKED")
    end,
})
```

The control uses the original-style:

```text
● ON
○ OFF
LOCKED
```

---

## Slider

The original interface used numeric text-entry controls rather than a draggable bar. `CreateSlider` preserves that appearance.

```lua
local Slider = General:CreateSlider({
    Title = "Intensity",
    Range = {0, 100},
    Default = 50,
    Increment = 1,
    Suffix = "%",
    Callback = function(value)
        print(value)
    end,
})

Slider.Value:Set(75)
```

---

## Dropdown

Dropdowns intentionally behave like the original full-width cycle rows.

```lua
local Mode = General:CreateDropdown({
    Title = "Mode",
    Options = {"Balanced", "Fast", "Safe"},
    Selected = {"Balanced"},
    Callback = function(selected)
        print(selected[1])
    end,
})
```

Multi-select is also supported:

```lua
General:CreateDropdown({
    Title = "Targets",
    Options = {"Players", "NPCs", "Projectiles"},
    Selected = {"Players", "NPCs"},
    Multi = true,
    Callback = function(selected)
        print(table.concat(selected, ", "))
    end,
})
```

---

## Input

```lua
General:CreateInput({
    Title = "Range",
    Default = 120,
    Numeric = true,
    Min = 0,
    Max = 1000,
    Callback = function(value)
        print(value)
    end,
})
```

---

## Keybind

```lua
General:CreateKeybind({
    Title = "Action key",
    Default = Enum.KeyCode.K,
    Callback = function(key)
        print(key.Name)
    end,
})
```

---

## Button

```lua
General:CreateButton({
    Title = "Run action",
    Callback = function()
        print("clicked")
    end,
})
```

---

## Label

```lua
local Label = General:CreateLabel("Status: Ready")
Label.Value:Set("Status: Running")
```

---

## Paragraph

```lua
General:CreateParagraph({
    Title = "About",
    Content = "Longer information can be placed here.",
})
```

---

## Separator

```lua
General:CreateSeparator({
    Title = "Advanced",
})
```

---

## Progress

```lua
local Progress = General:CreateProgress({
    Title = "Progress",
    Default = 0.25,
})

Progress.Value:Set(0.8)
```

Progress values are normalized from `0` to `1`.

---

## Runtime color profiles

The window includes runtime accent switching:

```lua
Window:SetColorway("Moon")
Window:SetColorway("Aurora")
Window:SetColorway("Rose")
Window:SetColorway("Solar")
Window:SetColorway("Ice")

local nextName = Window:CycleColorway()
Window:SetAmbientGlow(true)
```

The example includes a **Color Matrix** section under Settings with a profile selector, ambient-light toggle, and cycle button.

## Hotkeys

- **RightShift** — hide/show the interface.
- **F9** — unload the interface.

There is no F6 pause hotkey.

---

## Files

- `Library.lua` — reusable UI library.
- `Example.lua` — full showcase.
- `README.md` — API reference.
