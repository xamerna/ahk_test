#Requires AutoHotkey v2

#SingleInstance Force
DetectHiddenWindows true
SetTitleMatchMode 2

test_result_Path := Format('{1:#s}\result.txt',A_ScriptDir)
if (FileExist(test_result_Path))
	FileDelete test_result_Path
	
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

MsgBox "start"
;script := FileRead('Volume control.ahk')
script := FileRead('Selected file info & file type converter.ahk')
;DllCall(dllPath . '\ahkSetHwndKew', 'Ptr', A_ScriptHwnd, 'UInt', 1, 'UInt', 0, 'Cdecl')
;DllCall(dllPath . '\NewThread', 'Str', script, 'Str', '1 ' . A_ScriptHwnd . ' "local test"', 'Str', 'MuteControl.v2.ahk', 'UInt', 0, 'Ptr', 0, 'Cdecl')
KEahkgetvar := DllCall('GetProcAddress', 'Ptr', hLib, 'AStr', 'KEahkgetvar', 'Ptr')
ahkgetwindow := DllCall('GetProcAddress', 'Ptr', hLib, 'AStr', 'ahkgetwindow', 'Ptr')
threadId_ahk :=DllCall(dllPath . '\ahktextdll', 'Str', script, 'Str', '1 ' . A_ScriptHwnd . ' "local test"', 'Str', 'MuteControl.v2.ahk',  'Ptr', 0, 'Cdecl')

;hwnd_ahk := DllCall(ahkgetwindow, 'Ptr', 0, 'Cdecl') ;получаем хэнл ahk
;MsgBox hwnd_ahk
;Sleep 100
;DllCall(dllPath . '\ahkSetHwndKew', 'Ptr', hwnd_ahk, 'UInt', 1, 'UInt', 0, 'Cdecl')

VarInteger :=Buffer(1000)
/*
DllCall(KEahkgetvar, 'Str', 'VarStringJSON', 'Ptr', VarInteger, 'UInt', 1000, 'UInt', 0, 'Cdecl')
DllCall(KEahkgetvar, 'Str', 'VarInteger', 'Ptr', VarInteger, 'UInt', 1000, 'UInt', 0, 'Cdecl')
DllCall(KEahkgetvar, 'Str', 'VarFloat', 'Ptr', VarInteger, 'UInt', 1000, 'UInt', 0, 'Cdecl')
DllCall(KEahkgetvar, 'Str', 'VarString', 'Ptr', VarInteger, 'UInt', 1000, 'UInt', 0, 'Cdecl')
DllCall(KEahkgetvar, 'Str', 'arr_int', 'Ptr', VarInteger, 'UInt', 1000, 'UInt', 0, 'Cdecl')
DllCall(KEahkgetvar, 'Str', 'arr_float', 'Ptr', VarInteger, 'UInt', 1000, 'UInt', 0, 'Cdecl')
DllCall(KEahkgetvar, 'Str', 'arr_string', 'Ptr', VarInteger, 'UInt', 1000, 'UInt', 0, 'Cdecl')
DllCall(KEahkgetvar, 'Str', 'obj_int', 'Ptr', VarInteger, 'UInt', 1000, 'UInt', 0, 'Cdecl')
DllCall(KEahkgetvar, 'Str', 'obj_float', 'Ptr', VarInteger, 'UInt', 1000, 'UInt', 0, 'Cdecl')
DllCall(KEahkgetvar, 'Str', 'obj_string', 'Ptr', VarInteger, 'UInt', 1000, 'UInt', 0, 'Cdecl')
DllCall(KEahkgetvar, 'Str', 'arr_int_array_arr', 'Ptr', VarInteger, 'UInt', 1000, 'UInt', 0, 'Cdecl')
DllCall(KEahkgetvar, 'Str', 'arr_float_array_arr', 'Ptr', VarInteger, 'UInt', 1000, 'UInt', 0, 'Cdecl')
DllCall(KEahkgetvar, 'Str', 'arr_string_array_arr', 'Ptr', VarInteger, 'UInt', 1000, 'UInt', 0, 'Cdecl')
*/
wnd := Gui('AlwaysOnTop')
wnd.OnEvent('Close', (*) => ExitApp())
wnd.SetFont('s16', 'Calibri')
wnd.MarginX := 50
wnd.MarginY := 30
;CheckBox := wnd.AddCheckbox(, 'Mute')
;MSG := Messaging((param, value) => CheckBox.Value := value)
;CheckBox.OnEvent('Click', (*) => MSG.SendParam('NewMute', CheckBox.Value))
wnd.Show('x200')








