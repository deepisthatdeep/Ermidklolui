# Universal UI Library

A reusable Roblox UI library using the same core visual layout as the original interface this project was based on, but with neutral branding and no game-specific logic.

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
| `Title` | string | `"AETHER"` |
| `SubTitle` | string | `"S P E C T R A L"` |
| `ProductName` | string | `"PRISM"` |
| `CurrentPage` | string | `"OVERVIEW"` |
| `Version` | string | `"UI LIBRARY"` |
| `Palette` | table | white accents on dark panels |
| `ToggleKey` | KeyCode/false | `RightShift` |
| `Parent` | Instance | `gethui()` or `PlayerGui` |
| `DisplayOrder` | number | `100` |

---

## Default palette

The 940 × 610 window uses white text, borders, accents, and constellation artwork on dark backgrounds.

```lua
bg      = Color3.fromRGB(4, 5, 8)
card    = Color3.fromRGB(8, 10, 16)
line    = Color3.fromRGB(255, 255, 255)
accent  = Color3.fromRGB(255, 255, 255)
accent2 = Color3.fromRGB(255, 255, 255)
glow    = Color3.fromRGB(255, 255, 255)
bright  = Color3.fromRGB(255, 255, 255)
text    = Color3.fromRGB(255, 255, 255)
muted   = Color3.fromRGB(255, 255, 255)
```

Override channels through `Palette = {...}`. The showcase sets `AutoLoadPalette = false` to start with the default appearance.

---

## Window methods

```lua
Window:SetStatus("READY")
Window:SetVisible(true)
Window:ToggleVisible()
Window:SetFooter("v1.0", "Loaded")
Window:Destroy() -- programmatic cleanup

Window:Notify({
    Title = "Saved",
    Content = "Configuration saved.",
    Duration = 3,
})
```

There is deliberately no pause state, no `SetPaused`, and no F6 binding.

---


## Linoria-style two-column layout

Each selected sidebar tab now contains **two independent scrolling groupbox columns**, matching the layout shown in Linoria-style menus.

Use `Position = "Left"` or `Position = "Right"` on a section:

```lua
local Main = General:CreateSection({
    Position = "Left",
})

local Tuning = General:CreateSection({
    Position = "Right",
})

Tuning:CreateSlider({
    Title = "Strength",
    Range = {0, 100},
    Default = 50,
})
```

`Side = 1/2` and `Column = 1/2` are also accepted. If no side is supplied, sections automatically alternate between the two columns. Convenience helpers are available as `Tab:CreateLeftSection(...)` and `Tab:CreateRightSection(...)`.

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
    Position = "Left",
})
```

Omit `Title` or set it to `false` for an unlabeled groupbox. Explicit titles and descriptions remain optional.

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

Sliders use a draggable bar with the current value aligned to the right. Mouse and touch input are supported.

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

## Manual color editor

The Settings page includes an unlabeled groupbox that lets you edit palette channels individually. Clicking any color field opens a popup HSV picker with a saturation/value square, hue strip, live preview, hex field, and Select button.

- **Background** — window background.
- **Panels** — groupboxes and control surfaces.
- **Accent** — borders, both accent channels, and glow/constellation details.
- **Text** — regular, highlighted, and muted text.

The showcase has four pickers. Each grouped selection updates its channels together. Loading an older palette uses its primary accent and text colors for the corresponding groups.

The library exposes the same controls programmatically:

```lua
Window:SetPaletteColor("accent", "#B094FF")
Window:SetPaletteColor("accent2", "#68E0FF")
Window:SetPaletteColor("bg", "#04060E")

print(Window:GetPaletteColor("accent"))

local allColors = Window:GetPalette()
local allHex = Window:GetPaletteHex()
```

### Save / load

```lua
local ok, result = Window:SavePalette()
local ok2, result2 = Window:LoadPalette()
Window:ResetPalette()
```

Saved colors use executor file APIs and are automatically restored on the next launch when supported. The default file is `Ermidklolui_palette.json`. Set `AutoLoadPalette = false` or provide `PaletteFile = "your_file.json"` in `CreateWindow` if you want different behavior.

### Color input component

```lua
local Accent = Section:CreateColorInput({
    Title = "Primary accent",
    PaletteKey = "accent",
    Default = Window:GetPaletteColor("accent"),
    Callback = function(color, hex)
        print(hex)
    end,
})

Accent:SetHex("#FF80D5")
print(Accent:GetHex())
Accent:Close() -- closes only this control
```

`PaletteKeys = {"accent", "line", "accent2", "glow"}` binds one picker to a group, with the first key determining its displayed color. `PaletteKey` binds the control to one palette channel. Programmatic edits, load, and reset synchronize its swatch without firing its callback. Omit `PaletteKey` for an independent color value. `Accent:SetColor(color, false)` updates a standalone control silently. Picker drafts commit with Select; closing or switching pickers cancels the draft.

## Hotkeys

- **RightShift** — hide/show the interface.

There is no F6 pause hotkey.

---

## Files

- `Library.lua` — reusable UI library.
- `ColorPicker.lua` — popup HSV color picker used by color controls.
- `Example.lua` — full showcase.
- `README.md` — API reference.

