# Mage Network

A small, clean addon for **WoW Forever** that makes traveling with the mage-only
**Scroll of Liminal Passage** effortless.

The scroll teleports you to a party member, but only if **both of you are resting**
in an inn or a capital city. Mage Network finds those mages for you, asks them,
and turns the actual port into a single click.

## Features

- **Where to?** Type a town or zone and pick from suggestions. Only places with a
  resting inn for your faction (plus neutral goblin towns) are offered. English and
  German names both work, e.g. `Theramore`, `Booty`, `Dämmerwald`.
- **Mage-only search.** Searches `/who` for mages in that zone.
- **Ask in one click.** Whispers the first 1–10 mages, nicely spaced. Mages you asked
  recently are skipped automatically.
- **Explain.** One click sends a short explanation to mages who don't know the scroll.
- **Port partner tracking.** Remembers the mage who invited you, or the one you
  invited, and finds them even if the group already has other members.
- **Port button.** Targets your partner and uses the scroll in one click.
- **Status at a glance.** Shows whether you have a scroll and whether you are rested.
- **Inn icons on the world map.** Hearthstone pins mark every resting inn. They work
  alongside Questie and other map addons that use the Blizzard world map.
- **Localized.** Detects the client language (English and German included).
- **Stays out of the way.** Disabled in dungeons, raids and battlegrounds. Secure
  actions are never touched in combat.

## Install

1. Copy (or link) the `MageNetwork` folder into
   `World of Warcraft\_forever_\Interface\AddOns\`.
2. Restart the game client.

For development, link the folder instead of copying it (run in `cmd` as admin):

```bat
mklink /J "C:\Program Files (x86)\World of Warcraft\_forever_\Interface\AddOns\MageNetwork" "D:\Projects\mage-network\MageNetwork"
```

If the addon list says *out of date*, check your client's interface number with
`/run print(select(4, GetBuildInfo()))` and update `## Interface:` in
`MageNetwork.toc`.

## Usage

| Command        | What it does                                        |
| -------------- | --------------------------------------------------- |
| `/mn`          | Toggle the window (also via the addon compartment)  |
| `/mn partner`  | Use your current target as the port partner         |
| `/mn where`    | Print map ID and coordinates (to fix an inn pin)    |
| `/mn reset`    | Reset the window position and the ask history       |

You can also set a keybinding under *Key Bindings → AddOns → Mage Network*.

Typical flow: rest at an inn → `/mn` → type a place → **Search** → **Ask** → the mage
invites you (or you click **Invite**) → **Port to …**.

## Message templates

Edit both messages in the options (gear icon). Placeholders:

- `{inn}`: the chosen town, e.g. *Theramore Isle*
- `{zone}`: its zone, e.g. *Dustwallow Marsh*
- `{scroll}`: the localized scroll name

## Contributing inn coordinates

Inn positions are in `MageNetwork/Data/Inns.lua`. If a pin is off, stand in the inn,
run `/mn where` and update the `x`/`y` values.

## License

MIT
