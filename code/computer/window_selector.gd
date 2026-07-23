extends Button
class_name WindowSelector
@export var selected_scale:Vector2 = Vector2(1,1)
@export var normal_scale:Vector2 = Vector2(0.8,0.8)
var tween:Tween
var id:int
var active:bool = false
signal make_active(id:int)

func _init() -> void:
	offset_transform_enabled = true
	flat = true
	connect("pressed",select)

func select() -> void:
	if active:
		if tween and tween.is_running():
			tween.kill()
			offset_transform_scale = normal_scale
		tween = get_tree().create_tween()
		tween.tween_property(self,"offset_transform_scale",selected_scale,0.1)
		make_active.emit(id)
		active = false

func deselect() -> void:
	if not active and get_tree():
		if tween and tween.is_running():
			tween.kill()
			offset_transform_scale = selected_scale
		tween = get_tree().create_tween()
		tween.tween_property(self,"offset_transform_scale",normal_scale,0.1)
		active = true

@warning_ignore("shadowed_variable_base_class")
func update_text(text:String) -> void:
	self.text = text
