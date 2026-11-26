#Requires AutoHotkey v2.0
#SingleInstance Force
InstallKeybdHook
SendMode "Input"

; The Copilot key doesn't send a key of its own: it sends LWin + LShift + F23,
; and auto-repeats that whole triple while held. We hook F23 (which also stops
; Copilot from launching) and while it's held:
;
;   Copilot + Up    -> PgUp        Copilot + Left  -> Home
;   Copilot + Down  -> PgDn        Copilot + Right -> End
;   Copilot + anything else -> Ctrl + it (Copilot+C = copy, Copilot+click, ...)
;
; Real Ctrl/Alt pass through to the arrows (Copilot+Ctrl+Left = Ctrl+Home).
; Shift: hold left Shift BEFORE Copilot, or right Shift in any order. The G14
; firmware swallows a left Shift pressed after Copilot, so that can't work.

global layer := false
global userShift := false   ; true while YOU are holding left Shift

*F23:: {
    global layer
    if layer                    ; ignore auto-repeat while held
        return
    layer := true
    ; Swap the Win+Shift the Copilot key is holding for Ctrl. vkE8 is an unused
    ; key that stops the Win release from opening Start. If userShift is set,
    ; that LShift is the user's (the Copilot key doesn't send its own then).
    Send "{Blind}{vkE8}{LWin up}" (userShift ? "" : "{LShift up}") "{LCtrl down}"
}

*F23 up:: {
    global layer := false
    Send "{Blind}{LCtrl up}"
}

; Block the Copilot key's auto-repeated LWin/LShift so they don't re-press
; Win+Shift on top of our Ctrl. (A left Shift pressed by the user during the
; hold never arrives anyway - the firmware swallows it.)
#HotIf layer
*LWin::return
*LShift::return
#HotIf

; The Copilot press itself sends LWin down -> LShift down, so an LShift down
; that directly follows an LWin down is the Copilot key's. Any other is yours.
~*LShift:: {
    global userShift
    if A_PriorKey != "LWin"
        userShift := true
}

~*LShift up:: {
    global userShift := false
}

NavSend(key) {
    ; Lift the Ctrl we're holding (and any Win/Shift), then add back only the
    ; modifiers the user is really holding. Alt passes through untouched.
    mods := (userShift || GetKeyState("RShift", "P")) ? "+" : ""
    if GetKeyState("LCtrl", "P") || GetKeyState("RCtrl", "P")
        mods .= "^"
    Send "{Blind^#+}" mods "{" key "}"
}

#HotIf layer
*Up::    NavSend("PgUp")
*Down::  NavSend("PgDn")
*Left::  NavSend("Home")
*Right:: NavSend("End")
#HotIf
