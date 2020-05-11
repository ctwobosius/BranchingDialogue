extends GraphEdit

export (PackedScene) var dialogueBox
export (Script) var save
var offset: Vector2 = Vector2(400, 400)
var createdTop: bool = false
var boxes: Array = []
var boxNum: int = 0
var first: Node = null
onready var holdSpawn = $Menu/holdSpawn
signal new


func _ready():
	pass


func _on_Button_button_up():
	var dbox = createBox()
	dbox.name = "d" + str(boxNum)
	dbox.offset = offset
	boxNum += 1
	if not holdSpawn.pressed:
		if createdTop:
			offset += Vector2(0, 400)
		else:
			offset += Vector2(400, -400)
		createdTop = not createdTop

func createBox():
	var dbox = dialogueBox.instance()
	add_child(dbox)
	boxes.append(dbox)
	connect("new", dbox, "queue_free")
	return dbox

func loadBox(data: Array):
	var box = createBox()
	box.setData(data)

func loadConnections(connections: Array):
	for c in connections:
		_on_Main_connection_request(c["from"], c["from_port"], c["to"], c["to_port"] )

func _on_Main_connection_request(from, from_slot, to, to_slot):
	connect_node(from, from_slot, to, to_slot)

func _on_save_button_down():
	var newSave = save.new()
	var boxData: Array = []
	for box in boxes:
		if is_instance_valid(box):
			boxData.append(box.getData())
	newSave.boxes = boxData
	newSave.offset = offset
	newSave.createdTop = createdTop
	newSave.connections = get_connection_list()
	newSave.boxNum = boxNum
	
	if first:
		newSave.first = first.get_name()
	var dir = Directory.new()
	if not dir.dir_exists("res://saves"):
		dir.make_dir_recursive("res://saves")
	var saveName: String = $Menu/saveName.text 
	if saveName.is_valid_filename():
		ResourceSaver.save("res://saves/" + saveName + ".tres", newSave)
	


func _on_open_button_up():
	var openName: String = $Menu/openName.text 
	if openName.is_valid_filename():
		_on_new_button_up()
		$loadTimer.start()


func _on_new_button_up():
	emit_signal("new")
	offset = Vector2(400, 400)
	createdTop = false
	boxes = []
	boxNum = 0
	first = null



func _on_selectBeginning_button_up():
	for box in boxes:
		if box.selected:
			first = box
			$Menu/beginning.text = first.get_name()


func _on_loadTimer_timeout():
	$loadTimer.stop()
	var dir = Directory.new()
	var openName: String = $Menu/openName.text 
	if openName.is_valid_filename():
		if dir.file_exists("res://saves/" + openName + ".tres"):
			var oldSave = load("res://saves/" + openName + ".tres")
			for box in oldSave.boxes:
				loadBox(box)
				loadConnections(oldSave.connections)
			createdTop = oldSave.createdTop
	#		boxes = oldSave.boxes
			offset = oldSave.offset
			boxNum = oldSave.boxNum
			first = get_node(oldSave.first)


func _on_Main_delete_nodes_request():
	for box in boxes:
		if not is_instance_valid(box):
			boxes.erase(box)


func _on_export_button_up():
	var data: Dictionary = {}
	var bData: Array
	for box in boxes:
		bData = box.getData()
		data[bData[0]] = [bData[2], bData[3]]

	var connects: Array = get_connection_list()
	var responses: Dictionary = {}
	var i: int = 5
	var from: String
	var response: String
	for connection in connects:
		from = connection["from"]
		response = get_node(from).getData()[i]
		responses[response] = connection["to"]
		i += 1
	data[from] += [responses]
	
	var file = File.new()
	if file.open("res://dialogue.json", File.WRITE) != 0:
		print("Error opening file")
		return

	file.store_line(to_json(data))
	file.close()


func _on_Main_disconnection_request(from, from_slot, to, to_slot):
	disconnect_node(from, from_slot, to, to_slot)
