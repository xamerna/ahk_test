#NoTrayIcon
#Persistent

global VarString:="privet"
global VarInteger:=1
global VarFloat:=33.3

global arr_obj_string := {"KeyA": "ValueA", "KeyB": "ValueB"}
global arr_obj_int := {"KeyA": 1, "KeyB": 2}
global arr_obj_float := {"KeyA": 33.2, "KeyB": 22.5}

global  arr_int:= Array(1,2,3)
global arr_float:= Array(1.3,2.2,3.4)
global  arr_string:= Array("1","2","3")


MsgBox "start1"
KEPluginParamOutput(arr_float)
