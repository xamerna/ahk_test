Persistent

SetTimer Timer, -100

global input_variable:= "ERROR"

count_test:=0

global test_value_string_message:= "AHK->AHK2 value_string message - ERROR"
global test_value_float_message:= "AHK->AHK2 value_float message - ERROR"
global test_value_int_message:= "AHK->AHK2 value_int message - ERROR"

global test_var_string_message:= "AHK->AHK2 var_string message - ERROR"
global test_var_float_message:= "AHK->AHK2 var_float message - ERROR"
global test_var_int_message:= "AHK->AHK2 var_int message - ERROR"

global VarString:="test"
global VarInteger:=123
global VarFloat:=33.3

global  arr_int:= Array(1,2,3)
global arr_float:= Array(1.3,2.2,3.4)
global  arr_string:= Array("1","2","3")

OnKEPluginParamInput  InputMessage


InputMessage(name, value)
{
	
	if ( Instr(name,"value_string"))
	{
		if (Instr(value,"test"))
			global test_value_string_message:="AHK->AHK2 value_string message - OK " . value
		else 
			global test_value_string_message:="AHK->AHK2 value_string message - ERROR " . value
		
	}
	if ( Instr(name,"value_float"))
	{
		if (Instr(value,"33.3"))
			global test_value_float_message:= "AHK->AHK2 value_float message - OK " . value
		else 
			global test_value_float_message:= "AHK->AHK2 value_float message - ERROR " . value
		
	}
	if ( Instr(name,"value_int"))
	{
		if ( Instr(value,"123"))
			global test_value_int_message:= "AHK->AHK2 value_int message - OK " . value
		else 
			global test_value_int_message:= "AHK->AHK2 value_int message - ERROR " . value
		
	}	
	
	if ( Instr(name,"var_string"))
	{
		if (Instr(value,"test"))
			global test_var_string_message:="AHK->AHK2 var_string message - OK " . value
		else 
			global test_var_string_message:="AHK->AHK2 var_string message - ERROR " . value
		
	}
	if ( Instr(name,"var_float"))
	{
		if (Instr(value,"33.3"))
			global test_var_float_message:= "AHK->AHK2 var_float message - OK " . value
		else 
			global test_var_float_message:= "AHK->AHK2 var_float message - ERROR " . value
		
	}
	if ( Instr(name,"var_int") )
	{
		if (Instr(value,"123"))
			global test_var_int_message:= "AHK->AHK2 var_int message - OK " . value
		else 
			global test_var_int_message:= "AHK->AHK2 var_int message - ERROR " . value
		
	}	
	
	
	
	
	;MsgBox name	":" value

	
	
}

Timer() {
  KEPluginParamOutput("value_string","test")
  KEPluginParamOutput("value_float",33.3)
  KEPluginParamOutput("value_int",123)
  
  KEPluginParamOutput("var_string",VarString)
  KEPluginParamOutput("var_int",VarInteger)
  KEPluginParamOutput("var_float",VarFloat)
}
