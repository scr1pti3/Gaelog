extends Resource

class_name DialogueCursor

export var s_flow : Array
export var s_cursor : Dictionary
export var s_start : Dictionary
export var s_end : Array
export var s_port_table : Dictionary

var _prev : Dictionary


func _init(graph_edit: GraphEdit) -> void:
	assert(graph_edit.has_method("connected_ports"))
	
	var connection_list = graph_edit.get_connection_list()
	var start = GDUtil.array_dictionary_popv(connection_list, [{"from": "Start"}])
	
	if start:
		s_start = start
		s_port_table[start.from] = graph_edit.connected_ports(start.from)
		_populate_port_table(start, connection_list, graph_edit)
	
		s_cursor = start()


func get_node_name() -> String:
	return s_cursor.name


func get_actions_left() -> Array:
	return s_cursor.from.action.duplicate()


func get_actions_right() -> Array:
	return s_cursor.to.action.duplicate()


func get_universals_left() -> Array:
	return s_cursor.from.universal.duplicate()


func get_universals_right() -> Array:
	return s_cursor.to.universal.duplicate()


func size() -> int:
	return s_port_table.size()


func reset() -> void:
	s_cursor = start()


func start() -> Dictionary:
	return s_port_table.get("Start", {}) 


func end() -> Array:
	return s_end


func is_end() -> bool:
	return s_cursor.empty()


func is_start() -> bool:
	return s_cursor == start() or s_start.empty()


func is_invalid() -> bool:
	return s_end.empty()


func next(fork := 0) -> void:
	if is_end():
		return
	
	_prev = s_cursor
		
	fork = clamp(fork, 0, s_cursor.to.flow.size())
	var connection = s_cursor.to.flow[fork]

	s_cursor = s_port_table.get(connection.to, {})


func prev(fork := -777) -> void:
	if is_start():
		return
	
	if fork == -777:
		s_cursor = _prev
	else:
		fork = clamp(fork, 0, s_cursor.from.flow.size() - 1)
		var connection = s_cursor.from.flow[fork]

		s_cursor = s_port_table.get(connection.from, start())
	
	
func _populate_port_table(connection: Dictionary, connection_list: Array, dialogue_graph: GraphEdit) -> void:
	assert(dialogue_graph.has_method("connected_ports"))
	
	var graph_node : GraphNode = dialogue_graph.get_node(connection.to)
	
	if graph_node is GNEnd:
		s_end.append(connection)
		
		return

	var node_connection : Dictionary = dialogue_graph.connected_ports(connection.to)
	
	s_port_table[node_connection.name] = node_connection
	
	for port in node_connection.to:
		for connection in node_connection.to[port]:
			_populate_port_table(connection, connection_list, dialogue_graph)
