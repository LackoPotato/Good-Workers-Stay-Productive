extends Control
@export var windowroot:SubViewport
@export var windowselectorroot:HBoxContainer
@export var gametimer:Timer
var active_windows:Dictionary[int,PCWindow]
@export var window_scenes:Dictionary[int,PackedScene]
@export var task_apps:Array[Button]
@export var alert_sound:AudioStream
@export var normal_shutdown_prompt:String = "would you like to shut down your pc\nand stop being productive? (ends your day)"
@export var work_ended_shutdown_prompt:String = "work has finished, would you like to shutdown\nyour pc?"
@export var path_root:Node2D

@export var bug_scene:PackedScene
@export var ticks_since_last_bug:int = 1
@export var bug_chance_per_tick:float = 0.025
@export var bug_multiple_chance:float = 0.3
@export var max_bugs:int = 25
@export var pity_bug_spawn_tick_frequency:int = 45

@export var music_boot:AudioStream
@export var music_intro:AudioStream
@export var music_loop:AudioStream
@export var music_shutdown:AudioStream

@export var ticks:Array[AudioStream]
@export var tocks:Array[AudioStream]
var bug_chance:float = 0

func _ready() -> void:
	GameManager.update_background.connect(change_background)
	change_background(GameManager.background)
	GameManager.work_ended.connect(work_finished)

@export var warning_timer:int = 30
func _on_gametimer_timeout() -> void:
	GameManager.tick()
	if (Task.ValidTasks.BUG in GameManager.unlocked_tasks):
		if (ticks_since_last_bug == pity_bug_spawn_tick_frequency) or (randf() <= bug_chance) or (ticks_since_last_bug == 0 and randf() <= bug_multiple_chance):
			spawn_bug()
			bug_chance = 0
			ticks_since_last_bug = 0
		bug_chance += bug_chance_per_tick
	if not shutting_down and (GameManager.max_time-GameManager.time) <= warning_timer:
		%clock.stop()
		%clock.stream = ticks[randi_range(0,len(ticks)-1)] if (GameManager.max_time-GameManager.time) % 2 == 0 else tocks[randi_range(0,len(tocks)-1)]
		%clock.play()
	print(%clock.volume_linear)
	set_time_label()

func get_bug_count() -> int:
	var count:int = 0
	for child in path_root.get_children():
		count+=child.get_child_count()
	return count

func spawn_bug() -> void:
	if get_bug_count() <= max_bugs:
		var root:Path2D = path_root.get_children()[randi_range(0,path_root.get_child_count()-1)] as Path2D
		var bug := bug_scene.instantiate() as PathFollow2D
		root.add_child(bug)

func work_finished() -> void:
	if not skipping_day:
		if not %shutdownprompt.is_open:
			%shutdownprompt.get_node("%prompt").text = work_ended_shutdown_prompt
		show_shutdown_prompt()
		gametimer.stop()

func restart() -> void:
	for id in active_windows:
		active_windows[id].queue_free()
	active_windows.clear()
	for child in windowselectorroot.get_children():
		child.queue_free()
	for child in path_root.get_children():
		for bug in child.get_children():
			bug.queue_free()

func init_day() -> void:
	
	ticks_since_last_bug = 1
	GameManager.new_day()
	restart()
	GameManager.time = 0
	GameManager.start()
	set_time_label()
	for app in task_apps:
		if app:
			app.hide()
	for app in GameManager.unlocked_tasks:
		if app < len(task_apps):
			if task_apps[app]:
				task_apps[app].show()
	%shutdownprompt.close()
	%music.volume_db = 0
	%music.stream = music_boot
	%music.play()
	await %music.finished
	if not shutting_down:
		%music.stream = music_intro
		%music.play()
	await %music.finished
	if not shutting_down:
		%music.stream = music_loop
		%music.play()

func set_time_label() -> void:
	%time.text = "Day %s | Up next: %s | %s" % [GameManager.day, "Nothing" if GameManager.has_work_ended() else "Work until %s" % GameManager.int_to_time(GameManager.work_end_time),GameManager.get_string_time()]

#region App Management
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
	else:
		last_pressed_time = Time.get_ticks_msec()
	
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

#endregion

#region Transitions

func change_background(texture:Texture) -> void:
	%background.texture = texture

func on_power_pressed() -> void:
	if not %shutdownprompt.is_open:
		%shutdownprompt.get_node("%prompt").text = normal_shutdown_prompt
	show_shutdown_prompt()


func show_shutdown_prompt() -> void:
	%shutdownprompt.open()
	%shutdownprompt.size = Vector2i(350,100)
	%audio.stream = alert_sound
	%audio.play()

var shutdown_tick_seconds:float = 0.5
var shutdown_tick_count:int = 14
var skipping_day:bool = false
var shutting_down:bool = false
func shutdown() -> void:
	print("shutdown")
	skipping_day = false
	shutting_down = true
	var tween:Tween = get_tree().create_tween()
	tween.tween_property(%music,"volume_linear",0,0.5)
	tween.tween_callback(%music.stop)
	if not GameManager.has_work_ended():
		skipping_day = true
		RichTextLabel
		%time_passer_label.text = "Passing time until work ends:\n[scroll max_time=1]%s[/scroll]" % GameManager.int_to_time(GameManager.work_end_time)
		%time_passer_label.reload_effects()
		tween.tween_callback(transition.bind(%pc,%time_passer))
		tween.tween_interval(4)
		tween.tween_callback(skip_to_end_of_work)
		tween.tween_callback(transition.bind(%time_passer,%shutdown))
	else:
		transition(%pc,%shutdown)
	tween.tween_callback(play_shutdown)
	for i in shutdown_tick_count:
		tween.tween_callback(%shutdown.tick)
		tween.tween_interval(shutdown_tick_seconds)
	tween.tween_await(%music.finished)
	tween.tween_callback(%music.stop)
	tween.tween_callback(%results.show_results)
	tween.tween_callback(gametimer.stop)
	tween.tween_callback(set.bind("shutting_down",false))
	tween.tween_callback(set.bind("skipping_day",false))

func play_shutdown() -> void:
	%music.volume_db = 0
	%music.stream = music_shutdown
	%music.play()

func skip_to_end_of_work() -> void:
	for i in range(GameManager.max_time-GameManager.time):
		GameManager.tick()
	GameManager.sort_workers()
	print(GameManager.workers[0].productivity)

func _on_results_next() -> void:
	transition(%shutdown,%turnon,1)

func _on_turnon_start() -> void:
	%turnon.update_text()
	transition(%turnon,%pc)
	if not GameManager.has_passed():
		GameManager.reset()
	restart()
	init_day()
	gametimer.start()

func transition(from:Control,to:Control,wait_time:float = 0) -> void:
	%shutdown.hide()
	%pc.hide()
	%results.hide()
	%turnon.hide()
	%time_passer.hide()
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
#endregion
