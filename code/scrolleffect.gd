@tool
extends RichTextEffect
class_name ScrollEffect
var bbcode = "scroll"

func _process_custom_fx(fx: CharFXTransform) -> bool:
	var letter_size:int = fx.env.get("size",16)
	var bounds:int = fx.env.get("bounds",20) #Bounds from offset to which this effect will apply
	var offset:int =fx.env.get("offset",419)
	var time_per_letter:float = fx.env.get("time",0.5)
	var max_time:float
	if fx.env.get("max_time"):
		max_time = fx.env.get("max_time") as float
		time_per_letter = max_time/(fx.glyph_index-offset)
	else:
		max_time = time_per_letter*(fx.glyph_index-offset)
	
	if (fx.glyph_index-offset) and fx.glyph_index >= offset and fx.glyph_index < offset+bounds:
		var time_ratio:float = min(1,fx.elapsed_time/max_time)
		@warning_ignore("integer_division")
		if fx.elapsed_time < max_time+0.5*time_per_letter:
			fx.offset.y = (fmod(fx.elapsed_time/time_per_letter,1)*letter_size*2-letter_size)
		fx.glyph_index = int(time_ratio*(fx.glyph_index-offset))+offset
	return true
