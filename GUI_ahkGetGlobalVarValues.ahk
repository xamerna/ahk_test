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


ahktextdll     := DllCall('GetProcAddress', 'Ptr', hLib, 'AStr', 'ahktextdll'    , 'Ptr')
;NewThread     := DllCall('GetProcAddress', 'Ptr', hLib, 'AStr', 'NewThread'    , 'Ptr')
;ahkSetHwndKew := DllCall('GetProcAddress', 'Ptr', hLib, 'AStr', 'ahkSetHwndKew', 'Ptr')

wnd := Gui('AlwaysOnTop')
wnd.OnEvent('Close', (*) => ExitApp())
wnd.SetFont('s16', 'Calibri')
wnd.MarginX := 50
wnd.MarginY := 30
CheckBox := wnd.AddCheckbox(, 'Mute')
MSG := Messaging((param, value) => CheckBox.Value := value)
CheckBox.OnEvent('Click', (*) => MSG.SendParam('NewMute', CheckBox.Value))
wnd.Show('x200')

MsgBox "start1"

script := FileRead('test.ahk')
DllCall(ahktextdll, 'Str', script, 'Str', '1 ' . A_ScriptHwnd . ' "local test"', 'Str', 'MuteControl.v2.ahk',  'Ptr', 0, 'Cdecl')
;DllCall(NewThread, 'Str', script, 'Str', '1 ' . A_ScriptHwnd . ' "local test"', 'Str', 'MuteControl.v2.ahk', 'UInt', 0, 'Int', Cdecl)
;DllCall(ahkSetHwndKew, 'Ptr', A_ScriptHwnd, 'UInt', 1, 'UInt', 0, 'Cdecl')
HostWindowHandle := HostEngineThreadId := WinWait('MuteControl.v2.ahk')
;HostWindowHandle := HostEngineThreadId := WinWait('THREAD ahk_class AutoHotkey')
MsgBox HostWindowHandle
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
            ; these gobal variables get values ​​when the plugin starts, they are required to send messages to KEW
            global HostWindowHandle, HostEngineThreadId

            (!IsSet(HostWindowHandle) && HostWindowHandle := 0)
            (!IsSet(HostEngineThreadId) && HostEngineThreadId := 0)

            while !(HostWindowHandle && HostEngineThreadId) {
                Sleep 10
            }
            this.SendString(HostWindowHandle, HostEngineThreadId, param . ':' . value)
        }

        static SendString(hWnd, engineThreadId, str) {
            NumPut('Ptr', engineThreadId,
                    'Ptr', StrPut(str, 'UTF-16'),
                    'Ptr', StrPtr(str), COPYDATASTRUCT := Buffer(A_PtrSize * 3, 0))
            DllCall('SendMessage', 'Ptr', hWnd, 'UInt', WM_COPYDATA := 0x4A, 'Ptr', 0, 'Ptr', COPYDATASTRUCT)
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