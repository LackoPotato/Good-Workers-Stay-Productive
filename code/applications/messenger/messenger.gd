extends PCWindow
@export var sent_text:RichTextLabel
@export var customer_typing:Label
@export var customer_typing_template:String = "potential customer is typing%s"
@export var messenger_template:String = "[b]You[/b]:\n\t%s\n"
@export var receiver_template:String = "[b]Customer[/b]:\n\t%s\n"
@export var chat_closed_text:String = "[hr width=100%]\nthis chat has been closed"
@export var arrow_box:HBoxContainer
@export var typing_text:RichTextLabel
@export var left:Texture
@export var right:Texture
@export var up:Texture
@export var down:Texture
enum ARROW{
	LEFT,
	RIGHT,
	UP,
	DOWN
}
var messages_list:Array
var sequences:Array
func read_json(path:String) -> Array:
	var file := FileAccess.open(path,FileAccess.READ)
	var result = JSON.parse_string(file.get_as_text())
	if result is Array:
		return result
	return []

func _ready() -> void:
	messages_list = read_json("res://resources/messenger/messaging.json")
	sequences = read_json("res://resources/messenger/sequences.json")
	begin_chat()
	

var current_chat:Array
var current_sequence:Array
var sequence_length:int
func begin_chat() -> void:
	sent_text.clear()
	current_chat = messages_list[randi_range(0,len(messages_list)-1)].duplicate()
	new_sequence()


func new_sequence() -> void:
	current_sequence = sequences[randi_range(0,len(sequences)-1)].duplicate()
	show_sequence(current_sequence)
	sequence_length = len(current_sequence)
	typing_text.visible_ratio = 0
	typing_text.show()
	typing_text.text = current_chat[0]

func write_message(direction:ARROW) -> void:
	if current_sequence[0] == direction:
		arrow_box.get_children()[0].queue_free()
		current_sequence.pop_front()
		typing_text.visible_ratio = (1-((len(current_sequence))/float(sequence_length)))
		if not current_sequence:
			finish_message()
	else:
		shake(arrow_box.get_children()[0] as Control,10,0.3)

func finish_message() -> void:
	GameManager.update_tasks(Task.ValidTasks.MSG,1)
	typing_text.clear()
	sent_text.append_text(messenger_template % current_chat[0])
	current_chat.pop_front()
	customer_typing.show()
	var tween:Tween = get_tree().create_tween()
	for i in range(randi_range(2,4)):
		tween.tween_callback(customer_typing.set.bind("text",customer_typing_template%(".".repeat(i+1))))
		tween.tween_interval(0.5)
	tween.tween_callback(customer_typing.hide)
	if current_chat:
		tween.tween_callback(sent_text.append_text.bind(receiver_template % current_chat[0]))
	current_chat.pop_front()
	if current_chat:
		tween.tween_callback(new_sequence)
	else:
		tween.tween_interval(1)
		tween.tween_callback(sent_text.append_text.bind(chat_closed_text))
		tween.tween_callback(typing_text.hide)
		tween.tween_interval(1)
		tween.tween_callback(begin_chat)


func shake(control:Control,intensity:float,time:float) -> void:
	var tween:Tween = get_tree().create_tween()
	tween.tween_property(control,"offset_transform_position",Vector2(randf_range(-intensity,intensity),randf_range(-intensity,intensity)),time/3)
	tween.tween_property(control,"offset_transform_position",Vector2(randf_range(-intensity,intensity),randf_range(-intensity,intensity)),time/3)
	tween.tween_property(control,"offset_transform_position",Vector2(0,0),time/3)
	

func _physics_process(_delta: float) -> void:
	if current_sequence:
		if Input.is_action_just_pressed("up"):
			write_message(ARROW.UP)
		elif Input.is_action_just_pressed("down"):
			write_message(ARROW.DOWN)
		elif Input.is_action_just_pressed("left"):
			write_message(ARROW.LEFT)
		elif Input.is_action_just_pressed("right"):
			write_message(ARROW.RIGHT)

func show_sequence(sequence:Array) -> void:
	for child in arrow_box.get_children():
		child.queue_free()
	for i in len(sequence):
		var value := int(sequence[i])
		var arrow:TextureRect = TextureRect.new()
		arrow.offset_transform_enabled = true
		arrow.offset_transform_position.y = 200
		match value:
			ARROW.UP:
				arrow.texture = up
			ARROW.DOWN:
				arrow.texture = down
			ARROW.LEFT:
				arrow.texture = left
			ARROW.RIGHT:
				arrow.texture = right
			_:
				push_error("Invalid value in sequence: %s" % value)
		arrow_box.add_child(arrow)
		var tween = get_tree().create_tween()
		tween.tween_property(arrow,"offset_transform_position:y",0,0.1*i)

#Used to produce more sequences
#var new_code_strings:Array[Array] = [[]]
#func _input(event: InputEvent) -> void:
	#if event is InputEventKey:
		#if event.pressed:
			#match event.keycode:
				#4194320: #up
					#new_code_strings[-1].append(ARROW.UP)
					#show_sequence(new_code_strings[-1])
				#4194322: #down
					#new_code_strings[-1].append(ARROW.DOWN)
					#show_sequence(new_code_strings[-1])
				#4194319: #left
					#new_code_strings[-1].append(ARROW.LEFT)
					#show_sequence(new_code_strings[-1])
				#4194321: #right
					#new_code_strings[-1].append(ARROW.RIGHT)
					#show_sequence(new_code_strings[-1])
				#4194309: #enter
					#new_code_strings.append([])
					#show_sequence(new_code_strings[-1])
					#print(new_code_strings)
				#4194308: #delete
					#new_code_strings[-1].clear()
					#show_sequence(new_code_strings[-1])
