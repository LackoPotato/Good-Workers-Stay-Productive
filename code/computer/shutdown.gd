extends PanelContainer
@export var smileylabel:Label
@export var smileylilperson:String = "%s\n:D"
@export var smilyframes:Array[String] = [" \\","   /"]
var smiley_frame_index:int = 0
@export var shuttinglabel:Label
@export var shuttingdown:String = "shutting down your pc%s"
@export var shuttingdownframes:Array[String] = [".","..","...",".."]
var shutting_frame_index:int = 0

func tick() -> void:
	smileylabel.text = smileylilperson % smilyframes[smiley_frame_index]
	smiley_frame_index = (smiley_frame_index+1) % len(smilyframes)
	shuttinglabel.text = shuttingdown % shuttingdownframes[shutting_frame_index]
	shutting_frame_index = (shutting_frame_index+1) % len(shuttingdownframes)
