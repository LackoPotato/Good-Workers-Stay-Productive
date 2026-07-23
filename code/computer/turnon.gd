extends PanelContainer
signal start

func _on_login_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			start.emit()




func _on_visibility_changed() -> void:
	%time.text = "It is currently the %s day." % GameManager.int_to_place(max(1,GameManager.day))
