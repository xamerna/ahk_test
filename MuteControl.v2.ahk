/*
Input params:
NewMute       0 or 1

Output params:
CurrentMute   0 or 1
*/

#Requires AutoHotkey v2
#NoTrayIcon
Persistent
DetectHiddenWindows true

ar_ar :=[11.33 , 22.33 , 33.33]
	ar_value :=[ar_ar , ar_ar]
	ar_name := ["out","arr"]
	
    KEPluginParamOutput(ar_name,ar_value,A_ScriptHwnd)
	
	MsgBox "stop"

if A_Args.Has(2) && A_Args[2] = 'local test' {
    HostWindowHandle := HostEngineThreadId := Number(A_Args[1])
}
MMC := MasterMuteControl(SendInfo)
SendInfo(MMC.GetMute())

SendInfo(currentMute) {
    global HostWindowHandle
	
	ar_ar :=[11 , 22 , 33]
	ar_value :=[ar_ar , ar_ar]
	ar_name := ["out","arr"]
	
    KEPluginParamOutput(ar_name,ar_value)
  ; KEPluginParamOutput('CurrentMute', currentMute, HostWindowHandle)
}

OnKEPluginParamInput((param, value) => (param = 'NewMute' && MMC.SetMute(Number(value))))

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

class MasterMuteControl
{
    __New(OnVolumeChange) {
        this.AudioEndpointVolume := IAudioEndpointVolume.Create()
        this.AudioEndpointVolumeCallback := IAudioEndpointVolumeCallback(OnVolumeChange)
        this.AudioEndpointVolume.RegisterControlChangeNotify(this.AudioEndpointVolumeCallback.ptr)
    }

    __Delete() {
        this.AudioEndpointVolume.UnregisterControlChangeNotify(this.AudioEndpointVolumeCallback.ptr)
        this.AudioEndpointVolumeCallback := ''
        this.AudioEndpointVolume := ''
    }

    SetMute(mute) => this.AudioEndpointVolume.SetMute(!!mute)

    GetMute()     => this.AudioEndpointVolume.GetMute()
}

class IAudioEndpointVolume extends InterfaceBase
{
    static IID_IAudioEndpointVolume := '{5CDF2C82-841E-4546-9722-0CF74078229A}'
    
    static Create() {
        static eRender := 0, eConsole := 0, CLSCTX_ALL := 0x00000007
        MMDeviceEnumerator := IMMDeviceEnumerator.Create()
        MMDevice := MMDeviceEnumerator.GetDefaultAudioEndpoint(eRender, eConsole)
        DllCall('Ole32\CLSIDFromString', 'Str', this.IID_IAudioEndpointVolume, 'Ptr', CLSID := Buffer(16))
        pIAudioEndpointVolume := MMDevice.Activate(CLSID, CLSCTX_ALL, 0)
        return IAudioEndpointVolume(pIAudioEndpointVolume)
    }
    RegisterControlChangeNotify(pAudioEndpointVolumeCallback)   => ComCall(3, this, 'Ptr', pAudioEndpointVolumeCallback)

    UnregisterControlChangeNotify(pAudioEndpointVolumeCallback) => ComCall(4, this, 'Ptr', pAudioEndpointVolumeCallback)

    SetMute(bMute, pguidEventContext := 0) =>  ComCall(14, this, 'UInt' , bMute, 'Ptr', pguidEventContext)

    GetMute()                              => (ComCall(15, this, 'UIntP', &bMute := 0), bMute)
}

class IMMDeviceEnumerator extends InterfaceBase
{
    static CLSID_MMDeviceEnumerator := '{BCDE0395-E52F-467C-8E3D-C4579291692E}'
          , IID_IMMDeviceEnumerator := '{A95664D2-9614-4F35-A746-DE8DB63617E6}'

    static Create() => IMMDeviceEnumerator( ComObject(this.CLSID_MMDeviceEnumerator, this.IID_IMMDeviceEnumerator) )

    GetDefaultAudioEndpoint(dataFlow, role) {
        ComCall(4, this, 'Int', dataFlow, 'Int', role, 'PtrP', &pIMMDevice := 0)
        return IMMDevice(pIMMDevice)
    }
}

class IMMDevice extends InterfaceBase
{
    Activate(riid, dwClsCtx, pActivationParams := 0) {
        ComCall(3, this, 'Ptr', riid, 'UInt', dwClsCtx, 'Ptr', pActivationParams, 'PtrP', &pInterface := 0)
        return pInterface
    }
}

class InterfaceBase
{
    __New(ptr) {
        this.comObj := Type(ptr) = 'ComValue' ? ptr : ComValue(VT_UNKNOWN := 0xD, ptr)
        this.ptr := this.comObj.ptr
    }
}

class IAudioEndpointVolumeCallback
{
    __New(callback) {
        this.callback := callback
        this.vtable := this.CreateVTable()
        this.ptr := this.vtable.ptr
    }

    CreateVTable() {
        Methods := [
            {name: 'QueryInterface', paramCount: 3},
            {name: 'AddRef'        , paramCount: 1},
            {name: 'Release'       , paramCount: 1},
            {name: 'OnNotify'      , paramCount: 2}
        ]
        vtable := Buffer(A_PtrSize * (Methods.Length + 1))
        NumPut('Ptr', vtable.ptr + A_PtrSize, vtable)
        for k, v in Methods {
            NumPut('Ptr', RegisterSyncCallback(%v.name%,, v.paramCount), vtable, A_PtrSize * k)
        }
        return vtable

        QueryInterface(self, riid, pObj) {
            static IID_IUnknown                     := '{00000000-0000-0000-C000-000000000046}'
                 , IID_IAudioEndpointVolumeCallback := '{657804FA-D6AD-4496-8A60-352752AF4F89}'
                 , E_NOINTERFACE := 0x80004002, S_OK := 0

            DllCall('Ole32\StringFromGUID2', 'Ptr', riid, 'Ptr', buf := Buffer(78), 'Int', 39)
            str := StrGet(buf)
            if !(str = IID_IUnknown || str = IID_IAudioEndpointVolumeCallback)
                return E_NOINTERFACE
            else {
                NumPut('Ptr', self, pObj)
                return S_OK
            }
        }

        AddRef(self)  => 1
        Release(self) => 1

        OnNotify(self, pNotify) {
            newMute := NumGet(pNotify, 16, 'UInt')
            SetTimer this.callback.Bind(newMute), -10
            return 0
        }
    }

    __Delete() {
        Loop 4 {
            DllCall('GlobalFree', 'Ptr', NumGet(this.vtable, A_PtrSize * A_Index, 'Ptr'), 'Ptr')
        }
    }
}

RegisterSyncCallback(funcObj, options := '', paramCount?) {
    static wnd := '', msg := 0x8000, SendMessageW := 0

    (!IsSet(paramCount) && paramCount := funcObj.MinParams)
    if IsSet(paramCount) && paramCount > funcObj.MaxParams {
        throw ValueError('Incorrect paramCount', paramCount)
    }
    if !wnd {
        wnd := Gui('+Parent' . A_ScriptHwnd)
        OnMessage(msg, RegisterSyncCallback_Msg)
        hModule := DllCall('GetModuleHandle', 'Str', 'user32.dll', 'Ptr')
        SendMessageW := DllCall('GetProcAddress', 'Ptr', hModule, 'AStr', 'SendMessageW', 'Ptr')
    }
    pcb := DllCall('GlobalAlloc', 'UInt', 0, 'Ptr', 96, 'Ptr')
    DllCall('VirtualProtect', 'Ptr', pcb, 'Ptr', 96, 'UInt', 0x40, 'UInt*', 0)

    p := pcb
    if A_PtrSize = 8 {
        /*
        48 89 4c 24 08  ; mov [rsp+8], rcx
        48 89 54'24 10  ; mov [rsp+16], rdx
        4c 89 44 24 18  ; mov [rsp+24], r8
        4c'89 4c 24 20  ; mov [rsp+32], r9
        48 83 ec 28'    ; sub rsp, 40
        4c 8d 44 24 30  ; lea r8, [rsp+48]  (arg 3, &params)
        49 b9 ..        ; mov r9, .. (arg 4, operand to follow)
        */
        p := NumPut('Ptr'  , 0x54894808244c8948,
                    'Ptr'  , 0x4c182444894c1024,
                    'Ptr'  , 0x28ec834820244c89,
                    'Ptr'  , 0x00b9493024448d4c, p) - 1
        lParamPtr := p, p += 8

        p := NumPut('Char' , 0xba,        ; mov edx, nmsg
                    'Int'  , msg, 
                    'Char' , 0xb9,        ; mov ecx, hwnd
                    'Int'  , wnd.hwnd, 
                    'Short', 0xb848,      ; mov rax, SendMessageW
                    'Ptr'  , SendMessageW,
                            /*
                            ff d0         ; call rax
                            48 83 c4 28   ; add rsp, 40
                            c3            ; ret
                            */
                    'Ptr'  , 0x00c328c48348d0ff, p)
    } else {
        p := NumPut('Char' , 0x68, p)     ; push ... (lParam data)
        lParamPtr := p, p += 4
        p := NumPut('Int'  , 0x0824448d,  ; lea eax, [esp+8]
                    'Char' , 0x50,        ; push eax
                    'Char' , 0x68,        ; push nmsg
                    'Int'  , msg, 
                    'Char' , 0x68,        ; push hwnd
                    'Int'  , wnd.hwnd, 
                    'Char' , 0xb8,        ; mov eax, &SendMessageW
                    'Int'  , SendMessageW,
                    'Short', 0xd0ff,      ; call eax
                    'Char' , 0xc2,        ; ret argsize
                    'Short', InStr(options, 'C') ? 0 : paramCount * 4, p)
    }
    NumPut('Ptr', p, lParamPtr)
    NumPut('Ptr', ObjPtrAddRef(funcObj),
           'Int', paramCount, p)
    return pcb

    RegisterSyncCallback_Msg(wParam, lParam, msg, hwnd) {
        if hwnd != wnd.hwnd {
            return
        }
        fn := ObjFromPtrAddRef(NumGet(lParam, 'Ptr'))
        paramCount := NumGet(lParam, A_PtrSize, 'Int')
        params := []
        Loop paramCount {
            params.Push(NumGet(wParam, A_PtrSize * (A_Index - 1), 'Ptr'))
        }
        return fn(params*)
    }
}