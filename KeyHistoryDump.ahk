#Requires AutoHotkey v2.0
#SingleInstance Force
InstallKeybdHook
KeyHistory 500   ; keep the last 500 events (doesn't open the window)
; Diagnostic: records AHK's key history (which marks injected vs. physical
; events) and writes it to keyhistory.txt when you press Esc.
; Exit the other Copilot scripts before running this.

ToolTip "Key history recording - press Esc to save and stop"
SetTimer () => ToolTip(), -3000

~Esc:: {
    KeyHistory
    WinWait "ahk_id " A_ScriptHwnd
    text := ControlGetText("Edit1", "ahk_id " A_ScriptHwnd)
    f := A_ScriptDir "\keyhistory.txt"
    try FileDelete f
    FileAppend text, f
    ExitApp
}
