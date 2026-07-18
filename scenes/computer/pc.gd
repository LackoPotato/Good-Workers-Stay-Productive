extends VBoxContainer
@export var windowroot:SubViewport
@export var windowselectorroot:HBoxContainer

var active_windows:Dictionary[int,PCWindow]

func create_window(id:int,text:String,scene:PackedScene) -> PCWindow:
	if id in active_windows:
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
	button.connect("make_active",make_window_active)
	button.id =id
	window.update_text(text)
	window.grab_focus()
	return window

func make_window_active(id:int) -> void:
	if id in active_windows:
		var active_window := active_windows[id]
		active_window.open()
	else:
		push_warning("Window with id %s does not exist" % id)

func _ready() -> void:
	create_window(0,"Untitled Document",preload("res://scenes/applications/textedit.tscn"))
	create_window(1,"Untitled Document",preload("res://scenes/applications/textedit.tscn"))
