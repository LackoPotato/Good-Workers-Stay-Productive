extends PCWindow
@onready var pages:Dictionary[String,Node] = {
	"http://mmm.sunshine.com/leaderboard":%office,
	"mmm.sunshine.com/leaderboard":%office,
	"http://mmm.stopkillinggames.com":%skg,
	"mmm.stopkillinggames.com":%skg,
	"http://www.stopkillinggames.com":%skg,
	"www.stopkillinggames.com":%skg,
	"http://mmm.sunshine.com/blog":%sunshine_blog,
	"mmm.sunshine.com/blog":%sunshine_blog,
	"http://mmm.mebious.co.uk":%thewired,
	"mmm.mebious.co.uk":%thewired,
}
var forbidden_pages:Array[String] = [
	"http://mmm.youtube.com",
	"mmm.youtube.com",
	"http://mmm.itch.io",
	"mmm.itch.io",
	"http://mmm.geocities.com",
	"mmm.geocities.com",
]

@export var page_root:ScrollContainer
@export var load_bar:ProgressBar
@export var url_bar:LineEdit
var current_url:String = ""
@export var load_time:float = 2.5
var tween:Tween
func _on_refresh_pressed() -> void:
	load_page(current_url)

func load_page(url:String) -> void:
	for page in page_root.get_children():
		page.hide()
	if tween and tween.is_running():
		tween.kill()
	load_bar.value = 0
	tween = get_tree().create_tween().set_trans(Tween.TRANS_QUINT)
	tween.tween_property(load_bar,"value",100,load_time)
	tween.tween_callback(open_page.bind(url))

func open_page(url:String) -> void:
	if url in pages:
		pages[url].show()
	elif url in forbidden_pages:
		%blocked.show()
	else:
		%notfound.show()
	current_url = url
	url_bar.text = url

func _on_search_submitted(url: String) -> void:
	load_page(url)
