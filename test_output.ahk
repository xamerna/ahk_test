﻿;global space_:=Array()
#Persistent
;OnKEPluginParamInput("KEPluginParamInput")
SetTimer , Timer, -1000




KEPluginParamInput(name, value)
{
	MsgBox "1234"
	
}


Timer() {
	
 KEPluginParamOutput("123","123")
 
}



/*
global VarStringJSON:="{""out"":[{""id"":""name1"",""value"":1},{""id"":""name2"",""value"":2},{""id"":""name3"",""value"":3}]}"
global VarInteger := 1
global VarFloat := 3.3
global VarString:="one\g\k`n"

global  arr_int:= Array(1,,3)
global  arr_float:= Array(1.1,2.2,3.3)
global  arr_string := Array("one", "two")

;у объектов тип индекса всегда будет преобразован в string
global  obj_int := {"name1": 1, "name2": 2}
global  obj_float := {"name1": 1.1, "name2": 2.2}
global  obj_string := {"name1": "one", "name2": "two"}

global arr_int_array_arr:= Array(arr_string,arr_int)
global arr_float_array_arr:= Array(arr_string,arr_float)
global arr_string_array_arr:= Array(arr_string,arr_string)


Sleep 1000
KEPluginParamOutput("""{""id"":""one\g\k`n"",""value"":1.1}""")

KEPluginParamOutput(VarStringJSON)
KEPluginParamOutput("[{""id"":""one\g\k`n"",""value"":1.1}]")
KEPluginParamOutput(Array("1",,"3"))	
;KEPluginParamOutput("[{""id"":""one\g\k`n"",""value"":1.1}]")
KEPluginParamOutput("234re1")
KEPluginParamOutput(3.3)
KEPluginParamOutput({123: 1, name2: 2, "name3": 3})	

	
KEPluginParamOutput("test",Array("1","2","3"),Array(1,2,3))

paramName := "param name"
paramValue := {} ; пустой объект
KEPluginParamOutput(paramName, paramValue)


KEPluginParamOutput({"name1": 1, "name2": 2, "name3": 3})


;-----------------------один параметр----------------------
KEPluginParamOutput(VarInteger)		;преобразуется в {"VarInteger":1}
KEPluginParamOutput(VarFloat)		;преобразуется в {"VarFloat":33.3}
KEPluginParamOutput(VarString)		;преобразуется в {"VarString":"privet"}

KEPluginParamOutput(arr_int)		;преобразуется в {"arr_int":[{"id":1,"value":1},{"id":2,"value":2},{"id":3,"value":3}]}
KEPluginParamOutput(arr_float)		;преобразуется в {"arr_float":[{"id":1,"value":1.1},{"id":2,"value":2.2},{"id":3,"value":3.3}]}
KEPluginParamOutput(arr_string)		;преобразуется в {"arr_string":[{"id":1,"value":"one"},{"id":2,"value":"two"},{"id":3,"value":"three"}]}

KEPluginParamOutput(obj_int)  		;преобразуется в [{"name1":1},{"name2":2},{"name3":3}]
KEPluginParamOutput(obj_float)		;преобразуется в [{"name1":1},{"name2":2},{"name3":3}]
KEPluginParamOutput(obj_string)		;преобразуется в [{"name1":1},{"name2":2},{"name3":3}]


;---------------------------2 параметра-----------------------

KEPluginParamOutput("Var", VarInteger)						;{"Var":1}
KEPluginParamOutput("Var", VarFloat)						;{"Var":33.3}
KEPluginParamOutput("Var" ,VarString)						;{"Var":"privet"}

KEPluginParamOutput("arr" , arr_int) 						;{"arr":[{"id":1,"value":1},{"id":2,"value":2},{"id":3,"value":3}]}
KEPluginParamOutput("arr" , arr_float)						;{"arr":[{"id":1,"value":1.1},{"id":2,"value":2.2},{"id":3,"value":3.3}]}
KEPluginParamOutput("arr" ,arr_string)						;{"arrg":[{"id":1,"value":"one"},{"id":2,"value":"two"},{"id":3,"value":"three"}]}

KEPluginParamOutput("obj_int_to_array",obj_int)				;{"obj_int_to_array":[{"id":id1, "value":1},{"id":id2, "value":2},{"id":id3, "value":3}]}
KEPluginParamOutput("obj_float_to_array",obj_float)			;{"obj_int_to_array":[{"id":"id1","value":1.1},{"id":"id2","value":2.2},{"id":"id3","value":3.3}]}
KEPluginParamOutput("obj_string_to_array",obj_string)		;{"obj_string_to_array":[{"id":"id1","value":"one"},{"id":"id2","value":"two"},{"id":"id3","value":"three"}]}

KEPluginParamOutput(arr_string,arr_int)						;{[{"one":1},{"two":2},{"three":3}]}
KEPluginParamOutput(arr_string,arr_float)					;{[{"one":1.1},{"two":2.2},{"three":3.3}]}
KEPluginParamOutput(arr_string,arr_string)					;{[{"one":"one"},{"two":"two"},{"three":"three"}]}

KEPluginParamOutput(arr_string,arr_int_array)				;{[{"one":[{"id":1,"value":1},{"id":2,"value":2},{"id":3,"value":3}]},{"two":[{"id":1,"value":1},{"id":2,"value":2},{"id":3,"value":3}]},{"three":[{"id":1,"value":1},{"id":2,"value":2},{"id":3,"value":3}]}]}
KEPluginParamOutput(arr_string,arr_float_array)				;{[{"one":[{"id":1,"value":1.1},{"id":2,"value":2.2},{"id":3,"value":3.3}]},{"two":[{"id":1,"value":1.1},{"id":2,"value":2.2},{"id":3,"value":3.3}]},{"three":[{"id":1,"value":1.1},{"id":2,"value":2.2},{"id":3,"value":3.3}]}]}
KEPluginParamOutput(arr_string,arr_string_array)			;{[{"one":[{"id":1,"value":"one"},{"id":2,"value":"two"},{"id":3,"value":"three"}]},{"two":[{"id":1,"value":"one"},{"id":2,"value":"two"},{"id":3,"value":"three"}]},{"three":[{"id":1,"value":"one"},{"id":2,"value":"two"},{"id":3,"value":"three"}]}]}

;-------------------------------3 параметра------------------
KEPluginParamOutput("arr_int_ID", arr_string, arr_int)			;{"arr_int_ID":[{"id":"one","value":1},{"id":"two","value":2},{"id":"three","value":3}]}
KEPluginParamOutput("arr_float_ID", arr_string, arr_float)		;{"arr_float_ID":[{"id":"one","value":1.1},{"id":"two","value":2.2},{"id":"three","value":3.3}]}
KEPluginParamOutput("arr_string_ID", arr_string, arr_string) 	;{"arr_string_ID":[{"id":"one","value":"one"},{"id":"two","value":"two"},{"id":"three","value":"three"}]}




paramName := "param\value`n`t"
KEPluginParamOutput(paramName)

paramName := ["one", "two", "three"]
KEPluginParamOutput(paramName)


paramName := {"key1": "value1", "key2": "value2"}
KEPluginParamOutput(paramName)

;obj := Map("paramName1", "paramValue1", "paramName2", "paramValue2")
;KEPluginParamOutput(obj)

; или без предварительного сохранения Map в переменную
;KEPluginParamOutput(Map("paramName1", "paramValue1", "paramName2", "paramValue2"))"

paramName := "param name"
paramValue := "param value"
KEPluginParamOutput(paramName, paramValue)

; или без предварительного сохранения текста в переменные
KEPluginParamOutput("param name", "param value")

paramName := "param name"
paramValue := ["one", "two", "three"]
KEPluginParamOutput(paramName, paramValue)

; или без предварительного сохранения в переменные
KEPluginParamOutput("param name", ["one", "two", "three"])

paramName := "param name"
paramValue := [] ; пустой массив
KEPluginParamOutput(paramName, paramValue)


paramName := "param name"
paramValue := {"key1": "value1", "key2": "value2"}
KEPluginParamOutput(paramName, paramValue)

; или без предварительного сохранения в переменные
KEPluginParamOutput("param name", {"key1": "value1", "key2": "value2"})

paramName := "param name"
paramValue := {} ; пустой объект
KEPluginParamOutput(paramName, paramValue)

;paramName := "param name"
;obj := Map(1, "value1", 2, "value2")
;KEPluginParamOutput(paramName, obj)

;paramName := "param name"
;obj := Map()
;KEPluginParamOutput(paramName, obj)


paramName := "param name"
arr_ids:= ["par1", "par2", "par3"]
arr_values := ["one", "two", "three"]
KEPluginParamOutput(paramName, arr_ids, arr_values)
*/