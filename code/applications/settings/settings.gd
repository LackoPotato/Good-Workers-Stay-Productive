extends PCWindow

var audio_linear_min:float = 0
var audio_linear_max:float = 2

func set_background(texture: Texture2D) -> void:
	GameManager.update_background.emit(texture)

func _on_master_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"),value)


func _on_music_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Music"),value)


func _on_sound_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Sound"),value)
