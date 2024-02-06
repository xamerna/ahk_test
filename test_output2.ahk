#Requires AutoHotkey v2
Persistent

;global space_:=Array()

global VarStringJSON:="[{`"id`":`"one\g\k`n`",`"value`":1.1}]"
global VarInteger := 1
global VarFloat := 3.3
global VarString:="one\g\k`n"

global  arr_int:= Array(1,,3)
global  arr_float:= Array(1.1,2.2,3.3)
global  arr_string := Array("one\g\k`n", "two", "three")


;у объектов тип индекса всегда будет преобразован в string
global  obj_int := {"name1": 1, "name2": 2, "name3": 3}
global  obj_float := {"name1": 1.1, "name2": 2.2, "name3": 3.3}
global  obj_string := {"name1": "one", "name2": "two", "name3": "three"}

;у Map тип индекса должен быть string
global map_int := Map("name1", 1, "name2", 2, "name3", 3)
global map_float := Map("name1", 33.1, "name2", 2.2, "name3", 3.3)
global map_string := Map("name1", "one", "name2", "two", "name3", "three")

global map_int_array := Map("name1", arr_int, "name2", arr_int, "name3", arr_int)

global  obj_int_1 := {"name1": 1}

global arr_int_array:= Array(arr_int,arr_int,arr_int)
global arr_float_array:= Array(arr_float,arr_float,arr_float)
global arr_string_array:= Array(arr_string,arr_string,arr_string)

global arr_int_array_arr:= Array(arr_string,arr_int)
global arr_float_array_arr:= Array(arr_string,arr_float)
global arr_string_array_arr:= Array(arr_string,arr_string)


Sleep 1000


paramName := 'param name'
obj := Map(1, 'value1', 2, 'value2')
KEPluginParamOutput(paramName, obj)


KEPluginParamOutput(arr_int)


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

KEPluginParamOutput(map_int) 		;преобразуется в {["name1":1,"name2":2,"name3":3]}
KEPluginParamOutput(map_float)		;преобразуется в {["name1":1.1,"name2":2.2,"name3":3.3]}
KEPluginParamOutput(map_string)		;преобразуется в {["name1":"one","name2":"two","name3":"three"]}
KEPluginParamOutput(map_int_array) 	;преобразуется в {[{"name1",[{"id":1,"value":1},{"id":2,"value":2},{"id":3,"value":3}]},{"id":"name2","value":[{"id":1,"value":1},{"id":2,"value":2},{"id":3,"value":3}]},{"id":"name3","value":[{"id":1,"value":1},{"id":2,"value":2},{"id":3,"value":3}]}]}

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

KEPluginParamOutput("map_int_to_array",map_int)				;{"map_int_to_array":[{"id":"id1","value":1},{"id":"id2","value":2},{"id":"id3","value":3}]}
KEPluginParamOutput("map_float_to_array",map_float)			;{"map_float_to_array":[{"id":"id1","value":1.1},{"id":"id2","value":2.2},{"id":"id3","value":3.3}]}
KEPluginParamOutput("map_string_to_array",map_string)		;{"map_string_to_array":[{"id":"id1","value":"one"},{"id":"id2","value":"two"},{"id":"id3","value":"three"}]}


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

paramName := 'param name'
paramValue := {} ; пустой объект
KEPluginParamOutput(paramName, paramValue)


KEPluginParamOutput(Map('key', 'value','key2', 'value2'))
KEPluginParamOutput(Array("one"),Array(1))						;{"one":1}
KEPluginParamOutput(obj_int_1)  


