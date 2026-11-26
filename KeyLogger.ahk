#Requires AutoHotkey v2.0
#SingleInstance Force
; Diagnostic: logs every key down/up (with timing) to keylog.txt next to this
; script. Press Esc to stop. Exit CopilotNav.ahk before running this.

logFile := A_ScriptDir "\keylog.txt"
try FileDelete logFile
t0 := A_TickCount

ih := InputHook("V L0")
ih.KeyOpt("{All}", "N")
ih.OnKeyDown := (ih, vk, sc) => Log("down", vk, sc)
ih.OnKeyUp   := (ih, vk, sc) => Log("up  ", vk, sc)
ih.Start()

Log(dir, vk, sc) {
    global t0, logFile
    name := GetKeyName(Format("vk{:x}sc{:x}", vk, sc))
    FileAppend Format("{:6} ms  {}  {:-10}  vk{:02X} sc{:03X}`n", A_TickCount - t0, dir, name, vk, sc), logFile
    if (vk = 0x1B) {
        ToolTip "Logging stopped"
        SetTimer () => ExitApp(), -800
    }
}

ToolTip "Key logger running - press Esc to stop"
SetTimer () => ToolTip(), -3000
