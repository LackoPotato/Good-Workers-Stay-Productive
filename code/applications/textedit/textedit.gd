extends PCWindow
var focused:bool = true
@export var document:RichTextLabel
@export var editor:LineEdit
@export var word_path:String = "res://resources/textedit_documents/"
@export var clicks:Array[AudioStream]
@export var audio:AudioStreamPlayer
var words:Array[RegExMatch]
var word_index:int = 0
var current_word:String
var word_lookahead:int = 5
var unfinished_template:String = "[color=#333333]%s[/color]"
var wrong_template:String = "[s][color=#f91d04]%s[/color][/s]"
var caret_template:String = "[bgcolor=#5a68ed]%s[/bgcolor]"
var finished:String = ""

func _process(_delta: float) -> void:
	if focused:
		editor.grab_focus()

func get_edited_word() -> String:
	var current:String = editor.text
	#Add Caret View and Escape Text
	var escaped:String
	if editor.text:
		var cpos:int = max(0,editor.caret_column-1)
		escaped = "%s%s%s" % [
			current.substr(0,cpos).replace("[","[lb]").replace("]","[rb]"),
			caret_template % current[cpos],
			current.substr(cpos+1).replace("[","[lb]").replace("]","[rb]")
			]
	var edited:String = ""
	if current_word.begins_with(current):
		edited += escaped
	else:
		edited += wrong_template % escaped
	edited += unfinished_template % current_word.substr(len(current))
	var lookahead:String = " "
	for i in range(word_lookahead):
		var index:int = (word_index+i+1) % len(words)
		var word:String = words[index].get_string()
		lookahead += "%s " %word
	edited += unfinished_template % lookahead
	return edited.to_lower()

func correct_word() -> bool:
	return editor.text.rstrip(" ") == current_word

func _physics_process(_delta: float) -> void:
	if correct_word() and Input.is_action_just_pressed("submit"):
		score()
	document.text = finished+get_edited_word()

func work_ended() -> void:
	set_physics_process(false)
	document.text = finished

func score() -> void:
	finished += editor.text
	editor.text = ""
	word_index += 1
	word_index = word_index % len(words)
	current_word = words[word_index].get_string().to_lower()
	GameManager.update_tasks(Task.ValidTasks.TEXT,1)

func _on_editor_text_changed(new_text: String) -> void:
	audio.stream = clicks[randi_range(0,len(clicks)-1)]
	audio.play()
	if new_text.contains(" "):
		editor.delete_char_at_caret()
	if editor.text.contains(" "): # If the caret delete didnt work (e.g. Someone copied and pasted text (Can't ovveride on _copy a LineEdit))
		editor.text = editor.text.replace(" ","")
	
func _ready() -> void:
	GameManager.work_ended.connect(work_ended)
	setup_words()
	word_index = 0
	current_word = words[word_index].get_string().to_lower()

func setup_words() -> void:
	var paths:PackedStringArray = DirAccess.get_files_at(word_path)
	var file:String = paths[randi_range(0,len(paths)-1)]
	var filepath:String = word_path.path_join(file)
	var filedata:String = FileAccess.open(filepath,FileAccess.READ).get_as_text()
	var expression:RegEx = RegEx.create_from_string("\\w+")
	words = expression.search_all(filedata)
