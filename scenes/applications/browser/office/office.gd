extends PanelContainer
@export var leaderboard:RichTextLabel
@export var fireplace:Label
@export var leaderboard_template:String = "[table=3]%s[/table]"
@export var leaderboard_place_template:String = "\t[cell]%s[/cell][cell]%s[/cell][cell]%s[/cell]"
@export var fire_template:String = "Bottom %s get removed from their place of employment! Good workers stay productive."

func update_rankings() -> void:
	fireplace.text = fire_template % GameManager.productivity_place_quota
	GameManager.workers.sort_custom(sort)
	var text:String = ""
	for i in range(min(len(GameManager.workers),10)):
		var worker := GameManager.workers[i]
		text += leaderboard_place_template % [i,worker.name,floori(worker.productivity)]
	leaderboard.text = leaderboard_template % text

func sort(worker_a:GameManager.Worker,worker_b:GameManager.Worker) -> bool:
	return worker_a.productivity > worker_b.productivity

func _on_visibility_changed() -> void:
	update_rankings()
