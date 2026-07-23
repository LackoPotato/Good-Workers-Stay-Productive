extends Control
signal next()
@export var image_size:int = 96
@export var texture:AtlasTexture
@export var results_time:float = 3
@export var time_rank:float = 2
@export var day:RichTextLabel
@export var template_text:String = "[scroll max_time=%s]%s[/scroll]"
@export var tasks_finished:HBoxContainer
@export var productivity:HBoxContainer
@export var place:HBoxContainer
@export var message:Label
@export var rankimg:TextureRect

@export var drumroll:AudioStream
@export var applause:AudioStream
@export var audio:AudioStreamPlayer

func _ready() -> void:
	rankimg.texture = texture
	hide()

var rank_messages:Array[String] = [
	"You're fired.",
	"Could be better",
	"Just OK",
	"Adequate",
	"Good."
]
func clear(box:HBoxContainer) -> void:
	get_progress_label(box).text = "0"

func get_progress_label(box:HBoxContainer) -> RichTextLabel:
	return (box.get_node("%progress") as RichTextLabel)

func show_results() -> void:
	%speed_change.visible = GameManager.default_max_time != GameManager.max_time
	%speed_change.text = "%s IGT seconds per second" % GameManager.get_time_ratio()
	clear(tasks_finished)
	clear(productivity)
	texture.region.position.x = -image_size
	var pposition:int = GameManager.get_place(GameManager.you)
	var rank:int
	audio.stream = drumroll
	audio.playing = true
	var passed:bool = GameManager.has_passed()
	if passed:
		var ratio:float = ((pposition)/(len(GameManager.workers)))
		print(ratio)
		rank = max(1,floori((1-ratio) * 4))
	else:
		rank = 0
	day.text = "Day "
	get_progress_label(place).text = "0 / %s" % len(GameManager.workers)
	message.hide()
	message.text = rank_messages[rank]
	offset_transform_position.y = -600
	show()
	var time_per_show:float = results_time/4
	var start_tween:Tween = get_tree().create_tween().set_trans(Tween.TRANS_BOUNCE)
	start_tween.tween_property(self,"offset_transform_position:y",0,2)
	var tween:Tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_subtween(start_tween)
	tween.tween_callback(
		day.set.bind(
			"text",
			"Day %s" % ("[scroll max_time=%s size=32]%s[/scroll]" % [time_per_show,GameManager.day])
		)
	)
	tween.tween_interval(time_per_show)
	tween.tween_callback(
		get_progress_label(tasks_finished).set.bind(
			"text",
			template_text % [time_per_show,GameManager.tasks_finished]
		)
	)
	tween.tween_interval(time_per_show)
	tween.tween_callback(
		get_progress_label(productivity).set.bind(
			"text",
			template_text % [time_per_show,int(GameManager.you.productivity)]
		)
	)
	tween.tween_interval(time_per_show)
	tween.tween_callback(
		get_progress_label(place).set.bind(
			"text",
			"%s / %s" % [template_text % [time_per_show,pposition],len(GameManager.workers)]
		)
	)
	tween.tween_interval(time_per_show)
	tween.tween_property(texture,"region:position:x",image_size*rank,time_rank)
	tween.tween_callback(message.show)
	tween.tween_callback(play_applause)

func play_applause() -> void:
	audio.stop()
	audio.stream = applause
	audio.play()


func on_next_pressed() -> void:
	var tween:Tween = get_tree().create_tween().set_ease(Tween.EASE_IN)
	next.emit()
	tween.tween_property(self,"offset_transform_position:y",-600,0.5)
	tween.tween_callback(hide)
