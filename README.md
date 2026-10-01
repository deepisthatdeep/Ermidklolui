# Leech UI Library

A dark, purple-accented Roblox UI library inspired by the **Leech** interface style.

Leech UI is focused on a compact sidebar layout, numbered navigation, level-based sections, a bottom runtime/status strip, and a clean monospace aesthetic. This repository contains the UI framework only; game-specific automation or combat logic is not included.

---

## Loading the Library

```lua
local Leech = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/deepisthatdeep/Ermidklolui/main/Leech.lua"
))()
```

---

## Quick Start

```lua
local Leech = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/deepisthatdeep/Ermidklolui/main/Leech.lua"
))()

local Window = Leech:CreateWindow({
    Title = "Leech",
    SubTitle = "DEEPWOKEN",
    CurrentPage = "COMBAT",
    ProductName = "LEECH",
})

local Combat = Window:CreateTab({
    Title = "Combat",
    Index = "01",
})

local Parry = Combat:CreateSection({
    Title = "AUTOPARRY",
    Level = 1,
    Description = "Base autoparry uses attack timings and range.",
})

Parry:CreateToggle({
    Title = "Autoparry",
    Default = true,
    Callback = function(Value)
        print("Autoparry:", Value)
    end,
})
```

---

## `Leech:CreateWindow(Cfg)`

Creates the main Leech window and returns a **WindowObj**.

| Field | Type | Default | Description |
|---|---|---:|---|
| `Title` | string | `"Leech"` | Main title in the top-left |
| `SubTitle` | string | `"DEEPWOKEN"` | Small spaced subtitle |
| `CurrentPage` | string | `"HOME"` | Initial breadcrumb page label |
| `ProductName` | string | `"LEECH"` | Breadcrumb product label |
| `Width` | number | `840` | Window width |
| `Height` | number | `560` | Window height |
| `ToggleKey` | KeyCode | `RightShift` | Hide/show key |
| `PauseKey` | KeyCode | `F6` | Pause/resume key |
| `UnloadKey` | KeyCode | `F9` | Destroy UI key |

```lua
local Window = Leech:CreateWindow({
    Title = "Leech",
    SubTitle = "DEEPWOKEN",
    CurrentPage = "COMBAT",
    ProductName = "LEECH",
    Width = 840,
    Height = 560,
})
```

### WindowObj Methods

#### `WindowObj:CreateTab(Cfg)`

Creates a numbered sidebar tab.

| Field | Type | Default | Description |
|---|---|---|---|
| `Title` | string | `"Tab"` | Sidebar label |
| `Index` | string/number | automatic | Sidebar number |

```lua
local Combat = Window:CreateTab({
    Title = "Combat",
    Index = "01",
})
```

#### `WindowObj:SetPaused(Value)`

Sets the paused state and updates the sidebar/runtime display.

```lua
Window:SetPaused(true)
Window:SetPaused(false)
```

#### `WindowObj:SetStatus(Text)`

Changes the bottom-left runtime status text.

```lua
Window:SetStatus("Ready")
```

#### `WindowObj:SetCounter(Name, Value)`

Updates one of the bottom counters. Counter names are case-insensitive.

```lua
Window:SetCounter("parry", 12)
Window:SetCounter("dodge", 3)
Window:SetCounter("filter", 42)
Window:SetCounter("errors", 0)
```

#### `WindowObj:Destroy()`

Completely removes the UI and disconnects library-owned connections.

---

## `TabObj:CreateSection(Cfg)`

Creates a bordered Leech-style section inside a tab.

| Field | Type | Default | Description |
|---|---|---|---|
| `Title` | string | `"SECTION"` | Section heading |
| `Level` | number/string | `nil` | Optional `LEVEL N` label |
| `Description` | string | `""` | Muted helper text |

```lua
local Prediction = Combat:CreateSection({
    Title = "AIR PREDICTION",
    Level = 2,
    Description = "Uses normal game direction checks.",
})
```

---

## Components

All components are created from a **SectionObj**.

### `SectionObj:CreateToggle(Cfg)`

```lua
local Toggle = Prediction:CreateToggle({
    Title = "Air Prediction",
    Default = true,
    Callback = function(Value)
        print(Value)
    end,
})

Toggle.Value:Set(false)
Toggle.Name:Set("Prediction")
```

### `SectionObj:CreateSlider(Cfg)`

```lua
local Slider = Prediction:CreateSlider({
    Title = "Facing enter angle",
    Range = {0, 180},
    Default = 50,
    Increment = 1,
    Suffix = "°",
    Callback = function(Value)
        print(Value)
    end,
})

Slider.Value:Set(60)
```

### `SectionObj:CreateDropdown(Cfg)`

```lua
local Dropdown = Prediction:CreateDropdown({
    Title = "Mode",
    Options = {"Balanced", "Strict", "Loose"},
    Selected = {"Balanced"},
    Multi = false,
    Callback = function(Selected)
        print(Selected[1])
    end,
})

Dropdown.Options:Set({"Balanced", "Strict"})
Dropdown.Value:Set("Strict")
```

### `SectionObj:CreateButton(Cfg)`

```lua
Section:CreateButton({
    Title = "Reset counters",
    Callback = function()
        Window:SetCounter("parry", 0)
        Window:SetCounter("dodge", 0)
    end,
})
```

### `SectionObj:CreateLabel(Text)`

```lua
local Label = Section:CreateLabel("Ready")
Label.Value:Set("Running")
```

### `SectionObj:CreateParagraph(Cfg)`

```lua
local Paragraph = Section:CreateParagraph({
    Title = "About",
    Content = "Leech UI uses a compact dark interface with purple accents.",
})

Paragraph.Title:Set("Info")
Paragraph.Content:Set("Updated text.")
```

---

## Full Example

See [Example.lua](./Example.lua) for a complete showcase matching the Leech layout:

- 01 Combat
- 02 Breakers
- 03 Automation
- 04 Targeting
- 05 Vision
- 06 Settings
- F6 pause
- F9 unload
- RightShift hide
- Bottom `PARRY / DODGE / FILTER / ERRORS` counters

---

## Notes

- The library is designed for executor environments that support `loadstring` and `game:HttpGet`.
- It automatically prefers `gethui()` when available and otherwise falls back to `CoreGui`.
- `ResetOnSpawn` is disabled.
- This project is a UI framework. Connect component callbacks to your own logic.
