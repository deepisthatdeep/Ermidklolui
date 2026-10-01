# Leech UI

A universal Roblox UI library that combines the original **Leech** identity with a cleaner **Project Rain-inspired** layout.

The library contains **no game-specific logic**. Every component is callback-driven, so it can be used with any Roblox script.

## Design

The current build uses:

- Project Rain-style rounded sidebar, page titles, compact cards, modern toggles, and clean spacing.
- Leech-inspired purple/lavender identity.
- A detailed native background made from layered gradients, architectural grid lines, diagonal rain streaks, gothic tracery, corner diamonds, and accent nodes.
- Responsive scaling for smaller viewports.
- Draggable and minimizable window.
- RightShift show/hide.
- F9 unload.
- **No pause function or pause button.**

No external images are required for the background.

---

## Load

```lua
local Leech = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/deepisthatdeep/Ermidklolui/main/Leech.lua"
))()
```

To launch the complete component showcase:

```lua
loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/deepisthatdeep/Ermidklolui/main/Example.lua"
))()
```

---

## Create a window

```lua
local Window = Leech:CreateWindow({
    Title = "My Script",
    SubTitle = "UNIVERSAL INTERFACE",
    Version = "v1.0",
    Theme = "LeechRain",
})
```

### Window fields

| Field | Type | Default |
|---|---|---|
| `Title` | string | `"LEECH"` |
| `SubTitle` | string | `"UNIVERSAL INTERFACE"` |
| `Version` | string | `"UI LIBRARY"` |
| `Theme` | string/table | `"LeechRain"` |
| `Width` | number | `780` |
| `Height` | number | `550` |
| `ToggleKey` | KeyCode/false | `RightShift` |
| `UnloadKey` | KeyCode/false | `F9` |
| `Parent` | Instance | `gethui()` or PlayerGui |
| `DisplayOrder` | number | `100` |
| `OnUnload` | function | optional |

### Built-in themes

```lua
Theme = "LeechRain"   -- default purple/cyan hybrid
Theme = "Rain"        -- cyan Project Rain direction
Theme = "ClassicLeech"
```

You can also pass a custom theme table.

---

## Window methods

```lua
Window:SetStatus("ACTIVE")
Window:SetVisible(true)
Window:ToggleVisible()
Window:SetFooter("v1.0", "CUSTOM FOOTER")
Window:Destroy()

Window:Notify({
    Title = "Saved",
    Content = "Configuration saved.",
    Duration = 3,
})
```

There is intentionally **no** `SetPaused`, pause state, F6 pause key, or pause button.

---

## Tabs

```lua
local Main = Window:CreateTab({
    Title = "Main",
    Index = 1,
    Description = "Primary controls",
})
```

Tabs are completely dynamic; use as many as your script needs.

---

## Sections

```lua
local General = Main:CreateSection({
    Title = "General",
    Description = "Primary script options",
    Level = 1, -- optional
})
```

---

## Toggle

```lua
local Toggle = General:CreateToggle({
    Title = "Enabled",
    Default = false,
    Callback = function(value)
        print(value)
    end,
})

Toggle.Value:Set(true)
print(Toggle.Value:Get())
```

---

## Slider

```lua
local Slider = General:CreateSlider({
    Title = "Speed",
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

Single select:

```lua
local Dropdown = General:CreateDropdown({
    Title = "Mode",
    Options = {"Balanced", "Aggressive", "Safe"},
    Selected = {"Balanced"},
    Callback = function(selected)
        print(selected[1])
    end,
})
```

Multi-select:

```lua
local Targets = General:CreateDropdown({
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

Values are normalized from `0` to `1`.

---

## Hotkeys

- **RightShift** — show/hide the window.
- **F9** — unload the UI.

Both can be changed or disabled through `CreateWindow`.

---

## Files

- `Leech.lua` — reusable library.
- `Example.lua` — complete showcase.
- `README.md` — API reference.
