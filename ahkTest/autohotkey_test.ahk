#Persistent


SetTimer Timer, -100

;test_result_Path := Format('{1:#s}\test_result.txt',A_ScriptDir)

global input_variable:= "error"

global test_value_string_message:= "AHK2->AHK value_string message - ERROR"
global test_value_float_message:= "AHK2->AHK value_float message - ERROR"
global test_value_int_message:= "AHK2->AHK value_int message - ERROR"

global test_var_string_message:= "AHK2->AHK var_string message - ERROR"
global test_var_float_message:= "AHK2->AHK var_float message - ERROR"
global test_var_int_message:= "AHK2->AHK2 var_int message - ERROR"

global test_1par_VarString_message:= "AHK2->AHK 1par_VarString message - ERROR"
global test_1par_VarInteger_message:= "AHK2->AHK 1par_VarInteger message - ERROR"
global test_1par_VarFloat_message:= "AHK2->AHK 1par_VarFloat message - ERROR"

global test_arr_string_message:= "AHK2->AHK arr_string message - ERROR"
global test_arr_int_message:= "AHK2->AHK arr_int message - ERROR"
global test_arr_float_message:= "AHK2->AHK arr_float message - ERROR"

global test_1par_arr_string_message:= "AHK2->AHK 1par_arr_string message - ERROR"
global test_1par_arr_int_message:= "AHK2->AHK 1par_arr_int message - ERROR"
global test_1par_arr_float_message:= "AHK2->AHK 1par_arr_float message - ERROR"


global VarString:="test"
global VarInteger:=123
global VarFloat:=33.3

global  arr_int:= Array(1,2,3)
global arr_float:= Array(1.3,2.2,3.4)
global  arr_string:= Array("test1","test2","test3")


OnKEPluginParamInput("InputMessage")


InputMessage(name, value)
{
	;FileAppend StrGet(name) ." " . StrGet(value) . "`n", test_result_Path  	
	
}


Timer() {
  KEPluginParamOutput("value_string","test")
  KEPluginParamOutput("value_int",123)
  KEPluginParamOutput("value_float",33.3)
  
  KEPluginParamOutput("var_string",VarString)
  KEPluginParamOutput("var_int",VarInteger)
  KEPluginParamOutput("var_float",VarFloat)
  
  KEPluginParamOutput(VarString)
  KEPluginParamOutput(VarInteger)
  KEPluginParamOutput(VarFloat)
  
  KEPluginParamOutput("arr_string",arr_string)
  KEPluginParamOutput("arr_int",arr_int)
  KEPluginParamOutput("arr_float",arr_float)
  
  KEPluginParamOutput(arr_string)
  KEPluginParamOutput(arr_int)
  KEPluginParamOutput(arr_float)
}