<div align="center">

<img src="docs/assets/icon.png" width="128" alt="Mage Network icon">

# Mage Network

**Find a resting mage. Ask in one click. Port in one click.**

A clean, minimal World of Warcraft addon for traveling with the
mage-only **Scroll of Liminal Passage** on **WoW Forever**.

![WoW Forever](https://img.shields.io/badge/WoW-Forever%201.60.1-3FC7EB?style=flat-square)
![Interface](https://img.shields.io/badge/interface-16001-0E1116?style=flat-square)
![Languages](https://img.shields.io/badge/lang-EN%20%7C%20DE-3FC7EB?style=flat-square)
![License](https://img.shields.io/badge/license-MIT-0E1116?style=flat-square)

</div>

---

## Why

The Scroll of Liminal Passage teleports you to a party member, but **only while both
of you are resting** in an inn or a capital city. Finding that mage by hand means:
open `/who`, filter by class, type a zone, whisper mages one by one, wait, group up,
click the right party frame, use the scroll…

**Mage Network turns all of that into three clicks.**

```
  Where to?  ─►  Search  ─►  Ask  ─►  (they invite you)  ─►  Port
```

## Features

|  |  |
| --- | --- |
| 🧭 **Destination search** | Live suggestions, limited to places with a resting inn for your faction plus neutral towns. English and German names both work. |
| 🔎 **Mage-only search** | Searches `/who` for mages in that zone without any manual filters. |
| ✉️ **One-click ask** | Whispers the first 1–10 mages, spaced out, and never asks the same mage twice within the cooldown. |
| 💡 **Explain** | Sends a short explanation in one click to mages who have never heard of the scroll. |
| 🤝 **Port partner tracking** | Remembers who invited you, or whom you invited, even in a group that already has other members. |
| ✨ **One-click Port** | Targets your partner and uses the scroll in one click. |
| ✅ **Ready check** | Shows at a glance whether you have a scroll and whether you are rested. |
| 🗺️ **Inn icons on the map** | Hearthstone icons mark every resting inn. They work alongside Questie and other map addons. |
| 🌐 **Localized** | Detects the client language (English and German). |
| 🛡️ **Safe** | Off in dungeons, raids and battlegrounds, and never touches anything in combat. |

<!-- Screenshot: add docs/assets/screenshot.png and uncomment
<div align="center"><img src="docs/assets/screenshot.png" width="320" alt="Mage Network window"></div>
-->

## Install

**Addon manager:** search for **Mage Network** on CurseForge or Wago, or in WowUp use
*Install from URL* with this repository's URL.

**Manual:** download the latest zip from
[Releases](../../releases) and extract it into

```
World of Warcraft\_forever_\Interface\AddOns\
```

so that you end up with `AddOns\MageNetwork\MageNetwork.toc`. Then restart the game.

## Usage

Open it with **`/mn`**, the **minimap button** or the **addon compartment**.

| Command | Action |
| --- | --- |
| `/mn` | Open or close the window |
| `/mn options` | Open the options |
| `/mn minimap` | Show or hide the minimap button |
| `/mn partner` | Use your current target as the port partner |
| `/mn where` | Print map ID and coordinates (to fix an inn icon) |
| `/mn reset` | Reset the window position and ask history |

**Minimap button:** left-click opens the window, right-click opens options, drag to move.

### Message templates

Both whispers can be edited in the options. Placeholders:

| Placeholder | Becomes |
| --- | --- |
| `{inn}` | the chosen town, e.g. *Theramore Isle* |
| `{zone}` | its zone, e.g. *Dustwallow Marsh* |
| `{scroll}` | the localized scroll name |

## Development

```
MageNetwork/        the addon (this folder goes into AddOns)
  Core.lua          events, saved variables, slash commands
  Data/Inns.lua     inn locations per faction
  Who.lua           mage search
  Whisper.lua       batch asking, cooldowns, replies
  Party.lua         port partner and Port button
  MapPins.lua       world map icons
  UI/               window, autocomplete, list, options, minimap button
tools/
  make_icons.py     PNG artwork → in-game icon + README image
  package.py        builds dist/MageNetwork-<version>.zip
docs/
  PUBLISHING.md     how to release on GitHub, CurseForge, Wago, WowUp
```

For live development, link the folder instead of copying it (cmd as admin):

```bat
mklink /J "<WoW>\_forever_\Interface\AddOns\MageNetwork" "<repo>\MageNetwork"
```

### Fixing an inn icon

Stand inside the inn, run `/mn where`, and update `x` / `y` for that inn in
`MageNetwork/Data/Inns.lua`. Pull requests are welcome.

### Adding a language

Copy `MageNetwork/Locales/deDE.lua`, change the locale check at the top, translate
the strings, and add the file to `MageNetwork.toc`. For inn and zone names, add a key
next to `en`/`de` in `Data/Inns.lua`.

## License

[MIT](LICENSE)
