extends Control
@export var windowroot:SubViewport
@export var windowselectorroot:HBoxContainer

var active_windows:Dictionary[int,PCWindow]
@export var window_scenes:Dictionary[int,PackedScene]
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
	
func _ready() -> void:
	GameManager.update_background.connect(change_background)

var shutdown_tick_seconds:float = 0.5
var shutdown_tick_count:int = 8
func shutdown() -> void:
	print("shutdown")
	%pc.hide()
	var tween:Tween = get_tree().create_tween()
	for i in shutdown_tick_count:
		tween.tween_callback(%shutdown.tick)
		tween.tween_interval(shutdown_tick_seconds)

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
