#Requires AutoHotkey v2

#SingleInstance Force
DetectHiddenWindows true
SetTitleMatchMode 2

if A_PtrSize = 8 {
    if !FileExist(exePath := IniRead('settings.ini', 'Paths', '32bitAhkExePath', '')) {
        exePath := A_AhkPath . '\..\AutoHotkey32.exe'
        if !FileExist(exePath) {
            exePath := FileSelect(1, A_ProgramFiles . '\AutoHotkey\v2\AutoHotkey32.exe', 'Select 32 bit AHK interpreter', 'Applications (*.exe)')
        }
    }
    if !FileExist(exePath) {
        ExitApp
    }
    IniWrite(exePath, 'settings.ini', 'Paths', '32bitAhkExePath')
    Run exePath . ' "' . A_ScriptFullPath . '"'
    ExitApp
}
if !FileExist(dllPath := IniRead('settings.ini', 'Paths', 'AutoHotkey2Dll', '')) {
    dllPath := FileSelect(1, A_ScriptDir, 'Select AutoHotkey2.dll', 'DLL (*.dll)')
    if !FileExist(dllPath) {
        ExitApp
    }
    IniWrite(dllPath, 'settings.ini', 'Paths', 'AutoHotkey2Dll')
}
if !hLib := DllCall('LoadLibrary', 'Str', dllPath, 'Ptr') {
    throw OSError('Failed to load AutoHotkey2.dll')
}


;ahktextdll     := DllCall('GetProcAddress', 'Ptr', hLib, 'AStr', 'ahktextdll'    , 'Ptr')
ahkSetHwndKew := DllCall('GetProcAddress', 'Ptr', hLib, 'AStr', 'ahkSetHwndKew', 'Ptr')
;ahkSetHwndThreadKew := DllCall('GetProcAddress', 'Ptr', hLib, 'AStr', 'ahkSetHwndThreadKew', 'Ptr')
ahkgetglobalvarvalues := DllCall('GetProcAddress', 'Ptr', hLib, 'AStr', 'ahkgetglobalvarvalues', 'Ptr')
;KEahkgetvar := DllCall('GetProcAddress', 'Ptr', hLib, 'AStr', 'KEahkgetvar', 'Ptr')
NewThread     := DllCall('GetProcAddress', 'Ptr', hLib, 'AStr', 'NewThread' , 'Ptr')

MsgBox "start1"

script := FileRead('test.ahk')

DllCall(ahkSetHwndKew, 'Ptr', A_ScriptHwnd, 'UInt', 1, 'UInt', 0, 'Cdecl')

;DllCall(ahktextdll, 'Str', script, 'Str', '', 'Str', 'test.ahk',  'UInt', 0, 'Cdecl')

DllCall(NewThread, 'Str', script, 'Str', '1 ' . A_ScriptHwnd . ' "local test"', 'Str', 'MuteControl.v2.ahk', 'UInt', 0, 'Cdecl')

MsgBox "start1"
;DllCall(KEahkgetvar, 'Str', 'arr_string', 'Str', Buf , 'UInt', bufcount, 'UInt', 0, 'Cdecl')
