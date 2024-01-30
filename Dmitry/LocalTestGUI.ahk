#Requires AutoHotkey v2
DetectHiddenWindows true
SetTitleMatchMode 2
ScriptWindowHandle2:=0

wnd := Gui('AlwaysOnTop', 'Volume control')
wnd.MarginX := wnd.MarginY := 25
wnd.SetFont('s12', 'Calibri')
wnd.AddText(, 'Volume:')

volumeText   := wnd.AddText('x+5 yp left w60')
volumeSlider := wnd.AddSlider('xm y+5 h30 TickInterval10 AltSubmit')

volumeSlider.OnEvent('Change', (sl, *) => MSG.SendParam('newVolume', volumeText.Value := sl.Value))
checkMute := wnd.AddCheckbox('y+10', 'Mute')
checkMute.OnEvent(   'Click' , (ch, *) => MSG.SendParam('newMute', ch.Value))

MSG := Messaging(SetValues)
ScriptWindowHandle := RunScriptWithAutoHotkeyDll('MasterVolumeControl.ahk')

wnd.Show()



SetValues(param, value) {
    switch param {
        case 'currentMute'  : checkMute.Value := !!value
        case 'currentVolume': volumeText.Value := volumeSlider.Value := value
    }
}

class Messaging
{
    __New(UserOnMessageFunc?) {

        if Messaging.HasProp('singleton') {
            ObjSetBase(this, {})
            return Messaging.singleton
        }
        Messaging.singleton := this
        ObjRelease(ObjPtr(this))
        if IsSet(UserOnMessageFunc) {
            Messaging.Receiver.Init(UserOnMessageFunc)
        }
    }
    
    __Delete() {
        ObjAddRef(ObjPtr(this))
        Messaging.DeleteProp('singleton')
        Messaging.Receiver.Clear()
    }

    static SendParam(param, value) => Messaging.Sender.SendParam(param, value)
    
    SendParam(param, value) => Messaging.Sender.SendParam(param, value)

    class Sender {

        static SendParam(param, value) {
            global ScriptWindowHandle
            while !IsSet(ScriptWindowHandle) || !ScriptWindowHandle {
                Sleep 10
            }
            this.SendString(ScriptWindowHandle, param . ':' . value)
        }


        static SendString(hWnd, str) {
			global ScriptWindowHandle2
			;MsgBox hWnd
			;MsgBox ScriptWindowHandle2
			
            NumPut('Ptr', StrPut(str, 'UTF-16'), 'Ptr', StrPtr(str), COPYDATASTRUCT := Buffer(A_PtrSize * 3, 0), A_PtrSize)
            DllCall('SendMessage', 'Ptr', ScriptWindowHandle2, 'UInt',  0x004A, 'Ptr', 0, 'Ptr', COPYDATASTRUCT)
			
        }
    }

    class Receiver {

        static WM_COPYDATA := 0x4A

        static Init(UserFunc) {
            this.dataArr := []
            this.timer := ObjBindMethod(this, 'MessageProcessing', UserFunc)
            OnMessage(this.WM_COPYDATA, this.onMsg := ObjBindMethod(this, 'CopyDataRead'))
        }

        static CopyDataRead(wp, lp, *) {
            data := StrGet(NumGet(lp + A_PtrSize*2, 'Ptr'))
            this.dataArr.Push(data)
            SetTimer this.timer, -10
            return true
        }

        static MessageProcessing(UserFunc) {
            while this.dataArr.Has(1) {
                data := this.dataArr.RemoveAt(1)
                if RegExMatch(data, 's)^(?<param>.*?):(?<value>.*)', &m := '') {
                    UserFunc(m.param, m.value)
                } else {
                    Critical
                    MsgBox 'The data came in the wrong format: ' . data, 'Error', 0x10
                }
            }
        }

        static Clear() => this.HasProp('onMsg') && OnMessage(this.WM_COPYDATA, this.onMsg, 0)
    }
}

RunScriptWithAutoHotkeyDll(scriptPath, initMsg := true, params*) {
    #SingleInstance Force
    DetectHiddenWindows true
    SetTitleMatchMode 2

    if !(A_Args.Has(1) && FileExist(ahkDllPath := A_Args[1])) {
        ahkDllPath := ChooseModule()
    }
    ReloadWithAppropriateInterpreter(ahkDllPath)
    
    if !hLib := DllCall('LoadLibrary', 'Str', ahkDllPath, 'Ptr') {
        throw OSError('Failed to load AutoHotkey.dll')
    }
    GetFunctions(&NewThread := 0, &ahkSetHwndKew := 0,&ahkgetwindow := 0)
    
    IniWrite(ahkDllPath, 'settings.ini', 'Paths', 'AutoHotkeyDll')
    sParams := ''
    for param in params {
        sParams .= ' "' . param . '"'
    }
    script := FileRead(scriptPath)
    SplitPath scriptPath, &name
    threadId := DllCall(NewThread, 'Str', script, 'Str', sParams, 'Str', name, 'Cdecl Ptr')
    DllCall(ahkSetHwndKew, 'Ptr', A_ScriptHwnd, 'UInt', 1, 'UInt', threadId, 'Cdecl')
	global ScriptWindowHandle2
	ScriptWindowHandle2 := DllCall(ahkgetwindow, 'Cdecl Ptr')
	;MsgBox ScriptWindowHandle2

    return WinWait('ahk_class AutoHotkey ahk_pid ' . DllCall('GetCurrentProcessId'),,, A_ScriptHwnd)

    GetFunctions(&NewThread, &ahkSetHwndKew, &ahkgetwindow) {
        if !NewThread := DllCall('GetProcAddress', 'Ptr', hLib, 'AStr', 'ahktextdll', 'Ptr') {
            MsgBox 'Функция NewThread не найдена среди экспортируемых dll, скрипт будет завершён', 'NewThread не найдена', 0x10
            ExitApp
        }
        if initMsg && !(ahkSetHwndKew := DllCall('GetProcAddress', 'Ptr', hLib, 'AStr', 'ahkSetHwndKew', 'Ptr')) {
            MsgBox 'Функция ahkSetHwndKew не найдена среди экспортируемых dll, скрипт будет завершён', 'ahkSetHwndKew не найдена', 0x10
            ExitApp
        }
		if initMsg && !(ahkgetwindow := DllCall('GetProcAddress', 'Ptr', hLib, 'AStr', 'ahkgetwindow', 'Ptr')) {
            MsgBox 'Функция ahkgetwindow не найдена среди экспортируемых dll, скрипт будет завершён', 'ahkSetHwndKew не найдена', 0x10
            ExitApp
        }
    }

    static ChooseModule(bitness?) {
        b := IsSet(bitness)
        wnd := Gui('OwnDialogs', 'Выбор AutoHotkey' . (b ? bitness . '.exe' : '.dll'))
        wnd.OnEvent('Close', (*) => ExitApp())
        wnd.OnEvent('DropFiles', OnDropFile)
        wnd.MarginX := 20
        wnd.MarginY := 25
        wnd.SetFont('s12', 'Calibri')
        wnd.AddText(, 'Укажите путь к AutoHotkey' . (b ? bitness . '.exe' : '.dll') . ' (можно перетащить):')
        prevAhkDllPath := ''
        (FileExist(p := IniRead('settings.ini', 'Paths', 'AutoHotkeyDll', '')) && prevAhkDllPath := p)
        editObj := wnd.AddEdit('xm y+5 h24', prevAhkDllPath)
        ControlGetPos(,, &w,, editObj)
        w *= 96 / A_ScreenDPI
        maxEditWidth := 350
        if (m := w > maxEditWidth || !prevAhkDllPath) {
            ControlMove(,, maxEditWidth * A_ScreenDPI / 96,, editObj)
        }
        selDll := wnd.AddButton((m ? 'x' . wnd.MarginX + maxEditWidth + 5 : 'x+5') . ' yp w24 hp', '...')
        selDll.OnEvent('Click', SelectModule)
        ControlGetPos(&x,,,, selDll)
        x *= 96 / A_ScreenDPI
        guiWidth := wnd.MarginX + x + 24
        buttWidth := 100
        ahkModulePath := ''
        wnd.AddButton('x' . (guiWidth - buttWidth) / 2 . ' y+20 hp w' . buttWidth . ' Default', 'OK').OnEvent('Click', (*) => (
            (FileExist(ahkModulePath := editObj.Value) && wnd.Destroy())
        ))
        wnd.Show('AutoSize')
        SendMessage EM_SETSEL := 0xB1, -2, -1, editObj
        WinWaitClose(wnd)
        return ahkModulePath

        OnDropFile(gui, ctrl, fileArr, *) {
            filePath := fileArr[1]
            btns := GetModuleBitness(filePath)
            if b && btns != bitness {
                MsgBox(btns ? 'Перетащите сюда AutoHotkey.' . bitness . 'exe'
                            : 'Это не исполняемый файл, перетащите сюда AutoHotkey.' . bitness . 'exe', ' ', 0x30)
                return
            }
            SplitPath(filePath, &fileName)
            (fileName ~= 'i)AutoHotkey.*\.' . (b ? 'exe' : 'dll')
                ? (editObj.Value := filePath, SendMessage(EM_SETSEL := 0xB1, -2, -1, editObj))
                : MsgBox('Перетащите сюда AutoHotkey.' . (b ? bitness . 'exe' : 'dll') . ' файл', ' ', 0x30))
        }

        SelectModule(*) {
            Loop {
                modulePath := FileSelect(
                    1, A_ScriptDir, 'Select AutoHotkey.' . (b ? bitness . 'exe' : 'dll'), (b ? 'exe (*.exe)' : 'dll (*.dll)')
                )
                if !modulePath {
                    ExitApp
                }
                if b {
                    if GetModuleBitness(modulePath) != bitness {
                        if MsgBox('Выберите ' . bitness . '-битный AHK интерпретатор!', ' ', 0x35) = 'Cancel' {
                            ExitApp
                        }
                        continue
                    }
                }
                break
            }
            editObj.Value := modulePath
            SendMessage EM_SETSEL := 0xB1, -2, -1, editObj
        }
    }

    static ReloadWithAppropriateInterpreter(ahkDllPath) {
        bitness := GetModuleBitness(ahkDllPath)
        if A_PtrSize != bitness // 8 {
            if !FileExist((exePath := A_AhkPath . '\..\AutoHotkey' . bitness . '.exe')
                       || (exePath := IniRead('settings.ini', 'Paths', bitness . 'bitAhkExePath', ''))) {
                exePath := ChooseModule(bitness)
            }
            IniWrite exePath, 'settings.ini', 'Paths', bitness . 'bitAhkExePath'
            Run exePath . ' "' . A_ScriptFullPath . '" "' . ahkDllPath . '"'
            ExitApp
        }
    }

    static GetModuleBitness(filePath) {
        fileObj := FileOpen(filePath, 'r')
        fileObj.Pos := 0
        if fileObj.ReadShort() != 0x5A4D {
            return 0 ; the file is not executable
        }
        fileObj.Pos := 0x3C
        fileObj.Pos := fileObj.ReadUInt() + 4
        return Map(0x8664, 64, 0x014C, 32)[fileObj.ReadUShort()]
    }
}

SysError(nError?)
{
    static flags := (FORMAT_MESSAGE_ALLOCATE_BUFFER := 0x100) | (FORMAT_MESSAGE_FROM_SYSTEM := 0x1000)
    nError ?? nError := A_LastError
    DllCall('FormatMessage', 'UInt', flags, 'UInt', 0, 'UInt', nError, 'UInt', 0, 'PtrP', &pBuf := 0, 'UInt', 128, 'Ptr', 0)
    err := pBuf && (str := StrGet(pBuf)) ? str : nError . '`n'
    (pBuf && DllCall('LocalFree', 'Ptr', pBuf))
    return err
}