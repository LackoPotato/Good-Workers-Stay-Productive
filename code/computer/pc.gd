extends Control
@export var windowroot:SubViewport
@export var windowselectorroot:HBoxContainer
@export var gametimer:Timer
var active_windows:Dictionary[int,PCWindow]
@export var window_scenes:Dictionary[int,PackedScene]
@export var active_apps_per_day:Array[Button]
@export var alert_sound:AudioStream
func _ready() -> void:
	GameManager.update_background.connect(change_background)
	change_background(GameManager.background)

func restart() -> void:
	for id in active_windows:
		active_windows[id].queue_free()
	active_windows.clear()
	for child in windowselectorroot.get_children():
		child.queue_free()

func start_day() -> void:
	GameManager.new_day()
	restart()
	gametimer.start()
	GameManager.time = 0
	GameManager.start()
	set_time_label()
	for i in min(0,max(GameManager.day,len(active_apps_per_day))):
		active_apps_per_day[i].show()
	%shutdownprompt.close()

func set_time_label() -> void:
	%time.text = "Day %s | %s" % [GameManager.day, GameManager.get_string_time()]

func create_window(id:int,scene:PackedScene) -> PCWindow:
	if id in active_windows:
		active_windows[id].open()
		return active_windows[id]
	
	var window:PCWindow = scene.instantiate()
	active_windows[id] = window
	window.id = id
	windowroot.add_child(window)
	
	var button:WindowSelector = WindowSelector.new()
	windowselectorroot.add_child(button)
	window.connect("updated_text",button.update_text)
	window.connect("inactive",button.deselect)
	window.connect("active",button.select)
	window.request_snap.connect(set_snap)
	button.connect("make_active",make_window_active)
	button.id =id
	window.update_text(window.title)
	window.grab_focus()
	return window

func make_window_active(id:int) -> void:
	if id in active_windows:
		var active_window := active_windows[id]
		active_window.open()
	else:
		push_warning("Window with id %s does not exist" % id)

var last_pressed_id:int = -1
var last_pressed_time:int = 0
var launch_app_ms_limit:int = 1000
func app_icon_pressed(id: int) -> void:
	if last_pressed_id != id:
		last_pressed_id = id
		last_pressed_time = Time.get_ticks_msec()
	elif Time.get_ticks_msec()-last_pressed_time < launch_app_ms_limit:
		create_window(id,window_scenes[id])
	

func change_background(texture:Texture) -> void:
	%background.texture = texture

func on_power_pressed() -> void:
	%shutdownprompt.open()
	%shutdownprompt.size = Vector2i(350,100)
	%audio.stream = alert_sound
	%audio.play()


var shutdown_tick_seconds:float = 0.5
var shutdown_tick_count:int = 8
func shutdown() -> void:
	print("shutdown")
	transition(%pc,%shutdown)
	var tween:Tween = get_tree().create_tween()
	for i in shutdown_tick_count:
		tween.tween_callback(%shutdown.tick)
		tween.tween_interval(shutdown_tick_seconds)
	tween.tween_callback(%results.show_results)
	tween.tween_callback(gametimer.stop)

func set_snap(window:PCWindow) -> void:
	self.apply_snap_window = window
	for panel in snap_position_panels:
		panel.self_modulate.a = 0
	match window.snap_to:
		PCWindow.POSITION.TOPLEFT:
			%tl.self_modulate.a = 1
		PCWindow.POSITION.TOPRIGHT:
			%tr.self_modulate.a = 1
		PCWindow.POSITION.BOTTOMLEFT:
			%bl.self_modulate.a = 1
		PCWindow.POSITION.BOTTOMRIGHT:
			%br.self_modulate.a = 1
			

var apply_snap_window:PCWindow
@onready var snap_position_panels:Array[Panel] = [%tl,%tr,%bl,%br]
func _input(event: InputEvent) -> void:
	if apply_snap_window and event is InputEventMouseButton:
		if not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if apply_snap_window.snap_to:
				apply_snap_window.snap_to_corner()
			for panel in snap_position_panels:
				panel.self_modulate.a = 0


func _on_gametimer_timeout() -> void:
	GameManager.tick()
	set_time_label()


func _on_results_next() -> void:
	transition(%shutdown,%turnon,1)



func _on_turnon_start() -> void:
	transition(%turnon,%pc)
	restart()
	start_day()
	gametimer.start()

func transition(from:Control,to:Control,wait_time:float = 0) -> void:
	%shutdown.hide()
	%pc.hide()
	%results.hide()
	%turnon.hide()
	%transition_panel_top.show()
	%transition_panel_top.modulate.a = 0
	from.show()
	to.hide()
	
	var tween:Tween = get_tree().create_tween()
	tween.tween_property(%transition_panel_top,"modulate:a",1,0.5)
	tween.tween_callback(from.hide)
	tween.tween_interval(wait_time)
	tween.tween_callback(to.show)
	tween.tween_property(%transition_panel_top,"modulate:a",0,0.5)
	tween.tween_callback(%transition_panel_top.hide)
