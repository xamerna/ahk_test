/*
Исходящие параметры           Значение при старте, если есть                  Описание
                              
string InfoText               "Tap «Record» to start recording a new macro"   текст, который будет отображаться в поле текста для информации
string SetTime                "00:00"                                         время до конца работы макроса
                            
string KeyboardEvents         1                                               установить чекбокс Keyboard Events в 1
string MouseEvents            1                                               зустановить чекбокс Mouse Events в 0
string FastMode               0                                               установить чекбокс Fast Mode в 0
string LoopMacro              0                                               установить чекбокс Loop Macro в 0
                            
string EnableRecord                                                           disable/enable кнопки Record
string EnablePlay             0                                               disable/enable кнопки Play
string EnableStop             0                                               disable/enable кнопки Stop
string EnableLoopPlus         0                                               disable/enable кнопки +
string EnableLoopMinus        0                                               disable/enable кнопки -
string TogglePlayPause        0                                               toggle Play/Pause button, 0 — Play, 1 — Pause

string[] EventName                                                            текстовое отображение первой колонки размножаемых контролов
string[] EventValue                                                           текстовое отображение второй колонки размножаемых контролов
string[] SelectEvent                                                          выделение текущего события
string SetLoopCount           1
double PlayingLevel           0                                               положение слайдера прогресса

Следующие 4 иконки только для локального теста, в KEW не загружать!
 image IcoRecord              GetIcon("Record")                               строка base64 с изображением для кнопки Record
 image IcoPlay                GetIcon("Play")                                 строка base64 с изображением Play  для кнопки Play
 image IcoPause               GetIcon("Pause")                                строка base64 с изображением Pause для кнопки Play
 image IcoStop                GetIcon("Stop")                                 строка base64 с изображением для кнопки Stop
                              
************************************************************************************************************************************************************
Входящие параметры            Возможные значения                              Описание
                              
string ApplyLoopMacro         0 или 1                                         зацикливать ли воспроизведение макроса
string IncreaseLoopCount                                                      тап по кнопке +
string DecreaseLoopCount                                                      тап по кнопке -         
string WriteMouseEvents       0 или 1
string WriteKeyboardEvents    0 или 1
string RecordNewMacro                                                         тап по кнопке Record
string PlayPause                                                              тап по кнопке PlayPause
string Stop                                                                   тап по кнопке Stop
string ApplyFastMode          0 или 1                                         чекбокс Fast Mode
*/

#NoEnv
#NoTrayIcon
#SingleInstance Force
DetectHiddenWindows, On
CoordMode, ToolTip
SetBatchLines, -1

if A_Args[1] {
   HostWindowHandle := HostEngineThreadId :=  A_Args[1]
   timer := Func("IfParentExist").Bind(HostWindowHandle)
   SetTimer, % timer, 2000
}
MacroRecorder.Start()
Return

$*Esc:: MacroRecorder.MacroFinished := true

class MacroRecorder
{
   Start() {
      Hotkey, $*Esc, Off
      this.Msg := new Messaging(ObjBindMethod(this, "MessageReceiver"))
      
      this.KeyboardEvents := true
      this.MouseEvents := true
      this.FastMode := false
      this.LoopCount := 1
      this.LoopMacro := false
      
      if !A_Args[1]
         this.Msg.SendParam("TogglePlayPause", 0)
      else {
         for k, v in ["Record", "Play", "Stop"]
            this.Msg.SendParam("Ico" . v, GetIcon(v))
      }
      this.EnableControl(["Play", "Stop", "LoopPlus", "LoopMinus"], 0)
      this.Msg.SendParam("InfoText", "Tap «Record» to start recording a new macro")
      this.Msg.SendParam("SetTime"        , "00:00")
      this.Msg.SendParam("KeyboardEvents" , 1)
      this.Msg.SendParam("MouseEvents"    , 1)
      this.Msg.SendParam("SetLoopCount"   , 1)
      this.Msg.SendParam("PlayingLevel"   , 0)
      this.Msg.SendParam("FastMode"       , 0)
      this.Msg.SendParam("LoopMacro"      , 0)
   }
   MacroFinished[] {
      set {
         MacroRecorder.paused := true
         if A_ThisHotkey
            this.Macro.Stop()
         this.EnableControl("Record", 1), this.EnableControl("Stop", 0)
         if A_Args[1]
            this.Msg.SendParam("IcoPlay", GetIcon("Play"))
         else
            this.Msg.SendParam("TogglePlayPause", 0)
         this.Msg.SendParam("PlayingLevel", 100)
         this.Msg.SendParam("InfoText", "Macro playback finished")
         this.Msg.SendParam("SetTime", "00:00")
      }
   }
   MessageReceiver(param, value) {
      Switch param {
         Case "WriteKeyboardEvents":
            this.KeyboardEvents := value
            this.Msg.SendParam("KeyboardEvents", value)
         Case "WriteMouseEvents":
            this.MouseEvents := value
            this.Msg.SendParam("MouseEvents", value)
         Case "ApplyFastMode":
            this.FastMode := value
            this.Msg.SendParam("FastMode", value)
         Case "ApplyLoopMacro":
            this.LoopMacro := value
            this.EnableControl(["LoopPlus", "LoopMinus"], value)
            this.Msg.SendParam("LoopMacro", value)
         Case "RecordNewMacro":
            if !(this.KeyboardEvents || this.MouseEvents) {
               this.AtLeastOneCheckboxWarning()
               Return
            }
            if A_Args[1]
               this.Msg.SendParam("IcoPause", GetIcon("Pause"))
            else
               this.Msg.SendParam("TogglePlayPause", 1)
            this.EnableControl("Record", 0)
            this.EnableControl(["Play", "Stop"], 1)
            this.Msg.SendParam("InfoText", "New macro is recording. Tap «Pause» to pause the recordind, or tap «Stop» to stop.")
            this.recording := true
            this.paused := false
            this.Macro := new Macro()
            this.Macro.Record("new")
         Case "PlayPause":
            this.paused := !this.paused
            if this.paused {
               if A_Args[1]
                  this.Msg.SendParam("IcoPlay", GetIcon("Play"))
               else
                  this.Msg.SendParam("TogglePlayPause", 0)
               if this.recording {
                  this.Macro.Record("pause")
                  this.Msg.SendParam("InfoText", "The recording is paused. Tap «Play» to resume the recordind, or tap «Stop» to stop.")
               }
               else {
                  this.Macro.Player.play := false
                  this.Msg.SendParam("InfoText", "The macro is paused. Tap «Play» to resume playing, or tap «Stop» to stop.")
               }
            }
            else {
               if A_Args[1]
                  this.Msg.SendParam("IcoPause", GetIcon("Pause"))
               else
                  this.Msg.SendParam("TogglePlayPause", 1)
               if this.recording {
                  this.Macro.Record("resume")
                  this.Msg.SendParam("InfoText", "The recording is resumed. Tap «Pause» to pause the recordind, or tap «Stop» to stop.")
               }
               else {
                  this.EnableControl("Record", 0), this.EnableControl("Stop", 1)
                  this.Msg.SendParam("InfoText", "The macro is playing. Tap «Pause» to pause playing, or tap «Stop» to stop.")
                  this.Macro.Play()
               }
            }
         Case "Stop":
            this.paused := true
            this.EnableControl("Record", 1), this.EnableControl("Stop", 0)
            if A_Args[1]
               this.Msg.SendParam("IcoPlay", GetIcon("Play"))
            else
               this.Msg.SendParam("TogglePlayPause", 0)
            if this.recording {
               this.recording := false
               this.Macro.Record("stop")
            }
            else {
               this.Macro.Stop()
               this.Msg.SendParam("InfoText", "Playing is stopped.")
            }
         Case "IncreaseLoopCount": this.Msg.SendParam("SetLoopCount", this.LoopCount < 999 ? this.LoopCount += 1 : this.LoopCount := 1)
         Case "DecreaseLoopCount": this.Msg.SendParam("SetLoopCount", this.LoopCount > 1 ? this.LoopCount -= 1 : this.LoopCount := 999)
      }
   }
   EnableControl(CtrlNameOrNameArray, action) {
      if !IsObject(CtrlNameOrNameArray)
         this.Msg.SendParam("Enable" . CtrlNameOrNameArray, action)
      else {
         for k, name in CtrlNameOrNameArray
            this.Msg.SendParam("Enable" . name, action)
      }
   }
   AtLeastOneCheckboxWarning() {
      this.Msg.SendParam("EnableRecord", 0)
      Loop 3 {
         this.Msg.SendParam("InfoText", " ")
         Sleep 500
         this.Msg.SendParam("InfoText", "Check at least one of «Keyboard» and «Mouse»!")
         Sleep 500
      }
      Sleep, 1000
      this.Msg.SendParam("InfoText", "Tap «Record» to start recording a new macro")
      this.Msg.SendParam("EnableRecord", 1)
   }
}

class Macro extends MacroRecorder
{
   __New() {
      this.Events := []
      this.EventNamesArray := []
      this.EventValuesArray := []
      this.EventSelectionsArray := []
      this.OnEvents := new this.LowLevelProc( this.Events
                                            , this.EventNamesArray
                                            , this.EventValuesArray
                                            , this.EventSelectionsArray )
      this.KbdProc   := this.OnEvents.KbdProc
      this.MouseProc := this.OnEvents.MouseProc
      this.SelectedId := []
      this.RecordTimer 
   }
   __Delete() {
      this.KeyboardHook := ""
      this.MouseHook    := ""
   }
   Record(mode) {
      static WH_KEYBOARD_LL := 13, WH_MOUSE_LL := 14
      if (mode = "new") {
         this.Player := new this.EventsPlayer(this.SelectedId, this.EventSelectionsArray)
         this.Player.displayTime := 0
         timer := this.Player.RecordTimer
         SetTimer, % timer, 1000
         while this.Events[1]  ; нельзя переназначать this.Events, т. к. он уже передан в LowLevelProc
            this.Events.Pop()  ; поэтому просто удаляем все его элементы
         while this.EventNamesArray[1] {
            this.EventNamesArray.Pop()
            this.EventValuesArray.Pop()
            this.EventSelectionsArray.Pop()
         }
         this.Msg.SendParam("EventName", "[]")
         this.Msg.SendParam("EventValue", "[]")
         this.Msg.SendParam("SelectEvent", "[]")
      }
      if (mode ~= "new|resume") {
         ( this.KeyboardEvents && this.KeyboardHook := new WindowsHook(WH_KEYBOARD_LL, this.KbdProc  ) )
         ( this.MouseEvents    && this.MouseHook    := new WindowsHook(WH_MOUSE_LL   , this.MouseProc) )
      }
      if (mode ~= "stop|pause") {
         this.KeyboardHook := ""
         this.MouseHook    := ""
      }
      if (mode = "stop") {
         timer := this.Player.RecordTimer
         SetTimer, % timer, Delete
         this.Player.Events := this.Events
         this.Player.EventsCopy := this.Events.Clone()
         this.Msg.SendParam("InfoText", "Recording is over, tap «Play» to play the macro.")
      }
   }
   Play() {
      Hotkey, $*Esc, On
      this.Player.play := true
      this.Player.WaitForWindow := true
      this.Player.startTime := A_TickCount
      Timer := this.Player.StartTimer
      SetTimer, % Timer, -10
   }
   Stop() {
      Hotkey, $*Esc, Off
      this.Player.play := false
      timer := this.Player.CalcRemTimeTimer
      SetTimer, % timer, Delete
      this.Player.WaitForWindow := false
      Send {LAlt Up}{LCtrl Up}{LShift Up}{RAlt Up}{RCtrl Up}{RShift Up}{LButton Up}
      
      this.EventSelectionsArray[ this.SelectedId[1], "value" ] := false
      this.EventSelectionsArray[ 1                 , "value" ] := true
      this.Msg.SendParam("SelectEvent", AhkToJSON( this.EventSelectionsArray ))
      this.Msg.SendParam("PlayingLevel", 0)
      this.Msg.SendParam("SetTime", "00:00")
      this.Player.EventsCopy := this.Events.Clone()
   }
   
   class EventsPlayer extends Macro {
      __New(SelectedId, EventSelectionsArray) {
         this.SelectedId := SelectedId
         this.EventSelectionsArray := EventSelectionsArray
         this.SelectedId[1] := 1
         this.FullTime := 0
         this.WaitTimer        := ObjBindMethod(this, "WaitForWindowActive", "timer")
         this.CalcRemTimeTimer := ObjBindMethod(this, "CalcRemainingTime")
         this.StartTimer       := ObjBindMethod(this, "PlayTimer")
         this.RecordTimer      := ObjBindMethod(this, "RecordTime")
      }
      RecordTime() {
         t := ++this.displayTime
         formattedTime := RegExReplace(Format("{:02}:{:02}:{:02}", t//3600, mod(t, 3600)//60, mod(t, 60)), "^00:")
         this.Msg.SendParam("SetTime", formattedTime)
      }
      PlayTimer() {
         CalcTimer := this.CalcRemTimeTimer
         SetTimer, % CalcTimer, 500
         while this.play && event := this.currentEvent := this.EventsCopy.RemoveAt(1) {
            if (A_Index = 1) {
               Loop 2 {
                  if MacroRecorder.FastMode := !MacroRecorder.FastMode
                     this.FastTime := this.CalcRemainingTime()
                  else
                     this.SlowTime := this.CalcRemainingTime()
               }
            }
            
            if ( this.play && event[3] && !WinActive("ahk_class " . event[3]) )
               this.WaitForWindowActive()
            
            if this.play
               this.PerformCurrentEvent()
            
            if !this.play
               break
            
            if this.EventsCopy[1] {
               delay := this.CalcDelay(event[1], this.EventsCopy[1, 1])
               if !( MacroRecorder.FastMode && this.IsMouseMoveEvent(event) )
                  Sleep % delay
            }
            else if MacroRecorder.LoopMacro && MacroRecorder.LoopCount > 1 {
               this.Msg.SendParam("SetLoopCount", MacroRecorder.LoopCount-- - 1)
               this.EventsCopy := this.Events.Clone()
               Sleep, 100
            }
            else
               this.StopPlaying()
         }
      }
      CalcRemainingTime() {
         if !this.play
            Return
         prevTime := lastTime := startTime := this.currentEvent[1]
         for k, event in this.EventsCopy {
            time := event[1]
            delay := this.CalcDelay(prevTime, time)
            if ( MacroRecorder.FastMode && this.IsMouseMoveEvent(event) )
               delay := 0
            lastTime += delay
            prevTime := time
         }
         remainingTimeSec := Ceil( (lastTime - startTime)/1000 )
         t := (remainingTimeSec + (MacroRecorder.FastMode ? this.FastTime : this.SlowTime)*(MacroRecorder.LoopCount - 1))
         formattedTime := RegExReplace(Format("{:02}:{:02}:{:02}", t//3600, mod(t, 3600)//60, mod(t, 60)), "^00:")
         if this.play && formattedTime != "00:00"
            this.Msg.SendParam("SetTime", formattedTime)
         Return remainingTimeSec
      }
      WaitForWindowActive(isTimer := false) {
         if isTimer {
            if !WinActive("ahk_class " . this.windowClass) && this.WaitForWindow
               SetTimer,, -300
            else {
               SetTimer,, Delete
               this.windowIsActive := true
            }
         }
         else {
            this.Msg.SendParam("InfoText", "Waiting for appropriate window to be active ...")
            this.windowClass := this.currentEvent[3]
            this.windowIsActive := false
            WaitTimer := this.WaitTimer
            SetTimer, % WaitTimer, -300
            while !this.windowIsActive
               Sleep, 50
            if this.play
               this.Msg.SendParam("InfoText", "The macro is playing. Tap «Pause» to pause playing, or tap «Stop» to stop.")            
         }
      }
      PerformCurrentEvent() {
         event := this.currentEvent
         addr := event.GetAddress(2)
         if event[4] {
            this.EventSelectionsArray[ this.SelectedId[1]            , "value" ] := false
            this.EventSelectionsArray[ this.SelectedId[1] := event[4], "value" ] := true
            this.Msg.SendParam("SelectEvent", AhkToJSON( this.EventSelectionsArray ))
         }
         DllCall("SendInput", "UInt", 1, "Ptr", addr, "Int", 16 + A_PtrSize*3)
         if (A_TickCount - this.startTime > 200) {
            this.startTime := A_TickCount
            currentPlayingLevel := 100 - Round(this.EventsCopy.Count()/this.Events.Count()*100)
            if (currentPlayingLevel != prevPlayingLevel) {
               this.Msg.SendParam("PlayingLevel", currentPlayingLevel)
               prevPlayingLevel := currentPlayingLevel
            }
         }
      }
      IsMouseMoveEvent(event) {
         static mouseMoveEvent := (MOUSEEVENTF_MOVE := 0x0001) | (MOUSEEVENTF_ABSOLUTE := 0x8000)
         Return NumGet(event.GetAddress(2) + A_PtrSize + 12) = mouseMoveEvent
      }
      CalcDelay(time1, time2) {
         delay := time2 ? time2 - time1 : 0
         (delay > 1000 && delay := 1000)
         Return !MacroRecorder.FastMode ? delay : (delay > 50 ? 50 : delay)         
      }
      StopPlaying() {
         this.play := false
         CalcTimer := this.CalcRemTimeTimer
         SetTimer, % CalcTimer, Delete
         Send {LAlt Up}{LCtrl Up}{LShift Up}{RAlt Up}{RCtrl Up}{RShift Up}{LButton Up}
         this.EventsCopy := this.Events.Clone()
         this.MacroFinished := true
      }
   }
   
   class LowLevelProc extends Macro
   {
      __New(Events, EventNamesArray, EventValuesArray, EventSelectionsArray) {
         this.Events := Events
         this.EventNamesArray := EventNamesArray
         this.EventValuesArray := EventValuesArray
         this.EventSelectionsArray := EventSelectionsArray
         this.KbdProc   := ObjBindMethod(this, "LowLevelKeyboardProc")
         this.MouseProc := ObjBindMethod(this, "LowLevelMouseProc")
         this.timer     := ObjBindMethod(this, "ParseEvents")
         this.idCounter := 0
         this.idx       := 0
      }
      LowLevelMouseProc(nCode, wParam, lParam) {
         static INPUT_MOUSE := 0, MOUSEEVENTF_ABSOLUTE := 0x8000, inputSize := 16 + A_PtrSize*3
				  , Flags := { 0x200: 0x1, 0x201: 0x2, 0x202: 0x4, 0x204: 0x8, 0x205: 0x10, 0x207: 0x20
								 , 0x208: 0x40, 0x20B: 0x80, 0x20C: 0x100, 0x20A: 0x800, 0x20E: 0x1000 }
         data := []
         data[1] := NumGet(lParam + 16, "UInt") ; event time
         data.SetCapacity(2, inputSize)
         DllCall("RtlZeroMemory", "Ptr", data.GetAddress(2), "Ptr", inputSize)
         offset := data.GetAddress(2) + A_PtrSize
         x := NumGet(lParam + 0, "Int"), y := NumGet(lParam + 4, "Int")
         NumPut( INPUT_MOUSE, offset - A_PtrSize )
         NumPut( x/A_ScreenWidth *0xFFFF             , offset +  0 )
         NumPut( y/A_ScreenHeight*0xFFFF             , offset +  4 )
         NumPut( NumGet(lParam + 10, "Short")        , offset +  8 )
         NumPut( Flags[wParam] | MOUSEEVENTF_ABSOLUTE, offset + 12 )
         data[5] := {x: x, y: y}
         this.Events.Push(data)
         timer := this.timer
         SetTimer, % timer, -200
         Return DllCall("CallNextHookEx", "Ptr", 0, "Int", nCode, "Ptr", wParam, "Ptr", lParam)
      }
		LowLevelKeyboardProc(nCode, wParam, lParam) {
			static INPUT_KEYBOARD := 1, inputSize := 16 + A_PtrSize*3
				  , LLKHF_EXTENDED := (KF_EXTENDED := 0x100 ) >> 8
				  , LLKHF_UP       := (KF_UP       := 0x8000) >> 8
				  , KEYEVENTF_KEYUP := 0x2
				  
		   vk := NumGet(lParam + 0, "UInt")
			sc := NumGet(lParam + 4, "UInt")
			if ( !A_Args[1] || !(sc = 0x3b || sc = 0x3c || sc = 0x3d) ) { ; F1, F2, F3
				flags := NumGet(lParam + 8, "UInt")
				; ToolTip % Format("{:#x}", sc) . "`n" . flags & LLKHF_EXTENDED
				kbdInpFlags := (flags & LLKHF_EXTENDED) | ((flags & LLKHF_UP) ? KEYEVENTF_KEYUP : 0)
				
				data := []
				data[1] := NumGet(lParam + 12, "UInt") ; event time
				data.SetCapacity(2, inputSize)
            WinGetClass, winClass, A
            data[3] := winClass
				offset := data.GetAddress(2)
				DllCall("RtlZeroMemory", "Ptr", offset, "Ptr", inputSize)
				NumPut(INPUT_KEYBOARD, offset + 0)
				NumPut(vk            , offset + A_PtrSize + 0, "UShort")
				NumPut(sc            , offset + A_PtrSize + 2, "UShort")
				NumPut(kbdInpFlags   , offset + A_PtrSize + 4, "UInt"  )
				this.Events.Push(data)
            timer := this.timer
            SetTimer, % timer, -10
			}
			Return DllCall("CallNextHookEx", "Ptr", 0, "Int", nCode, "Ptr", wParam, "Ptr", lParam)
		}
      ParseEvents() {
         static INPUT_MOUSE := 0x00000000, INPUT_KEYBOARD := 0x00000001
         maxCount := this.Events.Count()
         while this.idx < maxCount {
            this.idx++
            event := this.Events[this.idx]
            EventInfo := this.GetEventInfo(event)
            nextEvent := prevEvent := prevPrevEvent := ""
            
            if this.Events.HasKey(this.idx + 1) {
               nextEvent := this.Events[this.idx + 1]
               NextEventInfo := this.GetEventInfo(nextEvent)
            }
            if this.Events.HasKey(this.idx - 1) {
               prevEvent := this.Events[this.idx - 1]
               PrevEventInfo := this.GetEventInfo(prevEvent)
            }
            if this.Events.HasKey(this.idx - 2) {
               prevPrevEvent := this.Events[this.idx - 2]
               PrevPrevEventInfo := this.GetEventInfo(prevPrevEvent)
            }
            if (EventInfo.type = INPUT_KEYBOARD) { ; <—————————————————— обработка клавиатурных нажатий
               Switch EventInfo.action {
                  Case "down":
                     if ( !prevEvent || PrevEventInfo.keyName != EventInfo.keyName
                          || (PrevEventInfo.keyName = EventInfo.keyName && PrevEventInfo.action != "down") )
                        this.SendEventInfo(event, true, "Key Down", EventInfo.keyName)
                  Case "up":
                     if ( PrevEventInfo.keyName = EventInfo.keyName && EventInfo.time - PrevEventInfo.time < 300
                          && (!prevPrevEvent || PrevPrevEventInfo.keyName != PrevEventInfo.keyName || PrevPrevEventInfo.action = "up") )
                        this.SendEventInfo(prevEvent, false, "Key Press", EventInfo.keyName)
                     else
                        this.SendEventInfo(event, true, "Key Up", EventInfo.keyName)
               }
            }
            else if (EventInfo.type = INPUT_MOUSE) { ; <———————————————— обработка событий мыши
               Switch EventInfo.name {
                  Case "Mouse Move":
                     if (!nextEvent || NextEventInfo.name != "Mouse Move")
                        this.SendEventInfo(event, true, "Mouse Move", EventInfo.coords)
                  Case "LButton Down": this.SendEventInfo(event, PrevEventInfo.name = "Mouse Move" ? false : true, "LButton Down", EventInfo.coords)
                  Case "LButton Up"  :
                     if (PrevEventInfo.name != "LButton Down" || EventInfo.time - PrevEventInfo.time > 200)
                        this.SendEventInfo(event, true, "LButton Up", EventInfo.coords)
                     else
                        this.SendEventInfo(event, false, "LButton Click", EventInfo.coords)
                  Case "RButton Down": this.SendEventInfo(event, true, "RButton Down", EventInfo.coords)
                  Case "RButton Up"  :
                     if (PrevEventInfo.name != "RButton Down" || EventInfo.time - PrevEventInfo.time > 200)
                        this.SendEventInfo(event, true, "RButton Up", EventInfo.coords)
                     else
                        this.SendEventInfo(event, false, "RButton Click", EventInfo.coords)
                  Case "MButton Down": this.SendEventInfo(event, true, "RButton Down", EventInfo.coords)
                  Case "MButton Up"  :
                     if (PrevEventInfo.name != "MButton Down" || EventInfo.time - PrevEventInfo.time > 200)
                        this.SendEventInfo(event, true, "MButton Up", EventInfo.coords)
                     else
                        this.SendEventInfo(event, false, "MButton Click", EventInfo.coords)
                  Case "Wheel forward":
                     if (!nextEvent || NextEventInfo.name != "Wheel forward")
                        this.SendEventInfo(event, true, "Wheel forward", EventInfo.coords)
                  Case "Wheel backward":
                     if (!nextEvent || NextEventInfo.name != "Wheel backward")
                        this.SendEventInfo(event, true, "Wheel backward", EventInfo.coords)
                  Default:
                     this.SendEventInfo(event, true, EventInfo.name, EventInfo.coords)
               }
            }
         }
      }
      GetEventInfo(event) {
         static INPUT_MOUSE := 0x00000000, INPUT_KEYBOARD := 0x00000001
         addr := event.GetAddress(2)
         eventType := NumGet(addr + 0)
         eventTime := event[1]
         Switch eventType {
            Case INPUT_KEYBOARD :
               flags := NumGet(addr + A_PtrSize + 4, "UInt")
               ext   := flags & 0x1
               vk    := NumGet(addr + A_PtrSize + 0, "UShort")
               sc    := NumGet(addr + A_PtrSize + 2, "UShort") | (ext << 8)
               up    := flags & 0x2, down := !up
               keyName := GetKeyName(Format("sc{:x}", sc))
               Info := {type: eventType, time: eventTime, vk: vk, sc: sc, keyName: keyName, action: up ? "up" : "down"}
               
            Case INPUT_MOUSE :
               ext    := NumGet(addr + A_PtrSize +  8, "Short")
               action := NumGet(addr + A_PtrSize + 12) ^ 0x8000
               MouseEvents := { 0x0001: "Mouse Move", 0x0002: "LButton Down", 0x0004: "LButton Up"
                                                    , 0x0008: "RButton Down", 0x0010: "RButton Up"
                                                    , 0x0020: "MButton Down", 0x0040: "MButton Up"
                                                    
                                                    , 0x0080: "XButton" . ext . " Down", 0x0100: "XButton" . ext . " Up"
                                                    
                                                    , 0x0800: ext = 120 ? "Wheel forward"  : "Wheel backward"
                                                    , 0x1000: ext = 120 ? "HWheel forward" : "HWheel backward" }
               Info := {type: eventType, time: eventTime, name: MouseEvents[action], coords: event[5, "x"] . ", " . event[5, "y"]}
         }
         Return Info
      }
      SendEventInfo(event, isNew, eventName, eventValue) {
         event[4] := id := (isNew ? ++this.idCounter : this.idCounter)
         if !isNew {
            this.EventNamesArray[  this.EventNamesArray.MaxIndex() , "value" ] := eventName
            this.EventValuesArray[ this.EventValuesArray.MaxIndex(), "value" ] := eventValue
         }
         else {
            this.EventNamesArray.Push(      {id: id, value: eventName } )
            this.EventValuesArray.Push(     {id: id, value: eventValue} )
            this.EventSelectionsArray.Push( {id: id, value: false     } )
         }
         MacroRecorder.Msg.SendParam( "EventName"  , AhkToJSON(this.EventNamesArray     ) )
         MacroRecorder.Msg.SendParam( "EventValue" , AhkToJSON(this.EventValuesArray    ) )
         MacroRecorder.Msg.SendParam( "SelectEvent", AhkToJSON(this.EventSelectionsArray) )
      }
   }
}

class WindowsHook {
   __New(type, callBack, isGlobal := true) {
      this.BoundCallback := new BoundFuncCallback(callBack, 3, "Fast")
      this.hHook := DllCall("SetWindowsHookEx", "Int", type, "Ptr", this.BoundCallback.addr
															 , "Ptr", !isGlobal ? 0 : DllCall("GetModuleHandle", "UInt", 0, "Ptr")
															 , "UInt", isGlobal ? 0 : DllCall("GetCurrentThreadId"), "Ptr")
   }
   __Delete() {
      DllCall("UnhookWindowsHookEx", "Ptr", this.hHook)
      this.BoundCallback := ""
   }
}

class BoundFuncCallback
{
   __New(BoundFuncObj, paramCount, options := "") {
      this.pInfo := Object( {BoundObj: BoundFuncObj, paramCount: paramCount} )
      this.addr := RegisterCallback(this.__Class . "._Callback", options, paramCount, this.pInfo)
   }
   __Delete() {
      ObjRelease(this.pInfo)
      DllCall("GlobalFree", "Ptr", this.addr, "Ptr")
   }
   _Callback(Params*) {
      Info := Object(A_EventInfo), Args := []
      Loop % Info.paramCount
         Args.Push( NumGet(Params + A_PtrSize*(A_Index - 2)) )
      Return Info.BoundObj.Call(Args*)
   }
}

AhkToJSON(obj, indent := "") {
   static Doc, JS
   if !Doc {
      Doc := ComObjCreate("htmlfile")
      Doc.write("<meta http-equiv=""X-UA-Compatible"" content=""IE=9"">")
      JS := Doc.parentWindow
      ( Doc.documentMode < 9 && JS.execScript() )
   }
   if indent|1 {
      if IsObject( obj ) {
         isArray := true
         for key in obj {
            if IsObject(key)
               throw Exception("Invalid key")
            if !( key = A_Index || isArray := false )
               break
         }
         for k, v in obj
            str .= ( A_Index = 1 ? "" : "," ) . ( isArray ? "" : %A_ThisFunc%(k, true) . ":" ) . %A_ThisFunc%(v, true)

         Return isArray ? "[" str "]" : "{" str "}"
      }
      else if !(obj*1 = "" || RegExMatch(obj, "^-?0|\s"))
         Return obj
      
      for k, v in [["\", "\\"], [A_Tab, "\t"], ["""", "\"""], ["/", "\/"], ["`n", "\n"], ["`r", "\r"], [Chr(12), "\f"], [Chr(8), "\b"]]
         obj := StrReplace( obj, v[1], v[2] )

      Return """" obj """"
   }
   sObj := %A_ThisFunc%(obj, true)
   Return JS.eval("JSON.stringify(" . sObj . ",'','" . indent . "')")
}

class Messaging
{
/*
The Messaging class implements messaging between Keyboard Extension® for Windows (KEW) and the script.

When the instance of the class Messaging is created,
a Func Object or a function name can optionally be passed to the constructor of the class. 
This object or function is required to process incoming messages from KEW.

In order to send messages to KEW, SendParam(param, value) method is used,
where param is the name of the outgoing parameter
      value is its corresponding value

UserOnMessageFunc — a custom Func Object or a function name that will be called when messages are received from KEW
                    It accepts two mandatory parameters:
                       param - the name of the incoming parameter
                       value - the value of the incoming parameter
*/
   __New(UserOnMessageFunc := "") {
      if UserOnMessageFunc {
         UserFunc := IsObject(UserOnMessageFunc) ? UserOnMessageFunc : Func(UserOnMessageFunc)
         this.OnMessageReceive := new this.Receiving(UserFunc)
      }
   }
   
   __Delete() {
      if this.OnMessageReceive {
         this.OnMessageReceive.Clear()
         this.OnMessageReceive := ""
      }
   }
   
   SendParam(param, value) {
    ; these gobal variables get values ​​when the plugin starts, they are required to send messages to KEW
      global HostWindowHandle, HostEngineThreadId
      while !(HostWindowHandle && HostEngineThreadId)
         Sleep, 10
      this._SendData(HostWindowHandle, HostEngineThreadId, param . ":" . value)
   }
   
   _SendData(hWnd, EngineThreadId, StringData) {
      VarSetCapacity(message, size := StrPut(StringData, "UTF-16")*2, 0)
      StrPut(StringData, &message, "UTF-16")
      VarSetCapacity(COPYDATASTRUCT, A_PtrSize*3, 0)
      NumPut(EngineThreadId, COPYDATASTRUCT, 0, "UInt")
      NumPut(size, COPYDATASTRUCT, A_PtrSize, "UInt")
      NumPut(&message, COPYDATASTRUCT, A_PtrSize*2)
      DllCall("SendMessage", Ptr, hWnd, UInt, WM_COPYDATA := 0x4A, Ptr, 0, Ptr, &COPYDATASTRUCT)
   }
   
   class Receiving {
      WM_COPYDATA := 0x4A
      __New(UserFunc) {
         this.dataArr := []
         this.UserFunc := UserFunc
         this.timer := ObjBindMethod(this, "MessageProcessing")
         this.OnMsg := ObjBindMethod(this, "CopyDataRead")
         OnMessage(this.WM_COPYDATA, this.OnMsg)
      }
      
      CopyDataRead(wp, lp) {
         data := StrGet(NumGet(lp + A_PtrSize*2), "UTF-16")
         this.dataArr.Push(data)
         timer := this.timer
         SetTimer, % timer, -10
         Return true
      }
      
      MessageProcessing() {
         while this.dataArr[1] != "" {
            data := this.dataArr.RemoveAt(1)
            RegExMatch(data, "^(.*?):(.*)", m)
            param := m1, value := m2
            this.UserFunc.Call(param, value)
         }
      }
      
      Clear() {
         OnMessage(this.WM_COPYDATA, this.OnMsg, 0)
         this.OnMsg := ""
         this.timer := ""
      }
   }
}

GetIcon(icoName) {
   icoRecord = 
   (LTrim Join
      iVBORw0KGgoAAAANSUhEUgAAAB0AAAAcCAYAAACdz7SqAAABT0lEQVR42u2VIUwD
      QRBF/ywOhUCgQIJCYDCABEdAAIJUniAhqUCRFEUFCUGQ4Iqrw0DAVRYMpgIDyKIR
      GHDcMDMUx5bd7aUJyf3kxOU2eff3bt7SO7YYQw6V0BI6VCiNjYJ2V4ClGdDsJCD3
      ePsAP3TBzTu7CoWSgFwjA6bG/Yu6r8g3TuUlXgaHusoCSIEhkeb5poDbT+lQkmbu
      /vB7K0Oj4PkDsDRPgrqLKmh1LhzYC7cfkS8fxUOt5fNJNPAnnxM71joOKg21aWry
      rOH9o/3Q2hpcbT0dWr8E16/+A1RGxYWOym9QndmbThxURTAyyI80vWfCiINKXGvf
      bBTdsnkLzs69z/sbSdtGyoF7ckCqHGxB5Lc1DV53+q4JE77MLB1vmzC8DVX4Mpv4
      w7vBUIsA9ftSZRGQo02POt1K6NEmID5reQ2UDi0wJbSEFpIvLBy0UfIMvHkAAAAA
      SUVORK5CYII=
   )
   icoPlay = 
   (LTrim Join
      iVBORw0KGgoAAAANSUhEUgAAAB0AAAAcCAYAAACdz7SqAAAAt0lEQVR42mPUmfHh
      PwOdAeOopaOWDn9LfVSYwfSWO3/pZ2maAQsYbwZaOuvCH4bnX8gPIJItBYHPv/4z
      LL8GsZxulsLAM6Bv03f8ItnXFFkKAyAfk+JrqlgK83Xfqd8MBx79o5+lMEBMQqO6
      pbAEBkpsNLcUFLyNR34znH1Bp+AlxndUsxTkq15g4rn1jg5ZBuQjkM9APiQHkGwp
      yHcNwLijSzEYqcUM9CGdC3xqglFLRy0dupYCABGIvLEocHfUAAAAAElFTkSuQmCC
   )
   icoPause = 
   (LTrim Join
      iVBORw0KGgoAAAANSUhEUgAAAB0AAAAcCAYAAACdz7SqAAAAPElEQVR42mPUmfHh
      PwOdAeOopaOWDl9L0wxYwBgGZl34A8bEyo9aOmrpqKWjlo5aOmopfcGopaOWDl1L
      AedR87FXxQ30AAAAAElFTkSuQmCC
   )
   icoStop = 
   (LTrim Join
      iVBORw0KGgoAAAANSUhEUgAAABwAAAAcCAYAAAByDd+UAAAAOUlEQVR42mPUmfHh
      PwMdAeOohaMWjlpIsoVnEjhIMtBkwY9RC0ctHLVw1MJRC2kMRi0ctXDUQgwAAFZD
      b7GFwn3GAAAAAElFTkSuQmCC
   )
   Return ico%icoName%
}

IfParentExist(hWnd) {
   if !WinExist("ahk_id " . hWnd)
      ExitApp
}