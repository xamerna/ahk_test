#Requires AutoHotkey v2
Persistent

;global space_:=Array()
global VarInteger:=1
;global VarString:="privet"
;global VarFloat:=33.3
global  arr_string := Array("out", "two", "three")
;global  arr_obj := Array("out":"123", "two":"1234", "three":"1235")
global arr_obj := {"KeyA": "ValueA", "KeyB": "ValueB"}
global  arr_int:= Array(1,2,3)
;global  arr_float:= Array(1.1,2.22,3.3)
MsgBox "start2"
KEPluginParamOutput("arr_obj",33.3)
