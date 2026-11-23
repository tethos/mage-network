# Mage Network

**Find a resting mage, ask them, port to them. All in a few clicks.**

The mage-only **Scroll of Liminal Passage** teleports you to a party member, but only
while **both of you are resting** in an inn or a capital city. That makes it a great way
to travel, if you can find a mage who is in the right place and willing to help.

Mage Network does the tedious part for you.

---

## How it works

1. **Rest** in any inn or capital city.
2. Open Mage Network with **`/mn`** or the **minimap button**.
3. Type where you want to go, e.g. *Theramore* or *Booty Bay*. Only places that have
   a resting inn for your faction are suggested.
4. Click **Search**. Mage Network lists every mage in that zone.
5. Click **Ask**. The first 1–10 mages get a friendly whisper asking them to step
   into the inn and invite you.
6. Someone accepts and invites you, or you click **Invite**.
7. Click **Port to …**. Done.

---

## Features

- **Smart destination search.** Suggestions as you type, limited to places with a
  resting inn for your faction plus neutral goblin towns. English and German names
  both work.
- **Mage-only search.** No manual `/who` filters.
- **One-click asking.** Whispers several mages at once, nicely spaced. Mages you asked
  recently are skipped automatically.
- **Explain button.** Some mages have never heard of the scroll. One click sends them a
  short explanation.
- **Reply alerts.** Mages who answer are highlighted, with an optional soft sound.
- **Port partner tracking.** Remembers who invited you, or whom you invited, even when
  the group already has other members.
- **One-click Port.** Targets your partner and uses the scroll for you.
- **Ready check at a glance.** Shows whether you have a scroll and whether you are
  rested right now.
- **Inn icons on the world map.** Hearthstone icons show every place where porting
  works. They work alongside Questie and other map addons.
- **Your own messages.** Edit both whisper templates with `{inn}`, `{zone}` and
  `{scroll}` placeholders.
- **Localized.** English and German, detected automatically.
- **Stays out of your way.** Turns itself off in dungeons, raids and battlegrounds, and
  never touches anything in combat.

---

## Commands

| Command | Action |
| --- | --- |
| `/mn` | Open or close the window |
| `/mn options` | Open the options |
| `/mn minimap` | Show or hide the minimap button |
| `/mn partner` | Use your current target as the port partner |
| `/mn where` | Show your map position (helps fix inn icons) |
| `/mn reset` | Reset the window position and ask history |

The minimap button: **left-click** opens the window, **right-click** opens options,
**drag** to move it. A keybinding is available under *Key Bindings → AddOns*.

---

## FAQ

**Does the other mage need this addon?**
No. They only need to stand in an inn and invite you.

**Why can't I port?**
Both of you must be resting (inn or capital) and in the same party, and you need a
Scroll of Liminal Passage in your bags. The Port button tells you what's missing.

**Is whispering several people at once spammy?**
Whispers are spaced out, the default is 5 mages, and nobody is asked twice within the
cooldown (15 minutes by default, adjustable).

**An inn icon is slightly off.**
Stand in the inn, type `/mn where`, and report the numbers. Thanks!

---

Feedback and bug reports are very welcome on the project's issue tracker.
