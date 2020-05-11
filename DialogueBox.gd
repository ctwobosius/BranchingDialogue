extends GraphNode
export (PackedScene) var option
const WHITE: Color = Color(1, 1, 1, 1)
const BLACK: Color = Color(0, 0, 0, 1)
const BLUE: Color = Color(0, .5, 1, 1)
const GOLD: Color = Color(1, .7, 0, 1)
var numOptions = 0
onready var speaker = $Speaker
onready var text = $Text

func _ready():
#	set_slot(1, true, 0, BLUE, true, 0, GOLD)
	set_slot(0, true, 0, BLUE, false, 0, GOLD)


func _on_Button_button_up():
	var o = option.instance()
	o.name = "Option" + str(numOptions)
	add_child(o)
	set_slot(numOptions + 3, false, 0, BLUE, true, 0, GOLD)
	numOptions += 1

func getData():
	var data: Array = [get_name(), offset, speaker.text, text.text, numOptions]
	for child in get_children():
		if checkIfOption(child.get_name()):
			data += [child.text]
	return data

func checkIfOption(name: String):
	return name.left(6) == "Option"

func setData(data: Array):
	name = data[0]
	offset = data[1]
	speaker.text = data[2]
	text.text = data[3]
	if data[4] > 0:
		for option in data.slice(5, data.size() - 1):
			_on_Button_button_up()
			get_node("Option" + str(numOptions - 1)).text = option

func _physics_process(delta):
	if Input.is_action_just_released("close") and selected:
		queue_free()

func _on_DialogueBox_close_request():
	queue_free()

func _on_DialogueBox_resize_request(new_minsize):
	rect_size = new_minsize
	rect_min_size = new_minsize


func _on_Remove_button_up():
	var lastChild: Node = get_children()[get_child_count() - 1]
	if checkIfOption(lastChild.get_name()):
		lastChild.queue_free()
