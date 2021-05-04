extends Tree

signal inspector_edited(node, tree_item)

const masters = {
	"button": preload("res://elements/NewButton.tscn"),
	"texture": preload("res://textures/new_gradienttexture.tres"),
}

enum ROW_TYPES { HEADER, STRING, BOOL, RANGE, SUBHEAD }

var live_obj: EcoNode = null
var is_dirty: bool = true

func _ready():
	var root = create_item()
	root.set_text(0, "Root")
	
	#build_test()
	#build_ecoHub()

func _draw():
#	if is_dirty:
#
#		is_dirty = false
#
	pass

func inspect_object(object: EcoNode):
	live_obj = object
	clear_current()
	if live_obj != null:
		refresh_display()
	
	update()


func refresh_display():
	match live_obj.ecoType:
		EcoNode.TYPES.HUB:
			build_ecoHub(live_obj.model_hub)
		EcoNode.TYPES.ROUTE:
			build_ecoRoute(live_obj.model_LtoR, live_obj.model_RtoL)
		EcoNode.TYPES.SHIPMENT:
			pass
		_:
			assert(false, "unable to refresh display! no ecotype found!")
	pass


func build_ecoHub(h: Economy.Hub):
	var root = get_root()
	
	var headings: Dictionary = {
		"Economic Hub": null,
		"Goods Sockets": null,
		"Connected Routes": null,
		"Shipments": null,
	}
	
	for i in headings.keys():
		var c = create_item(root)
		headings[i] = c
		prep_row(c, i, ROW_TYPES.HEADER)
	
	var general_lines = [
		{
			"title": "ID", 
			"type": ROW_TYPES.STRING,
			"args": { 
				"editable": false,
				"meta": ["id"],
				"expr": str(h.id),
			},
		},
		{
			"title": "Is Valid", 
			"type": ROW_TYPES.BOOL,
			"args": { 
				"editable": false,
				"meta": ["is_valid"],
				"expr": h.is_valid,
			 },
		},
		{
			"title": "Type",
			"type": ROW_TYPES.STRING,
			"args": { 
				"editable": false,
				"meta": ["type"],
				"expr": h.get_type_string(),
			 },
		},
		{
			"title": "Sub Type",
			"type": ROW_TYPES.RANGE,
			"args": { 
				"editable": true,
				"meta": ["subtype"],
				"min": 0.0, "max": 4.0, "step": 1.0,
				"expr": h.subtype
			 },
		},
		{
			"title": "Name",
			"type": ROW_TYPES.STRING,
			"args": { 
				"editable": true,
				"meta": ["name"],
				"expr": h.name,
			 },
		},
	]
	
	for i in general_lines:
		var c = create_item(headings["Economic Hub"])
		prep_row(c, i.title, i.type, i.args)
	
	for i in h.routes:
		var c: TreeItem = create_item(headings["Connected Routes"])
		prep_row(c, i.name, ROW_TYPES.SUBHEAD)
		
		var src_text = "Null" if i.source == null else i.source.name
		var snk_text = "Null" if i.sink == null else i.sink.name
		
		var route_lines = [
			{
				"title": "ID", 
				"type": ROW_TYPES.STRING,
				"args": { 
					"editable": false,
					"meta": ["id"],
					"expr": str(i.id)
				 },
			},
			{
				"title": "Is Valid", 
				"type": ROW_TYPES.BOOL,
				"args": { 
					"editable": false,
					"meta": ["is_valid"],
					"expr": i.is_valid 
				},
			},
			{
				"title": "Source",
				"type": ROW_TYPES.STRING,
				"args": { 
					"editable": false,
					"meta": ["source"],
					"expr": src_text 
				},
			},
			{
				"title": "Sink",
				"type": ROW_TYPES.STRING,
				"args": { 
					"editable": false,
					"meta": ["sink"],
					"expr": snk_text 
				},
			},
			{
				"title": "Capacity",
				"type": ROW_TYPES.RANGE,
				"args": { 
					"editable": false, 
					"meta": ["capacity", "total"],
					"min": 0.0, "max": 100.0, "step": 1.0,
					"expr": i.capacity.total 
				},
			},
			{
				"title": "Distance",
				"type": ROW_TYPES.RANGE,
				"args": { 
					"editable": false, 
					"meta": ["distance"],
					"min": 0.0, "max": 100.0, "step": 1.0,
					"expr": i.distance 
				},
			},
		]
		
		for j in route_lines:
			var d: TreeItem = create_item(c)
			prep_row(d, j.title, j.type, j.args)
		
		c.collapsed = true
	
	
	var props = h.get_property_list()
	for i in props:
		#print(i)
		pass
	pass

func build_ecoRoute(LtoR: Economy.Route, RtoL: Economy.Route):
	var root = get_root()
	
	var headings: Dictionary = {
		"Economic Route": null,
		"--> Left to Right -->": null,
		"<-- Right to Left <--": null,
	}
	
	for i in headings.keys():
		var c = create_item(root)
		headings[i] = c
		prep_row(c, i, ROW_TYPES.HEADER)
	
	add_route_lines(headings["--> Left to Right -->"], LtoR, true)
	add_route_lines(headings["<-- Right to Left <--"], RtoL, false)
	

func add_route_lines(tree_root: TreeItem, route: Economy.Route, is_LtoR: bool):
	var src_text: String = "None" if route.source == null else route.source.name
	var snk_text: String = "None" if route.sink == null else route.sink.name
	
	var direction: String = "model_LtoR" if is_LtoR else "model_RtoL"
	
	var route_general = [
		{
			"title": "ID", 
			"type": ROW_TYPES.STRING,
			"args": { 
				"editable": false,
				"meta": [direction, "id"],
				"expr": str(route.id),
			},
		},
		{
			"title": "Is Valid", 
			"type": ROW_TYPES.BOOL,
			"args": { 
				"editable": false,
				"meta": [direction, "is_valid"],
				"expr": route.is_valid,
			 },
		},
		{
			"title": "Type",
			"type": ROW_TYPES.STRING,
			"args": { 
				"editable": false,
				"meta": [direction, "type"],
				"expr": route.get_type_string(),
			 },
		},
		{
			"title": "Source",
			"type": ROW_TYPES.STRING,
			"args": { 
				"editable": false,
				"meta": [direction, "source"],
				"expr": src_text,
			 },
		},
		{
			"title": "Sink",
			"type": ROW_TYPES.STRING,
			"args": { 
				"editable": false,
				"meta": [direction,"sink"],
				"expr": snk_text,
			 },
		},
		{
			"title": "Distance",
			"type": ROW_TYPES.RANGE,
			"args": { 
				"editable": true,
				"meta": [direction,"distance"],
				"min": 0.0, "max": 100.0, "step": 5.0,
				"expr": route.distance,
			 },
		},
	]
	
	for i in route_general:
		var c = create_item(tree_root)
		prep_row(c, i.title, i.type, i.args)
	
	var cap: TreeItem
	cap = create_item(tree_root, -2)
	prep_row(cap, "Capacity", ROW_TYPES.SUBHEAD)
	
	var cap_lines = [
		{
			"title": "Total",
			"type": ROW_TYPES.RANGE,
			"args": { 
				"editable": true,
				"meta": [direction, "capacity", "total"],
				"min": 0.0, "max": 100.0, "step": 5.0,
				"expr": route.capacity.total,
			 },
		},
		{
			"title": "In Use",
			"type": ROW_TYPES.RANGE,
			"args": { 
				"editable": false,
				"meta": [direction, "capacity","taken"],
				"min": 0.0, "max": INF, "step": 5.0,
				"expr": route.capacity.taken,
			 },
		},
		{
			"title": "Queued",
			"type": ROW_TYPES.RANGE,
			"args": { 
				"editable": false,
				"meta": [direction, "capacity", "queued"],
				"min": 0.0, "max": INF, "step": 5.0,
				"expr": route.capacity.queued,
			 },
		},
	]
	
	for i in cap_lines:
		var c = create_item(cap)
		prep_row(c, i.title, i.type, i.args)


func prep_row(row: TreeItem, title: String, row_type: int, args: Dictionary = {}):
	row.set_text(0, title)
	row.set_editable(0, false)

	match row_type:
		ROW_TYPES.HEADER:
			row.set_text(0, title)
			row.set_text_align(0, TreeItem.ALIGN_CENTER)
			row.set_expand_right(0, true)
			row.set_custom_bg_color(0, Color(0.37, 0.12, 0.26))
			row.disable_folding = true
		ROW_TYPES.SUBHEAD:
			row.set_text_align(0, TreeItem.ALIGN_CENTER)
			row.set_expand_right(0, true)
			row.set_custom_bg_color(0, Color(0.15, 0.24, 0.31))
			row.disable_folding = false
		ROW_TYPES.BOOL:
			row.set_cell_mode(1, TreeItem.CELL_MODE_CHECK)
			row.set_checked(1, args.expr)
			row.set_text(1, "True" if args.expr else "False")
			row.set_editable(1, args.editable)
			# add something for signals??
			pass
		ROW_TYPES.RANGE:
			row.set_cell_mode(1, TreeItem.CELL_MODE_RANGE)
			row.set_metadata(1, args.meta)
			row.set_range_config(1, args.min, args.max, args.step, args.expr)
			row.set_range(1, args.expr)
			row.set_editable(1, args.editable)
		ROW_TYPES.STRING:
			row.set_cell_mode(1, TreeItem.CELL_MODE_STRING)
			row.set_metadata(1, args.meta)
			row.set_text(1, args.expr)
			row.set_editable(1, args.editable)
			pass


func clear_current():
	# let's try clearing and rebuilding the whole tree each time
	clear()
	var root = create_item()
	root.set_text(0, "Root")
	pass

func find_selected_row(item: TreeItem = null) -> TreeItem:
	var out: TreeItem = null
	if item == null:
		item = get_root()
	var child: TreeItem = item.get_children()
	while child != null:
		if out == null:
			if child.is_selected(1):
				out = child
			else:
				out = find_selected_row(child)
		child = child.get_next()
	return out

func _on_Inspector_item_edited():
	var row: TreeItem = find_selected_row()
	#if row.get_cell_mode(1) != TreeItem.CELL_MODE_RANGE:
	#	row.deselect(1)
	
	var k
	match row.get_cell_mode(1):
		TreeItem.CELL_MODE_STRING:
			k = row.get_text(1)
		TreeItem.CELL_MODE_CHECK:
			k = row.is_checked(1)
		TreeItem.CELL_MODE_RANGE:
			k = row.get_range(1)
	
	print("inspector changed. Row ", row.get_text(0), " val: ", k)
	
	if row != null:
		emit_signal("inspector_edited", live_obj, row)
