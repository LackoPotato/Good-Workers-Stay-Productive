@tool
extends TextureButton
signal choose(texture:Texture2D)
@export var texture:Texture:
	set(t):
		texture = t
		texture_normal = t
		texture_pressed = t
		texture_disabled = t
		texture_focused = t
		texture_hover = t

func _on_pressed() -> void:
	choose.emit(texture)

var hover:bool = false
func _on_mouse_entered() -> void:
	hover = true
	self_modulate = self_modulate.darkened(0.5)


func _on_mouse_exited() -> void:
	hover = false
	self_modulate = Color(1,1,1,1)

func _on_button_down() -> void:
	self_modulate = Color(0,0,0,1)

func _on_button_up() -> void:
	self_modulate = Color(1,1,1,1)
	if hover:
		self_modulate = self_modulate.darkened(0.5)
