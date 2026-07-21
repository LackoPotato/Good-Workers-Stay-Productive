extends PanelContainer
@export var leaderboard:RichTextLabel
@export var yourplace_label:Label
@export var fireplace:Label
@export var yourplace_template:String = "You are currently at %s place with %s points!"
@export var leaderboard_template:String = "[table=3]%s[/table]"
@export var leaderboard_place_template:String = "\t[cell]%s[/cell][cell]%s[/cell][cell]%s[/cell]"
@export var fire_template:String = "Bottom %s get removed from their place of employment! Good workers stay productive."
@export var player_surrounding_amount:int = 3

func update_rankings() -> void:
	fireplace.text = fire_template % GameManager.productivity_place_quota
	GameManager.workers.sort_custom(sort)
	var place:int = GameManager.workers.find(GameManager.you)+1
	yourplace_label.text = yourplace_template % [place,int(GameManager.you.productivity)]
	var text:String = ""
	for i in range(min(len(GameManager.workers),10)):
		var worker := GameManager.workers[i]
		text += leaderboard_place_template % [i+1,worker.name,floori(worker.productivity)]
	if place >= 10:
		text += leaderboard_place_template % ["...","",""]
		for i in range(place-1-player_surrounding_amount,min(place+player_surrounding_amount,len(GameManager.workers))):
			var worker := GameManager.workers[i]
			text += leaderboard_place_template % [i+1,worker.name,floori(worker.productivity)]
	if place+player_surrounding_amount < len(GameManager.workers):
		text += leaderboard_place_template % ["...","",""]
	leaderboard.text = leaderboard_template % text

func sort(worker_a:GameManager.Worker,worker_b:GameManager.Worker) -> bool:
	return worker_a.productivity > worker_b.productivity

func _on_visibility_changed() -> void:
	update_rankings()
