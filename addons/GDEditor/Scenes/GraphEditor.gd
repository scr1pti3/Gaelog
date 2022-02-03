tool

extends VSplitContainer

onready var _node_selection := find_node("NodeSelection")


func _ready() -> void:
	if not get_dialogue_preview():
		var standard_view : GDDialogueView = load(
				GDUtil.resolve("GDStandardView.tscn")).instance()
		
		set_dialogue_preview(standard_view)


func get_dialogue_preview() -> GDDialogueView:
	var first_child : Node = get_child(0)
	
	if first_child is GDDialogueView:
		return first_child as GDDialogueView
	else:
		return null


func get_dialogue_graph() -> DialogueGraph:
	return $"MainContainer/DialogueGraph" as DialogueGraph


func set_dialogue_preview(dialogue_view: GDDialogueView) -> void:
	dialogue_view.hide()
	
	var current_dialogue_view := get_dialogue_preview()
	
	if current_dialogue_view:
		current_dialogue_view.queue_free()
		
		add_child(dialogue_view)
		move_child(dialogue_view, 0)
		
		for component in dialogue_view.get_components():
			var idx : int = _node_selection.get_item_count()
			_node_selection.add_item(component.get_component_name(), idx)
			_node_selection.set_item_metadata(idx, component)
	else:
		add_child(dialogue_view)
		move_child(dialogue_view, 0)


func save() -> void:
	get_dialogue_graph().save()
