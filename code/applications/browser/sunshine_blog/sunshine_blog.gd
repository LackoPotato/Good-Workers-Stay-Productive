extends PanelContainer
@export var blog_stylebox:StyleBox = load("res://resources/blog_entry.tres")
@export var blog_root:VBoxContainer
@export var blog_template:String = "Day %s\n%s"
@export var no_blog_posted:String = "There are no blogs posted currently, please try again later!"
@export var blogs_daily:Array[String] = [
	"We have implemented a new leaderboard system!\nTo score more points, you just have to complete tasks on the new tasks app installed in your computers.\nAll employees are recommended to keep their productivity up for the chance to get big bonuses!\nThank you and remember, we love you all",
	"Management have noticed a dip in our Company's projected earnings.\nAs a family, we all have to work together to be the best that we can be.\nSo to motivate our workers, all workers are now required to place high enough in the leaderboards starting today.\nFailure to comply will result in a release from our company.\nThank you and remember, we love you all.",
	"As we are running low on sales staff, all workers are now required to complete personal sales campaigns to our prospective customers! Just use our new messaging app.\nThank you and remember, we love you all.",
	"Sadly, with the loss of our beloved programmers, all of our software is riddled with bugs.\nAll workers are now required to efficiently resolve and overcome any bugs they find.\nThank you and remember, we value the time you put into our family!",
	"In order to increase our company value, we have implemented a new artifical worker system.\nAll workers are expected to exceed it's expected productivity output in order to ensure a healthy, healthy company. \nThank you and remember, Good Workers, Stay Productive."
]
func add_blog(day:int, blog:String) -> void:
	var label = create_blog_label()
	label.text = blog_template % [day,blog]
	blog_root.add_child(label)
	blog_root.move_child(label,0)

func create_blog_label() -> Label:
	var label:Label = Label.new()
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_stylebox_override("normal",blog_stylebox)
	label.add_theme_stylebox_override("focus",blog_stylebox)
	label.add_theme_font_size_override("font_size",12)
	return label

func load_blogs() -> void:
	for child in blog_root.get_children():
		child.queue_free()
	for i in min(GameManager.day,len(blogs_daily)):
		add_blog(i+1,blogs_daily[i])

func _on_visibility_changed() -> void:
	load_blogs()
