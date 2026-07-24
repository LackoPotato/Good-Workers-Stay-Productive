extends PanelContainer
@export var leaderboard:RichTextLabel
@export var yourplace_label:RichTextLabel
@export var fireplace:Label
@export var yourplace_template:String = "You are currently at [scroll time=0.1]%s[/scroll] place with [scroll time=0.1]%s[/scroll] points!"
@export var leaderboard_template:String = "[table=3]%s[/table]"
@export var leaderboard_place_template:String = "\t[cell]%s[/cell][cell]%s[/cell][cell][scroll time=0.1]%s[/scroll][/cell]"
@export var fire_template:String = "Bottom %s get removed from their place of employment! Good workers stay productive."
@export var robot_worker_template:String = "Robot Workers are projected to score %s, all working below this score by the end of the work day are elevated to the prestigious rank of worked"
@export var player_surrounding_amount:int = 3

func update_rankings() -> void:
	fireplace.visible = (GameManager.productivity_place_quota < len(GameManager.workers)) or (GameManager.minimum_score_required != -1)
	fireplace.text = (fire_template % GameManager.productivity_place_quota) if (GameManager.minimum_score_required == -1) else robot_worker_template % GameManager.minimum_score_required
	var place:int = GameManager.get_place(GameManager.you)
	yourplace_label.text = yourplace_template % [GameManager.int_to_place(place),int(GameManager.you.productivity)]
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
	yourplace_label.text = ""
	update_rankings()
