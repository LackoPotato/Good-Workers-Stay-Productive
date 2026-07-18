extends PanelContainer
var focused:bool = true
@export var document:RichTextLabel
@export var editor:LineEdit
var word:String = "testing"
var unfinished_template:String = "[color=#333333]%s[/color]"
var wrong_template:String = "[s][color=#f91d04]%s[/color][/s]"
var finished:String = ""

func _process(delta: float) -> void:
	if focused:
		editor.grab_focus()

func get_edited_word() -> String:
	var current:String = editor.text
	var escaped:String = current.replace("[","[lb]").replace("]","[rb]")
	var edited:String = ""
	if word.begins_with(current):
		edited += escaped
	else:
		edited += wrong_template % escaped
	return edited + unfinished_template % word.substr(len(current))

func correct_word() -> bool:
	return editor.text.rstrip(" ") == word

func _physics_process(delta: float) -> void:
	if correct_word() and Input.is_action_just_pressed("submit"):
		finished += editor.text
		editor.text = ""
	document.text = finished+get_edited_word()

func _on_editor_text_changed(new_text: String) -> void:
	if new_text.contains(" "):
		editor.delete_char_at_caret()
	
