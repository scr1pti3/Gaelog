tool

extends GDGraphNode

class_name GDMessageGN

export(String, MULTILINE) var s_message 

onready var _message_edit := find_node("MessageEdit")
onready var _character_selection := find_node("CharacterSelection")
onready var _expression_selection := find_node("ExpressionSelection")


func _ready() -> void:
	_message_edit.text = s_message
	_character_selection.graph_node = self


func get_component_name() -> String:
	return "Message"


func get_character_selection() -> OptionButton:
	return _character_selection as OptionButton


func connect_to(graph_node: GDGraphNode, from_slot: int, to_slot: int) -> bool:
	if self is graph_node.get_script():
		# deny action outport to connect to GDMessageGN action inport
		if graph_node.get_connection_input_type(from_slot) == PortType.ACTION and \
			get_connection_output_type(to_slot) == PortType.ACTION:
			return false
	
	return true


func _on_CharacterSelection_item_selected(index: int) -> void:
	_expression_selection.clear()


func _on_CharacterSelection_character_selected_left() -> void:
	_expression_selection.clear()


func _on_ExpressionSelection_pressed() -> void:
	if _character_selection.selected == -1:
		return
		
	var character_data : CharacterData = _character_selection.get_selected_metadata()
	
	var selected_expression : CharacterExpressionData = _expression_selection.get_selected_metadata()
	
	_expression_selection.clear()
	
	for expression in character_data.character_expressions:
		assert(expression is CharacterExpressionData)
		
		var idx: int = _expression_selection.get_item_count()
		
		_expression_selection.add_item(expression.expression_name)
		_expression_selection.set_item_metadata(idx, expression)
		
		if expression == selected_expression:
			_expression_selection.select(idx)


func _on_MessageEdit_text_changed() -> void:
	s_message = _message_edit.text
