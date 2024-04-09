#Requires AutoHotkey v2

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
KEahkGetVar2 := DllCall('GetProcAddress', 'Ptr', hLib2, 'AStr', 'KEahkGetVar', 'Ptr')
ahkSetHwndKew2 := DllCall('GetProcAddress', 'Ptr', hLib2, 'AStr', 'ahkSetHwndKew', 'Ptr')
ahkSetHwndThreadKew2 := DllCall('GetProcAddress', 'Ptr', hLib2, 'AStr', 'ahkSetHwndThreadKew', 'Ptr')
ahkTerminateScript2 := DllCall('GetProcAddress', 'Ptr', hLib2, 'AStr', 'ahkTerminateScript', 'Ptr')
ahkGetWindow2 := DllCall('GetProcAddress', 'Ptr', hLib2, 'AStr', 'ahkGetWindow', 'Ptr')
ahkgetglobalvarvalues2 := DllCall('GetProcAddress', 'Ptr', hLib2, 'AStr', 'ahkgetglobalvarvalues', 'Ptr')

if (!addScript2 || !NewThread || !ahkReady2 || !ahkAssign2 || !KEahkGetVar2 || !ahkSetHwndKew2 || !ahkSetHwndThreadKew2 || !ahkTerminateScript2 || !ahkGetWindow2 || !ahkgetglobalvarvalues2){
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
MsgBox hwnd_ahk
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
	
	DllCall(ahkAssign2, 'Str', 'test_result_Path', 'Str', test_result_Path, 'UInt', threadId_ahk2, 'UInt', 0, 'Cdecl')
	
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
value_input_var := DllCall(KEahkGetVar2, 'Str', 'input_variable',  'UInt', 0, 'UInt', threadId_ahk2, 'Ptr', 0, 'Cdecl')

if (StrGet(value_input_var) == "value_input_var") 
	FileAppend "AutoHotkey2 read and write global variable - OK`n", test_result_Path    
else 
	FileAppend "AutoHotkey2 read and write global variable - ERROR`n", test_result_Path  
	
	
	
	
	
	
;------читаем переменную VarString из AutoHotkey
value_input_var :=Buffer(1000)
DllCall(KEahkgetvar, 'Str', 'VarString', 'Ptr', value_input_var, 'UInt', 1000, 'UInt', 0, 'Cdecl')
result :=StrGet(value_input_var)
if (Instr(result,"test")) 
	FileAppend "AutoHotkey read VarString global variable - OK " . StrGet(value_input_var) . "`n", test_result_Path    
else 
	FileAppend "AutoHotkey read VarString global variable - ERROR " . StrGet(value_input_var) . "`n", test_result_Path  	
	
	
value_input_var := DllCall(KEahkGetVar2, 'Str', 'VarString',  'UInt', 0, 'UInt', threadId_ahk2, 'Ptr', 0, 'Cdecl')
result :=StrGet(value_input_var)
if ( Instr(result,"test") ) 
	FileAppend "AutoHotkey2 read VarString global variable - OK " . StrGet(value_input_var) . "`n", test_result_Path    
else 
	FileAppend "AutoHotkey2 read VarString global variable - ERROR " . StrGet(value_input_var) . "`n", test_result_Path  	
	
	
	;------читаем переменную VarInteger из AutoHotkey
value_input_var :=Buffer(1000)
DllCall(KEahkgetvar, 'Str', 'VarInteger', 'Ptr', value_input_var, 'UInt', 1000, 'UInt', 0, 'Cdecl')
result :=StrGet(value_input_var)
if ( Instr(result,"123") ) 
	FileAppend "AutoHotkey read VarInteger global variable - OK " . StrGet(value_input_var) . "`n", test_result_Path    
else 
	FileAppend "AutoHotkey read VarInteger global variable - ERROR " . StrGet(value_input_var) . "`n", test_result_Path  	
	
	
value_input_var := DllCall(KEahkGetVar2, 'Str', 'VarInteger',  'UInt', 0, 'UInt', threadId_ahk2, 'Ptr', 0, 'Cdecl')
result :=StrGet(value_input_var)
if ( Instr(result,"123") ) 
	FileAppend "AutoHotkey2 read VarInteger global variable - OK " . StrGet(value_input_var) . "`n", test_result_Path    
else 
	FileAppend "AutoHotkey2 read VarInteger global variable - ERROR " . StrGet(value_input_var) . "`n", test_result_Path  
	
	
	;------читаем переменную VarFloat из AutoHotkey
value_input_var :=Buffer(1000)
DllCall(KEahkgetvar, 'Str', 'VarFloat', 'Ptr', value_input_var, 'UInt', 1000, 'UInt', 0, 'Cdecl')
result :=StrGet(value_input_var)
if ( Instr(result,"33.3")) 
	FileAppend "AutoHotkey read VarFloat global variable - OK " . StrGet(value_input_var) . "`n", test_result_Path    
else 
	FileAppend "AutoHotkey read VarFloat global variable - ERROR " . StrGet(value_input_var) . "`n", test_result_Path  	
	
	
value_input_var := DllCall(KEahkGetVar2, 'Str', 'VarFloat',  'UInt', 0, 'UInt', threadId_ahk2, 'Ptr', 0, 'Cdecl')
result :=StrGet(value_input_var)
if ( Instr(result,"33.3")) 
	FileAppend "AutoHotkey2 read VarFloat global variable - OK " . StrGet(value_input_var) . "`n", test_result_Path    
else 
	FileAppend "AutoHotkey2 read VarFloat global variable - ERROR " . StrGet(value_input_var) . "`n", test_result_Path  	
	
	
	
	
	
	
	
	
;------читаем массив arr_int из AutoHotkey
value_input_var :=Buffer(1000)
DllCall(KEahkgetvar, 'Str', 'arr_int', 'Ptr', value_input_var, 'UInt', 1000, 'UInt', 0, 'Cdecl')
result :=StrGet(value_input_var)
if ( Instr(result,"id") && Instr(result,"value")) 
	FileAppend "AutoHotkey read arr_int global variable - OK " . StrGet(value_input_var) . "`n", test_result_Path    
else 
	FileAppend "AutoHotkey read arr_int global variable - ERROR " . StrGet(value_input_var) . "`n", test_result_Path  	
	
	
value_input_var := DllCall(KEahkGetVar2, 'Str', 'arr_int',  'UInt', 0, 'UInt', threadId_ahk2, 'Ptr', 0, 'Cdecl')
result :=StrGet(value_input_var)
if ( Instr(result,"id") && Instr(result,"value")) 
	FileAppend "AutoHotkey2 read arr_int global variable - OK " . StrGet(value_input_var) . "`n", test_result_Path    
else 
	FileAppend "AutoHotkey2 read arr_int global variable - ERROR " . StrGet(value_input_var) . "`n", test_result_Path  	
		
;------читаем массив arr_float из AutoHotkey
value_input_var :=Buffer(1000)
DllCall(KEahkgetvar, 'Str', 'arr_float', 'Ptr', value_input_var, 'UInt', 1000, 'UInt', 0, 'Cdecl')
result :=StrGet(value_input_var)
if ( Instr(result,"id") && Instr(result,"value")) 
	FileAppend "AutoHotkey read arr_float global variable - OK " . StrGet(value_input_var) . "`n", test_result_Path    
else 
	FileAppend "AutoHotkey read arr_float global variable - ERROR " . StrGet(value_input_var) . "`n", test_result_Path  	
	
	
value_input_var := DllCall(KEahkGetVar2, 'Str', 'arr_float',  'UInt', 0, 'UInt', threadId_ahk2, 'Ptr', 0, 'Cdecl')
result :=StrGet(value_input_var)
if ( Instr(result,"id") && Instr(result,"value")) 
	FileAppend "AutoHotkey2 read arr_float global variable - OK " . StrGet(value_input_var) . "`n", test_result_Path    
else 
	FileAppend "AutoHotkey2 read arr_float global variable - ERROR " . StrGet(value_input_var) . "`n", test_result_Path  	
	
	
;------читаем массив arr_string из AutoHotkey
value_input_var :=Buffer(1000)
DllCall(KEahkgetvar, 'Str', 'arr_string', 'Ptr', value_input_var, 'UInt', 1000, 'UInt', 0, 'Cdecl')
result :=StrGet(value_input_var)
if ( Instr(result,"id") && Instr(result,"value")) 
	FileAppend "AutoHotkey read arr_string global variable - OK " . StrGet(value_input_var) . "`n", test_result_Path    
else 
	FileAppend "AutoHotkey read arr_string global variable - ERROR " . StrGet(value_input_var) . "`n", test_result_Path  	
	
	
value_input_var := DllCall(KEahkGetVar2, 'Str', 'arr_string',  'UInt', 0, 'UInt', threadId_ahk2, 'Ptr', 0, 'Cdecl')
result :=StrGet(value_input_var)
if ( Instr(result,"id") && Instr(result,"value")) 
	FileAppend "AutoHotkey2 read arr_string global variable - OK " . StrGet(value_input_var) . "`n", test_result_Path    
else 
	FileAppend "AutoHotkey2 read arr_string global variable - ERROR " . StrGet(value_input_var) . "`n", test_result_Path  	
;---------------------------------------------------------------------------------------------------	

;---------------------------Тест передачи сообщением из AHK1 в AHK2---------------------------------


;---------------------------------------------------------------------------------------------------	

MsgBox "Тест завершен"

