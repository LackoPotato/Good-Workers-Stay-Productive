extends PanelContainer
signal start

func _on_login_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			start.emit()




func _on_visibility_changed() -> void:
	update_text()

func update_text() -> void:
	if GameManager.has_passed():
		%time.text = "It is currently the %s day." % GameManager.int_to_place(max(1,GameManager.day+1))
	else:
		%time.text = "You got fired on the %s day!" % GameManager.int_to_place(max(1,GameManager.day+1)-1)
