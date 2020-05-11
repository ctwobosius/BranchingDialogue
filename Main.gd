extends GraphEdit

export (PackedScene) var dialogueBox
export (Script) var save
var offset: Vector2 = Vector2(400, 400)
var createdTop: bool = false
var boxes: Array = []
var boxNum: int = 0
var first: Node = null
onready var holdSpawn = $ZMod/Menu/holdSpawn
onready var saveName = $ZMod/Menu/saveName
onready var openName = $ZMod/Menu/openName
onready var beginning = $ZMod/Menu/beginning
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
		_on_Main_connection_request(c["from"], c["from_port"], c["to"], c["to_port"])

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
	var fileName: String = saveName.text 
	if fileName.is_valid_filename():
		ResourceSaver.save("res://saves/" + fileName + ".tres", newSave)
	


func _on_open_button_up():
	var fileName: String = openName.text 
	if fileName.is_valid_filename():
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
			beginning.text = first.get_name()
			return
	first = null
	beginning.text = ""


func _on_loadTimer_timeout():
	$loadTimer.stop()
	var dir = Directory.new()
	var fileName: String = openName.text 
	if fileName.is_valid_filename():
		if dir.file_exists("res://saves/" + fileName + ".tres"):
			var oldSave = load("res://saves/" + fileName + ".tres")
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
	
	for box in boxes:
		var bData: Array = box.getData()
		data[bData[0]] = [bData[2], bData[3]]

	var connects: Array = get_connection_list()
	var seen: Dictionary = {}
	var seenIndices: Dictionary = {}
	for connection in connects:
		var from: String = connection["from"]
		if from in seenIndices:
			seenIndices[from] += 1
		else:
			seenIndices[from] = 5
		var index: int = seenIndices[from]
		var response: String = get_node(from).getData()[index]
		if from in seen:
			seen[from][response] = connection["to"]
		else:
			seen[from] = {response: connection["to"]}


	for box in seen:
		data[box].append(seen[box])
	var file = File.new()
	if file.open("res://dialogue.json", File.WRITE) != 0:
		print("Error opening file")
		return

	file.store_line(to_json(data))
	file.close()


func _on_Main_disconnection_request(from, from_slot, to, to_slot):
	disconnect_node(from, from_slot, to, to_slot)


func _on_Main_connection_to_empty(from, from_slot, release_position):
	for c in get_connection_list():
		if c["from"] == from:
			disconnect_node(c["from"], c["from_port"], c["to"], c["to_port"])


func _on_Main_connection_from_empty(to, to_slot, release_position):
	for c in get_connection_list():
		if c["to"] == to:
			disconnect_node(c["from"], c["from_port"], c["to"], c["to_port"])
