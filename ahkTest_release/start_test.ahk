﻿#Requires AutoHotkey v2

#SingleInstance Force
DetectHiddenWindows true
SetTitleMatchMode 2

test_result_Path := Format('{1:#s}\test_result.txt',A_ScriptDir)
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
if !FileExist(dllPath2 := IniRead('settings.ini', 'Paths', 'AutoHotkey2Dll', '')) {
    dllPath2 := FileSelect(1, A_ScriptDir, 'Select AutoHotkey2.dll', 'DLL (*.dll)')
    if !FileExist(dllPath2) {
        ExitApp
    }
    IniWrite(dllPath2, 'settings.ini', 'Paths', 'AutoHotkey2Dll')
}

if !FileExist(dllPath := IniRead('settings.ini', 'Paths', 'AutoHotkeyDll', '')) {
    dllPath := FileSelect(1, A_ScriptDir, 'Select AutoHotkey.dll', 'DLL (*.dll)')
    if !FileExist(dllPath) {
        ExitApp
    }
    IniWrite(dllPath, 'settings.ini', 'Paths', 'AutoHotkeyDll')
}

if !hLib := DllCall('LoadLibrary', 'Str', dllPath, 'Ptr') {
    throw OSError('Failed to load AutoHotkey.dll')
}

if !hLib2 := DllCall('LoadLibrary', 'Str', dllPath2, 'Ptr') {
    throw OSError('Failed to load AutoHotkey2.dll')
}

ahkdll := DllCall('GetProcAddress', 'Ptr', hLib, 'AStr', 'ahkdll', 'Ptr')
ahktextdll     := DllCall('GetProcAddress', 'Ptr', hLib, 'AStr', 'ahktextdll'    , 'Ptr')
ahkreload := DllCall('GetProcAddress', 'Ptr', hLib, 'AStr', 'ahkreload', 'Ptr')
ahkpause := DllCall('GetProcAddress', 'Ptr', hLib, 'AStr', 'ahkpause', 'Ptr')
ahkterminate := DllCall('GetProcAddress', 'Ptr', hLib, 'AStr', 'ahkterminate', 'Ptr')
ahkready := DllCall('GetProcAddress', 'Ptr', hLib, 'AStr', 'ahkready', 'Ptr')
ahkassign := DllCall('GetProcAddress', 'Ptr', hLib, 'AStr', 'ahkassign', 'Ptr')
KEahkgetvar := DllCall('GetProcAddress', 'Ptr', hLib, 'AStr', 'KEahkgetvar', 'Ptr')
ahkgetglobalvarvalues := DllCall('GetProcAddress', 'Ptr', hLib, 'AStr', 'ahkgetglobalvarvalues', 'Ptr')
ahkgetwindow := DllCall('GetProcAddress', 'Ptr', hLib, 'AStr', 'ahkgetwindow', 'Ptr')
ahkSetHwndKew := DllCall('GetProcAddress', 'Ptr', hLib, 'AStr', 'ahkSetHwndKew', 'Ptr')

if (!ahkdll || !ahktextdll || !ahkreload || !ahkpause || !ahkterminate || !ahkready || !ahkassign || !KEahkgetvar || !ahkgetglobalvarvalues || !ahkgetwindow || !ahkSetHwndKew){
	throw OSError('Failed to load functions AutoHotkey.dll')
}


addScript2 := DllCall('GetProcAddress', 'Ptr', hLib2, 'AStr', 'addScript', 'Ptr')
NewThread     := DllCall('GetProcAddress', 'Ptr', hLib2, 'AStr', 'NewThread'    , 'Ptr')
ahkReady2 := DllCall('GetProcAddress', 'Ptr', hLib2, 'AStr', 'ahkReady', 'Ptr')
ahkAssign2 := DllCall('GetProcAddress', 'Ptr', hLib2, 'AStr', 'ahkAssign', 'Ptr')
ahkGetVar2 := DllCall('GetProcAddress', 'Ptr', hLib2, 'AStr', 'ahkGetVar', 'Ptr')
ahkSetHwndKew2 := DllCall('GetProcAddress', 'Ptr', hLib2, 'AStr', 'ahkSetHwndKew', 'Ptr')
ahkSetHwndThreadKew2 := DllCall('GetProcAddress', 'Ptr', hLib2, 'AStr', 'ahkSetHwndThreadKew', 'Ptr')
ahkTerminateScript2 := DllCall('GetProcAddress', 'Ptr', hLib2, 'AStr', 'ahkTerminateScript', 'Ptr')
ahkGetWindow2 := DllCall('GetProcAddress', 'Ptr', hLib2, 'AStr', 'ahkGetWindow', 'Ptr')
ahkgetglobalvarvalues2 := DllCall('GetProcAddress', 'Ptr', hLib2, 'AStr', 'ahkgetglobalvarvalues', 'Ptr')

if (!addScript2 || !NewThread || !ahkReady2 || !ahkAssign2 || !ahkGetVar2 || !ahkSetHwndKew2 || !ahkSetHwndThreadKew2 || !ahkTerminateScript2 || !ahkGetWindow2 || !ahkgetglobalvarvalues2){
	throw OSError('Failed to load functions AutoHotkey2.dll')
}


MsgBox "Старт"

;тест записи переменной

script_ahk1 := FileRead('autohotkey_test.ahk')
script_ahk2 := FileRead('autohotkey2_test.ahk')

if (!script_ahk1 || !script_ahk2){
	throw OSError('Failed to load script AutoHotkey.dll')
}
if (!script_ahk2){
	throw OSError('Failed to load script AutoHotkey2.dll')
}

;загрузка скрипта ahk
;DllCall(ahkSetHwndKew, 'Ptr', A_ScriptHwnd, 'UInt', 1, 'UInt', 0, 'Cdecl')
threadId_ahk :=DllCall(ahktextdll, 'Str', script_ahk1, 'Str', '', 'Str', 'ahk',  'Ptr', 0, 'Cdecl')
if (!threadId_ahk){
	throw OSError('Failed threadId_ahk')
}
hwnd_ahk := DllCall(ahkgetwindow, 'Ptr', 0, 'Cdecl') ;получаем хэнл ahk
if (!hwnd_ahk) 
	throw OSError('Failed hwnd_ahk')
	

;-----загрузка скрипта ahk2

threadId_ahk2 := DllCall(NewThread, 'Str', script_ahk2, 'Str', '', 'Str', 'ahk2', 'UInt', 0, 'UInt', 0, 'Cdecl')
if (!threadId_ahk2){
	throw OSError('Failed threadId_ahk2')
}
hwnd_ahk2 := DllCall(ahkGetWindow2, 'UInt', threadId_ahk2, 'Ptr', 0, 'Cdecl') ;получаем хэнл ahk2
if (!hwnd_ahk2) 
	throw OSError('Failed hwnd_ahk2')
	
;------устанавливаем в ahk2 хендл для отправки в ahk а в ahk хендл для отправки в ahk2
DllCall(ahkSetHwndKew2, 'Ptr', hwnd_ahk, 'UInt', threadId_ahk, 'UInt', 0, 'Cdecl') 
DllCall(ahkSetHwndKew, 'Ptr', hwnd_ahk2, 'UInt', threadId_ahk2, 'UInt', 0, 'Cdecl')

;MsgBox hwnd_ahk
;MsgBox hwnd_ahk2
;---------------------------Тест установки и чтения глобальных переменных-------------------------

;------устанавливаем переменную input_variable в AutoHotkey
DllCall(ahkassign, 'Str', 'input_variable', 'Str', 'value_input_var', 'UInt', 0, 'Cdecl')

;------устанавливаем переменную input_variable в AutoHotkey2
DllCall(ahkAssign2, 'Str', 'input_variable', 'Str', 'value_input_var', 'UInt', threadId_ahk2, 'UInt', 0, 'Cdecl')

;------читаем переменную input_variable из AutoHotkey
value_input_var :=Buffer(1000)
DllCall(KEahkgetvar, 'Str', 'input_variable', 'Ptr', value_input_var, 'UInt', 1000, 'UInt', 0, 'Cdecl')

if (StrGet(value_input_var) == "value_input_var") 
	FileAppend "AutoHotkey read and write global variable - OK`n", test_result_Path    
else 
	FileAppend "AutoHotkey read and write global variable - ERROR`n", test_result_Path  
	
;------читаем переменную input_variable из AutoHotkey2
value_input_var := DllCall(ahkGetVar2, 'Str', 'input_variable',  'UInt', 0, 'UInt', threadId_ahk2, 'Ptr', 0, 'Cdecl')

if (StrGet(value_input_var) == "value_input_var") 
	FileAppend "AutoHotkey2 read and write global variable - OK`n", test_result_Path    
else 
	FileAppend "AutoHotkey2 read and write global variable - ERROR`n", test_result_Path  
	
;---------------------------------------------------------------------------------------------------	

;---------------------------Тест передачи сообщением из AHK1 в AHK2---------------------------------


;---------------------------------------------------------------------------------------------------	

MsgBox "Тест завершен"
;------читаем переменную input_variable из AutoHotkey
test_message :=Buffer(1000)
test_message := DllCall(ahkGetVar2, 'Str', 'test_value_string_message',  'UInt', 0, 'UInt', threadId_ahk2, 'Ptr', 0, 'Cdecl')
FileAppend StrGet(test_message) . "`n", test_result_Path   
test_message:=Buffer(1000)
DllCall(KEahkgetvar, 'Str', 'test_value_string_message', 'Ptr', test_message, 'UInt', 1000, 'UInt', 0, 'Cdecl')
FileAppend StrGet(test_message) . "`n", test_result_Path  

test_message := DllCall(ahkGetVar2, 'Str', 'test_value_float_message',  'UInt', 0, 'UInt', threadId_ahk2, 'Ptr', 0, 'Cdecl')
FileAppend StrGet(test_message) . "`n", test_result_Path   
test_message:=Buffer(1000)
DllCall(KEahkgetvar, 'Str', 'test_value_float_message', 'Ptr', test_message, 'UInt', 1000, 'UInt', 0, 'Cdecl')
FileAppend StrGet(test_message) . "`n", test_result_Path  

test_message := DllCall(ahkGetVar2, 'Str', 'test_value_int_message',  'UInt', 0, 'UInt', threadId_ahk2, 'Ptr', 0, 'Cdecl')
FileAppend StrGet(test_message) . "`n", test_result_Path   
test_message:=Buffer(1000)
DllCall(KEahkgetvar, 'Str', 'test_value_int_message', 'Ptr', test_message, 'UInt', 1000, 'UInt', 0, 'Cdecl')
FileAppend StrGet(test_message) . "`n", test_result_Path  

test_message := DllCall(ahkGetVar2, 'Str', 'test_var_string_message',  'UInt', 0, 'UInt', threadId_ahk2, 'Ptr', 0, 'Cdecl')
FileAppend StrGet(test_message) . "`n", test_result_Path   
test_message:=Buffer(1000)
DllCall(KEahkgetvar, 'Str', 'test_var_string_message', 'Ptr', test_message, 'UInt', 1000, 'UInt', 0, 'Cdecl')
FileAppend StrGet(test_message) . "`n", test_result_Path  

test_message := DllCall(ahkGetVar2, 'Str', 'test_var_float_message',  'UInt', 0, 'UInt', threadId_ahk2, 'Ptr', 0, 'Cdecl')
FileAppend StrGet(test_message) . "`n", test_result_Path   
test_message:=Buffer(1000)
DllCall(KEahkgetvar, 'Str', 'test_var_float_message', 'Ptr', test_message, 'UInt', 1000, 'UInt', 0, 'Cdecl')
FileAppend StrGet(test_message) . "`n", test_result_Path  

test_message := DllCall(ahkGetVar2, 'Str', 'test_var_int_message',  'UInt', 0, 'UInt', threadId_ahk2, 'Ptr', 0, 'Cdecl')
FileAppend StrGet(test_message) . "`n", test_result_Path   
test_message:=Buffer(1000)
DllCall(KEahkgetvar, 'Str', 'test_var_int_message', 'Ptr', test_message, 'UInt', 1000, 'UInt', 0, 'Cdecl')
FileAppend StrGet(test_message) . "`n", test_result_Path  




;DllCall(KEahkgetvar, 'Str', 'arr_string', 'Str', Buf , 'UInt', bufcount, 'UInt', 0, 'Cdecl')
