#NoEnv
#NoTrayIcon
SetBatchLines, -1
OnKEPluginParamInput("KEPluginParamInput")
VC := new MasterVolumeControl("SendInfo")
Sleep 100
KEPluginParamOutput("currentMute", VC.GetMute())
KEPluginParamOutput("currentVolume", VC.GetMasterVolume())
Return

SendInfo(currentMute, currentVolume) {
   static prevMute := prevVolume := ""
   if (currentMute != prevMute) {
      KEPluginParamOutput("currentMute", currentMute)
      prevMute := currentMute
   }
   if (currentVolume != prevVolume) {
      KEPluginParamOutput("currentVolume", currentVolume)
      prevVolume := currentVolume
   }
}

KEPluginParamInput(param, value) {
	global VC
   if (param = "newMute" && VC.GetMute() != !!value)
      VC.SetMute(!!value)
   if (param = "newVolume")
      VC.SetMasterVolume(value)
}

class MasterVolumeControl
{
   __New(OnVolumeChange) {
      this.AudioEndpointVolume := IAudioEndpointVolume.Create()
      UserFunc := IsObject(OnVolumeChange) ? OnVolumeChange : Func(OnVolumeChange)
      this.AudioEndpointVolumeCallback := new IAudioEndpointVolumeCallback(UserFunc)
      this.AudioEndpointVolume.RegisterControlChangeNotify( this.AudioEndpointVolumeCallback.ptr )
   }
   
   __Delete() {
      this.AudioEndpointVolume.UnregisterControlChangeNotify( this.AudioEndpointVolumeCallback.ptr )
      this.AudioEndpointVolumeCallback := ""
      this.AudioEndpointVolume := ""
   }
   
   SetMasterVolume(volume) { ; volume 0 — 100
      this.AudioEndpointVolume.SetMasterVolumeLevelScalar(volume/100)
   }
   
   GetMasterVolume() {
      Return Round( this.AudioEndpointVolume.GetMasterVolumeLevelScalar()*100 )
   }
   
   SetMute(mute) { ; mute — 0 or 1
      if (this.GetMute() != !!mute)
         this.AudioEndpointVolume.SetMute(!!mute)
   }
   
   GetMute() {
      Return this.AudioEndpointVolume.GetMute()
   }
}

class IAudioEndpointVolume extends _InterfaceBase
{
   Create() {
      static IID_IAudioEndpointVolume := "{5CDF2C82-841E-4546-9722-0CF74078229A}"
           , eRender := 0, eConsole := 0, CLSCTX_ALL := 0x00000007
      MMDeviceEnumerator := IMMDeviceEnumerator.Create()
      MMDevice := MMDeviceEnumerator.GetDefaultAudioEndpoint(eRender, eConsole)
      pIAudioEndpointVolume := MMDevice.Activate( CLSIDFromString(IID_IAudioEndpointVolume, _), CLSCTX_ALL, 0 )
      Return new IAudioEndpointVolume(pIAudioEndpointVolume)
   }
   RegisterControlChangeNotify(pAudioEndpointVolumeCallback) {
      hr := DllCall(this.VTable(3), "Ptr", this.ptr, "Ptr", pAudioEndpointVolumeCallback)
      this.IsError(A_ThisFunc, hr)
   }
   UnregisterControlChangeNotify(pAudioEndpointVolumeCallback) {
      hr := DllCall(this.VTable(4), "Ptr", this.ptr, "Ptr", pAudioEndpointVolumeCallback)
      this.IsError(A_ThisFunc, hr)
   }
   SetMasterVolumeLevelScalar(level, pguidEventContext := 0) {
      hr := DllCall(this.VTable(7), "Ptr", this.ptr, "Float", level, "Ptr", pguidEventContext)
      this.IsError(A_ThisFunc, hr)
   }
   GetMasterVolumeLevelScalar() {
      hr := DllCall(this.VTable(9), "Ptr", this.ptr, "FloatP", level)
      this.IsError(A_ThisFunc, hr)
      Return level
   }
   SetMute(bMute, pguidEventContext := 0) {
      hr := DllCall(this.VTable(14), "Ptr", this.ptr, "UInt", bMute, "Ptr", pguidEventContext)
      this.IsError(A_ThisFunc, hr)
   }
   GetMute() {
      hr := DllCall(this.VTable(15), "Ptr", this.ptr, "UIntP", bMute)
      this.IsError(A_ThisFunc, hr)
      Return bMute
   }
}

class IMMDeviceEnumerator extends _InterfaceBase
{
   Create() {
      static CLSID_MMDeviceEnumerator := "{BCDE0395-E52F-467C-8E3D-C4579291692E}"
            , IID_IMMDeviceEnumerator := "{A95664D2-9614-4F35-A746-DE8DB63617E6}"
      Return new IMMDeviceEnumerator( ComObjCreate(CLSID_MMDeviceEnumerator, IID_IMMDeviceEnumerator) )
   }
   GetDefaultAudioEndpoint(dataFlow, role) {
      hr := DllCall(this.VTable(4), "Ptr", this.ptr, "Int", dataFlow, "Int", role, "PtrP", pIMMDevice)
      this.IsError(A_ThisFunc, hr)
      Return new IMMDevice(pIMMDevice)
   }
}

class IMMDevice extends _InterfaceBase
{
   Activate(riid, dwClsCtx, pActivationParams := 0) {
      hr := DllCall(this.VTable(3), "Ptr", this.ptr, "Ptr", riid, "UInt", dwClsCtx, "Ptr", pActivationParams, "PtrP", pInterface)
      this.IsError(A_ThisFunc, hr)
      Return pInterface
   }
}

class _InterfaceBase
{
   __New(ptr) {
      this.ptr := ptr
   }
   __Delete() {
      ObjRelease(this.ptr)
   }
   VTable(idx) {
      Return NumGet(NumGet(this.ptr + 0) + A_PtrSize*idx)
   }
   IsError(method, result, exc := true) {
      if (result = 0)
         Return 0
      error := StrReplace(method, ".", "::") . " failed.`nResult: "
                              . ( result = "" ? "No result" : SysError(Format("{:#x}", result & 0xFFFFFFFF)) )
                              . "`nErrorLevel: " . ErrorLevel
      if !exc
         Return error
      throw error
   }
}

class IAudioEndpointVolumeCallback
{
   __New(UserFunc) {
      this.UserFunc := IsObject(UserFunc) ? UserFunc : Func(UserFunc)
      this._CreateVTable()
   }
   
   _CreateVTable() {
      static Methods := [ {name: "QueryInterface", paramCount: 3}
                        , {name: "AddRef"        , paramCount: 1}
                        , {name: "Release"       , paramCount: 1}
                        , {name: "OnNotify"      , paramCount: 2} ]
                        
      this.SetCapacity("vtable", A_PtrSize*(Methods.Count() + 1))
      pVtable := this.GetAddress("vtable")
      this.SetCapacity("IUnknown", A_PtrSize)
      this.ptr := this.GetAddress("IUnknown")
      NumPut(pVtable, this.ptr)
      
      this.Callbacks := []
      for k, v in Methods {
         Callback := RegisterSyncCallback("IAudioEndpointVolumeCallback_" . v.name,, v.paramCount)
         NumPut( Callback, pVtable + A_PtrSize*(k - 1) )
         this.Callbacks.Push(Callback)
      }
      NumPut( RegisterCallback(this.UserFunc, "Fast", 2), pVtable + A_PtrSize*(Methods.Count()) )
   }
   
   __Delete() {
      for k, v in this.Callbacks
         DllCall("GlobalFree", "Ptr", v, "Ptr")
      DllCall("GlobalFree", "Ptr", NumGet(this.GetAddress("vtable") + A_PtrSize*4), "Ptr")
      this.SetCapacity("vtable", 0)
      this.Delete("vtable")
   }
}

IAudioEndpointVolumeCallback_QueryInterface(this, riid, ppvObject) {
   static IID_IUnknown                     := "{00000000-0000-0000-C000-000000000046}"
        , IID_IAudioEndpointVolumeCallback := "{657804FA-D6AD-4496-8A60-352752AF4F89}"
        , E_NOINTERFACE := 0x80004002, S_OK := 0, _, __
        , p1 := CLSIDFromString(IID_IUnknown                    ,  _)
        , p2 := CLSIDFromString(IID_IAudioEndpointVolumeCallback, __)

   if !( DllCall("Ole32\IsEqualGUID", "Ptr", riid, "Ptr", p1)
      || DllCall("Ole32\IsEqualGUID", "Ptr", riid, "Ptr", p2) )
   { ; if riid doesn't match IID_IUnknown nor IID_IAudioEndpointVolumeCallback
      NumPut(0, ppvObject + 0)
      Return E_NOINTERFACE
   }
   else {
      NumPut(this, ppvObject + 0)
      DllCall(NumGet(NumGet(ppvObject + 0) + A_PtrSize), "Ptr", ppvObject)
      Return S_OK
   }
}

IAudioEndpointVolumeCallback_AddRef(this) {
   Return 1
}

IAudioEndpointVolumeCallback_Release(this) {
   Return 1
}

IAudioEndpointVolumeCallback_OnNotify(this, pNotify) {
   newMute   := NumGet(pNotify + 16, "UInt")
   newVolume := NumGet(pNotify + 20, "Float")
   addrUserFunc := NumGet(NumGet(this + 0) + A_PtrSize*4)
   timer := Func("DllCall").Bind(addrUserFunc, "UInt", newMute, "UInt", Round(newVolume * 100))
   SetTimer, % timer, -10
   Return 0
}

CLSIDFromString(IID, ByRef CLSID) {
   VarSetCapacity(CLSID, 16, 0)
   if res := DllCall("ole32\CLSIDFromString", "WStr", IID, "Ptr", &CLSID, "UInt")
      throw Exception("CLSIDFromString failed. Error: " . Format("{:#x}", res))
   Return &CLSID
}

SysError(ErrorNum := "")
{ 
   static flags := (FORMAT_MESSAGE_ALLOCATE_BUFFER := 0x100) | (FORMAT_MESSAGE_FROM_SYSTEM := 0x1000)
   (ErrorNum = "" && ErrorNum := A_LastError)
   DllCall("FormatMessage", "UInt", flags, "UInt", 0, "UInt", ErrorNum, "UInt", 0, "PtrP", pBuff, "UInt", 512, "Str", "")
   str := StrGet(pBuff), DllCall("LocalFree", "Ptr", pBuff)
   Return str? str : ErrorNum
}

/*
   RegisterSyncCallback

   A replacement for RegisterCallback for use with APIs that will call
   the callback on the wrong thread.  Synchronizes with the script's main
   thread via a window message.

   This version tries to emulate RegisterCallback as much as possible
   without using RegisterCallback, so shares most of its limitations,
   and some enhancements that could be made are not.

   Other differences from v1 RegisterCallback:
   - Variadic mode can't be emulated exactly, so is not supported.
   - A_EventInfo can't be set in v1, so is not supported.
   - Fast mode is not supported (the option is ignored).
   - ByRef parameters are allowed (but ByRef is ignored).
   - Throws instead of returning "" on failure.
*/
RegisterSyncCallback(FunctionName, Options:="", ParamCount:="")
{
   if !(fn := Func(FunctionName)) || fn.IsBuiltIn
      throw Exception("Bad function", -1, FunctionName)
   if (ParamCount == "")
      ParamCount := fn.MinParams
   if (ParamCount > fn.MaxParams && !fn.IsVariadic || ParamCount+0 < fn.MinParams)
      throw Exception("Bad param count", -1, ParamCount)

   static sHwnd := 0, sMsg, sSendMessageW
   if !sHwnd
   {
      Gui RegisterSyncCallback: +Parent%A_ScriptHwnd% +hwndsHwnd
      OnMessage(sMsg := 0x8000, Func("RegisterSyncCallback_Msg"))
      sSendMessageW := DllCall("GetProcAddress", "ptr", DllCall("GetModuleHandle", "str", "user32.dll", "ptr"), "astr", "SendMessageW", "ptr")
   }

   if !(pcb := DllCall("GlobalAlloc", "uint", 0, "ptr", 96, "ptr"))
      throw
   DllCall("VirtualProtect", "ptr", pcb, "ptr", 96, "uint", 0x40, "uint*", 0)

   p := pcb
   if (A_PtrSize = 8)
   {
      /*
      48 89 4c 24 08  ; mov [rsp+8], rcx
      48 89 54'24 10  ; mov [rsp+16], rdx
      4c 89 44 24 18  ; mov [rsp+24], r8
      4c'89 4c 24 20  ; mov [rsp+32], r9
      48 83 ec 28'    ; sub rsp, 40
      4c 8d 44 24 30  ; lea r8, [rsp+48]  (arg 3, &params)
      49 b9 ..        ; mov r9, .. (arg 4, operand to follow)
      */
      p := NumPut(0x54894808244c8948, p+0)
      p := NumPut(0x4c182444894c1024, p+0)
      p := NumPut(0x28ec834820244c89, p+0)
      p := NumPut(  0xb9493024448d4c, p+0) - 1
      lParamPtr := p, p += 8

      p := NumPut(0xba, p+0, "char") ; mov edx, nmsg
      p := NumPut(sMsg, p+0, "int")
      p := NumPut(0xb9, p+0, "char") ; mov ecx, hwnd
      p := NumPut(sHwnd, p+0, "int")
      p := NumPut(0xb848, p+0, "short") ; mov rax, SendMessageW
      p := NumPut(sSendMessageW, p+0)
      /*
      ff d0        ; call rax
      48 83 c4 28  ; add rsp, 40
      c3           ; ret
      */
      p := NumPut(0x00c328c48348d0ff, p+0)
   }
   else ;(A_PtrSize = 4)
   {
      p := NumPut(0x68, p+0, "char")      ; push ... (lParam data)
      lParamPtr := p, p += 4
      p := NumPut(0x0824448d, p+0, "int") ; lea eax, [esp+8]
      p := NumPut(0x50, p+0, "char")      ; push eax
      p := NumPut(0x68, p+0, "char")      ; push nmsg
      p := NumPut(sMsg, p+0, "int")
      p := NumPut(0x68, p+0, "char")      ; push hwnd
      p := NumPut(sHwnd, p+0, "int")
      p := NumPut(0xb8, p+0, "char")      ; mov eax, &SendMessageW
      p := NumPut(sSendMessageW, p+0, "int")
      p := NumPut(0xd0ff, p+0, "short")   ; call eax
      p := NumPut(0xc2, p+0, "char")      ; ret argsize
      p := NumPut((InStr(Options, "C") ? 0 : ParamCount*4), p+0, "short")
   }
   NumPut(p, lParamPtr+0) ; To be passed as lParam.
   p := NumPut(&fn, p+0)
   p := NumPut(ParamCount, p+0, "int")
   return pcb
}

RegisterSyncCallback_Msg(wParam, lParam)
{
   if (A_Gui != "RegisterSyncCallback")
      return
   fn := Object(NumGet(lParam + 0))
   paramCount := NumGet(lParam + A_PtrSize, "int")
   params := []
   Loop % paramCount
      params.Push(NumGet(wParam + A_PtrSize * (A_Index-1)))
   return %fn%(params*)
}