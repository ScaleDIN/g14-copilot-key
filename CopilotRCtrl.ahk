#Requires AutoHotkey v2.0
#SingleInstance Force
InstallKeybdHook
SendMode "Input"

; For use with Windows Settings > Personalization > Text input >
; "Customize Copilot key on keyboard" set to Right Ctrl. Windows then does the
; Ctrl part for us, so this script adds the arrow layer:
;
;   RCtrl (Copilot) + Up    -> PgUp        + Left  -> Home
;   RCtrl (Copilot) + Down  -> PgDn        + Right -> End
;   RCtrl (Copilot) + anything else -> plain Ctrl
;
; Alt passes through, and holding left Ctrl as well adds Ctrl back
; (Copilot+LCtrl+Left = Ctrl+Home). Don't run this together with CopilotNav.ahk.
;
; Shift fix: the key still sends LWin+LShift+F23, and Windows' remap turns that
; into RCtrl by releasing LWin, LShift - and also any Shift YOU are holding -
; then pressing RCtrl:
;   LWin dn, LShift dn, F23 dn, LWin up, LShift up, [RShift up], F23 up, RCtrl dn
; So we track the user's Shift ourselves, ignore the fake Shift release in that
; burst, and press Shift again once RCtrl is down. This makes Shift-first work
; for every Copilot combo, not just the arrows. (A left Shift pressed AFTER
; Copilot still can't work: the keyboard firmware never reports it.)

global userShift := ""      ; "LShift"/"RShift" while the user holds one, else ""
global f23Tick := 0

~*F23:: {
    global f23Tick := A_TickCount
}

ShiftDown(key) {
    global userShift
    ; The Copilot key's own LShift directly follows its LWin.
    if !(key = "LShift" && A_PriorKey = "LWin")
        userShift := key
}

ShiftUp(key) {
    global userShift
    ; Ignore the fake release in the Copilot press burst (just after F23 down,
    ; before RCtrl goes down).
    if (A_TickCount - f23Tick < 50) && !GetKeyState("RCtrl")
        return
    if userShift = key
        userShift := ""
}

~*LShift::    ShiftDown("LShift")
~*RShift::    ShiftDown("RShift")
~*LShift up:: ShiftUp("LShift")
~*RShift up:: ShiftUp("RShift")

; RCtrl down at the end of the burst: put back the Shift Windows released.
~*RCtrl:: {
    if userShift && !GetKeyState("Shift")
        Send "{Blind}{" userShift " down}"
}

NavSend(key) {
    ; {Blind^} keeps Shift/Alt as held but lifts Ctrl for this key; add it back
    ; only if left Ctrl is really held too.
    mods := GetKeyState("LCtrl", "P") ? "^" : ""
    Send "{Blind^}" mods "{" key "}"
}

*>^Up::    NavSend("PgUp")
*>^Down::  NavSend("PgDn")
*>^Left::  NavSend("Home")
*>^Right:: NavSend("End")
