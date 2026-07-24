extends PanelContainer


func _on__pressed() -> void:
	GameManager.add_productivity(100)
	GameManager.cheated = true


func _on_ten_pressed() -> void:
	GameManager.add_productivity(10)
	GameManager.cheated = true


func _on_apps_pressed() -> void:
	#TODO ADD THIS
	GameManager.cheated = true
