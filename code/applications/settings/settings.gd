extends PCWindow

var audio_linear_min:float = 0
var audio_linear_max:float = 2

func set_background(texture: Texture2D) -> void:
	GameManager.background = texture

func _on_master_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"),value)


func _on_music_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Music"),value)


func _on_sound_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Sound"),value)

func update_time_scale(value: int) -> void:
	@warning_ignore("integer_division")
	GameManager.time = (GameManager.time/GameManager.max_time)*value
	GameManager.max_time = value
	update_time_label()

func update_time_label() -> void:
	@warning_ignore("integer_division")
	%time.text = "Every second that passes %2d seconds pass ingame." % GameManager.get_time_ratio()


func _on_opened() -> void:
	%timescale.value = GameManager.max_time
	%master.value = AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("Master"))
	%music.value = AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("Music"))
	%sound.value = AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("Sound"))
	%pslabel.text = "Productivty x%.1f" % GameManager.productivity_scale
	%prodscale.value = GameManager.productivity_scale
	update_time_label()


func on_reset_game_settings_pressed() -> void:
	%timescale.value = GameManager.default_max_time
	update_time_scale(GameManager.default_max_time)
	GameManager.productivity_scale = 1
	%pslabel.text = "Productivty x%.1f" % GameManager.productivity_scale
	%prodscale.value = GameManager.productivity_scale


func _on_restart_pressed() -> void:
	GameManager.reset()
	get_tree().reload_current_scene()


func _on_prodscale_value_changed(value: float) -> void:
	if value != 1:
		GameManager.productivity_has_been_changed = true
	GameManager.productivity_scale = value
	%pslabel.text = "Productivty x%.1f" % GameManager.productivity_scale
