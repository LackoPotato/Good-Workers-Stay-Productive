extends Window
class_name PCWindow
@export var id:int = 0
@export var open_on_ready:bool = true
signal active()
signal inactive()
signal closed(id:int)
signal opened(id:int)
signal updated_text(text:String)
signal request_snap(window:PCWindow)
var is_open:bool = false
@export var window_title_size := 30
@export var window_side_size := 5
enum POSITION{
	NONE,
	TOPLEFT,
	TOPRIGHT,
	BOTTOMLEFT,
	BOTTOMRIGHT,
	LEFT,
	RIGHT,
	BOTTOM,
	TOP
}
var pcwindowtween:Tween
var size_before_animation:Vector2i
@onready var position_before_animation:Vector2i = (get_tree().root.content_scale_size/2)-size/2
func _init() -> void:
	add_theme_constant_override("resize_margin",8)
	close_requested.connect(close)
	focus_entered.connect(active.emit)
	focus_exited.connect(inactive.emit)
	size_before_animation = size
	is_open = false
	call_deferred("launch_on_ready")

@export var corner_snap_range:Vector2i = Vector2i(40,40)
@export var taskmanager_size:Vector2i = Vector2i(640,40) # The bar at the bottom, it's what KDE calls it at least (I think...), used to account for sizing differences
func get_corner() -> POSITION:
	var screen_size := get_tree().root.content_scale_size
	var mouse_position:Vector2i = position+Vector2i(get_mouse_position())
	if Rect2i(Vector2(0,0),corner_snap_range).has_point(mouse_position):
		return POSITION.TOPLEFT
	elif Rect2i(Vector2i(screen_size.x-corner_snap_range.x,0),corner_snap_range).has_point(mouse_position):
		return POSITION.TOPRIGHT
	elif Rect2i(Vector2i(0,screen_size.y-corner_snap_range.y)-Vector2i(0,taskmanager_size.y),corner_snap_range).has_point(mouse_position):
		return POSITION.BOTTOMLEFT
	elif Rect2i(screen_size-corner_snap_range-Vector2i(0,taskmanager_size.y),corner_snap_range).has_point(mouse_position):
		return POSITION.BOTTOMRIGHT
	return POSITION.NONE

var snap_to:POSITION
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_POSITION_CHANGED:
		snap_to = get_corner()
		request_snap.emit(self)
		var screen_size := get_tree().root.content_scale_size
		if position.y < window_title_size:
			position.y = window_title_size
		elif position.y > screen_size.y-taskmanager_size.y:
			position.y = screen_size.y-taskmanager_size.y
		if position.x < 0:
			position.x = 0
		elif position.x > screen_size.x:
			position.x = screen_size.x



func snap_to_corner() -> void:
	var screen_size := get_tree().root.content_scale_size-Vector2i(0,taskmanager_size.y)
	@warning_ignore("integer_division")
	var new_size := (screen_size/2) - Vector2i(window_side_size,window_title_size)
	match snap_to:
		POSITION.TOPLEFT:
			size = new_size
			position = Vector2i(0,window_title_size)
		POSITION.TOPRIGHT:
			size = new_size
			position = Vector2i(screen_size.x-size.x,window_title_size)
		POSITION.BOTTOMLEFT:
			size = new_size
			position = Vector2i(0,screen_size.y-size.y)
		POSITION.BOTTOMRIGHT:
			size = new_size
			position = screen_size-size
	snap_to = POSITION.NONE

func launch_on_ready() -> void: #weird bypass where ready() is not called by my script on window open
	if open_on_ready:
		open()

func close() -> void:
	if is_open:
		is_open = false
		if pcwindowtween and pcwindowtween.is_running():
			pcwindowtween.kill()
		size_before_animation = size
		position_before_animation = position
		closed.emit(id)
		grab_focus()
		inactive.emit()
		pcwindowtween = get_tree().create_tween()
		pcwindowtween.tween_callback(show)
		pcwindowtween.tween_property(self,"size:y",0,0.1)
		pcwindowtween.tween_callback(hide)

func open() -> void:
	if not is_open:
		is_open = true
		if pcwindowtween and pcwindowtween.is_running():
			pcwindowtween.kill()
		size.y = 0
		position = position_before_animation
		opened.emit()
		pcwindowtween = get_tree().create_tween()
		pcwindowtween.tween_callback(show)
		pcwindowtween.tween_interval(0.05)
		pcwindowtween.tween_property(self,"size:y",size_before_animation.y,0.1)
	grab_focus()

func update_text(new_text:String) -> void:
	title = new_text
	updated_text.emit(title)
