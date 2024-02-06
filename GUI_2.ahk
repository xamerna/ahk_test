#Requires AutoHotkey v2

#SingleInstance Force
DetectHiddenWindows true
SetTitleMatchMode 2

test_result_Path := Format('{1:#s}\result2.txt',A_ScriptDir)
if (FileExist(test_result_Path))
	FileDelete test_result_Path
	
if A_PtrSize = 8 {
    if !FileExist(exePath := IniRead('settings2.ini', 'Paths', '32bitAhkExePath', '')) {
        exePath := A_AhkPath . '\..\AutoHotkey32.exe'
        if !FileExist(exePath) {
            exePath := FileSelect(1, A_ProgramFiles . '\AutoHotkey\v2\AutoHotkey32.exe', 'Select 32 bit AHK interpreter', 'Applications (*.exe)')
        }
    }
    if !FileExist(exePath) {
        ExitApp
    }
    IniWrite(exePath, 'settings2.ini', 'Paths', '32bitAhkExePath')
    Run exePath . ' "' . A_ScriptFullPath . '"'
    ExitApp
}
if !FileExist(dllPath := IniRead('settings2.ini', 'Paths', 'AutoHotkey2Dll', '')) {
    dllPath := FileSelect(1, A_ScriptDir, 'Select AutoHotkey2.dll', 'DLL (*.dll)')
    if !FileExist(dllPath) {
        ExitApp
    }
    IniWrite(dllPath, 'settings2.ini', 'Paths', 'AutoHotkey2Dll')
}
if !hLib := DllCall('LoadLibrary', 'Str', dllPath, 'Ptr') {
    throw OSError('Failed to load AutoHotkey2.dll')
}

MsgBox "start"
script := FileRead('test_output2.ahk')
DllCall(dllPath . '\ahkSetHwndKew', 'Ptr', A_ScriptHwnd, 'UInt', 1, 'UInt', 0, 'Cdecl')
threadId_ahk2 := DllCall(dllPath . '\NewThread', 'Str', script, 'Str', '1 ' . A_ScriptHwnd . ' "local test"', 'Str', 'MuteControl.v2.ahk', 'UInt', 0, 'Ptr', 0, 'Cdecl')
KEahkgetvar := DllCall('GetProcAddress', 'Ptr', hLib, 'AStr', 'KEahkGetVar', 'Ptr')

;DllCall(dllPath . '\ahktextdll', 'Str', script, 'Str', '1 ' . A_ScriptHwnd . ' "local test"', 'Str', 'MuteControl.v2.ahk',  'Ptr', 0, 'Cdecl')

VarInteger :=Buffer(1000)

VarInteger := DllCall(KEahkgetvar, 'Str', 'VarStringJSON', 'UInt', 0, 'UInt', threadId_ahk2, 'Ptr', 0, 'Cdecl')
VarInteger := DllCall(KEahkgetvar, 'Str', 'VarInteger', 'UInt', 0, 'UInt', threadId_ahk2, 'Ptr', 0, 'Cdecl')
VarInteger := DllCall(KEahkgetvar, 'Str', 'VarFloat',  'UInt', 0, 'UInt', threadId_ahk2, 'Ptr', 0, 'Cdecl')
VarInteger := DllCall(KEahkgetvar, 'Str', 'VarString',  'UInt', 0, 'UInt', threadId_ahk2, 'Ptr', 0, 'Cdecl')

VarInteger := DllCall(KEahkgetvar, 'Str', 'arr_int',  'UInt', 0, 'UInt', threadId_ahk2, 'Ptr', 0, 'Cdecl')
VarInteger := DllCall(KEahkgetvar, 'Str', 'arr_float', 'UInt', 0, 'UInt', threadId_ahk2, 'Ptr', 0, 'Cdecl')
VarInteger := DllCall(KEahkgetvar, 'Str', 'arr_string',  'UInt', 0, 'UInt', threadId_ahk2, 'Ptr', 0, 'Cdecl')

VarInteger := DllCall(KEahkgetvar, 'Str', 'map_int',  'UInt', 0, 'UInt', threadId_ahk2, 'Ptr', 0, 'Cdecl')
VarInteger := DllCall(KEahkgetvar, 'Str', 'map_float',  'UInt', 0, 'UInt', threadId_ahk2, 'Ptr', 0, 'Cdecl')
VarInteger := DllCall(KEahkgetvar, 'Str', 'map_string',  'UInt', 0, 'UInt', threadId_ahk2, 'Ptr', 0, 'Cdecl')

VarInteger := DllCall(KEahkgetvar, 'Str', 'map_int_array',  'UInt', 0, 'UInt', threadId_ahk2, 'Ptr', 0, 'Cdecl')

VarInteger := DllCall(KEahkgetvar, 'Str', 'obj_int',  'UInt', 0, 'UInt', threadId_ahk2, 'Ptr', 0, 'Cdecl')
VarInteger := DllCall(KEahkgetvar, 'Str', 'obj_float',  'UInt', 0, 'UInt', threadId_ahk2, 'Ptr', 0, 'Cdecl')
VarInteger := DllCall(KEahkgetvar, 'Str', 'obj_string',  'UInt', 0, 'UInt', threadId_ahk2, 'Ptr', 0, 'Cdecl')

VarInteger := DllCall(KEahkgetvar, 'Str', 'arr_int_array_arr',  'UInt', 0, 'UInt', threadId_ahk2, 'Ptr', 0, 'Cdecl')
VarInteger := DllCall(KEahkgetvar, 'Str', 'arr_float_array_arr',  'UInt', 0, 'UInt', threadId_ahk2, 'Ptr', 0, 'Cdecl')
VarInteger := DllCall(KEahkgetvar, 'Str', 'arr_string_array_arr', 'UInt', 0, 'UInt', threadId_ahk2, 'Ptr', 0, 'Cdecl')

wnd := Gui('AlwaysOnTop')
wnd.OnEvent('Close', (*) => ExitApp())
wnd.SetFont('s16', 'Calibri')
wnd.MarginX := 50
wnd.MarginY := 30
;CheckBox := wnd.AddCheckbox(, 'Mute')
;MSG := Messaging((param, value) => CheckBox.Value := value)
;CheckBox.OnEvent('Click', (*) => MSG.SendParam('NewMute', CheckBox.Value))
wnd.Show('x200')








