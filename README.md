# G14 Copilot key as a navigation modifier

AutoHotkey v2 scripts that turn the Copilot key on an Asus ROG Zephyrus G14 (2025)
into a modifier:

| Copilot + | Sends |
|---|---|
| ↑ | Page Up |
| ↓ | Page Down |
| ← | Home |
| → | End |
| anything else | Ctrl + that key |

Shift, Alt and the real Ctrl keys combine with the arrows as you'd expect, e.g.
Shift + Copilot + → = Shift+End (select to end of line), Copilot + Ctrl + ← = Ctrl+Home.

## Which script?

**`CopilotRCtrl.ahk` (recommended).** Set Windows to remap the key first:
*Settings → Personalization → Text input → Customize Copilot key on keyboard → Right Ctrl*.
Windows then provides the Ctrl behaviour and the script only adds the arrow layer, plus a
fix for Windows dropping any Shift you're holding when it does the remap.

**`CopilotNav.ahk`.** For when the Copilot key is left at its default. It does the whole job
itself: hooks the key, swaps the Win+Shift it sends for Ctrl, and adds the arrow layer.

Run only one of them. To start one with Windows, put a shortcut to it in `shell:startup`.

If you use G-Helper, set its Copilot key binding to Default/None so the key reaches the script.

## Known limitation: Shift after Copilot

Press Shift **before** Copilot. Shift pressed *after* Copilot (left or right) doesn't work,
and no script can fix it: while Copilot is held, the G14 keyboard firmware doesn't report a
Shift press at all, only the release later on.

## What the Copilot key actually sends

Logged on a G14 2025:

- It doesn't have a key code of its own. A press sends **LWin ↓, LShift ↓, F23 ↓**, and holding
  it repeats that whole triple about every 30 ms after a 0.5 s delay.
- If you're already holding left Shift, it sends just LWin + F23.
- With the Windows Right Ctrl remap on, Windows immediately releases LWin, LShift, F23 *and any
  Shift you're holding*, then presses RCtrl. It releases the artificial RCtrl when F23 goes up.

## Diagnostic scripts

- `KeyLogger.ahk`: logs every key down/up with timings to `keylog.txt`. Press Esc to stop.
- `KeyHistoryDump.ahk`: saves AutoHotkey's key history to `keyhistory.txt` when you press Esc.
  The history marks which events were injected by software and which came from the keyboard.

Exit the main script before running either.

Requires [AutoHotkey v2](https://www.autohotkey.com/).

## License

MIT. See [LICENSE](LICENSE).
