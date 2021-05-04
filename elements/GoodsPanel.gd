extends ScrollContainer

var goods_set: Array = []

onready var tree = $VBoxContainer/GoodsTree
onready var root = tree.create_item()

enum ROW_TYPES { HEADER, STRING, BOOL, RANGE, SUBHEAD, SUBHEAD2, COLOR }

signal new_good_pressed()
signal good_edited(tree_item)


func _ready():
	root.set_text(0, "Root")

func _draw():
	pass

func set_model_object(model_obj: Array):
	if model_obj.size() > 0:
		model_obj.sort_custom(self, "_goods_sorter")
		for i in model_obj:
			new_good_added(i)
			pass

func new_good_added(good: Economy.Good):
	goods_set.push_back(good)
	make_goods_tree_lines(good)
	pass

func make_goods_tree_lines(g: Economy.Good):
	var good_line = tree.create_item(root)
	prep_row(good_line, g.name, ROW_TYPES.SUBHEAD)
	good_line.set_metadata(0, g)
	
	var c: TreeItem = null
	var cfg: Dictionary = {}
	
	# name
	c = tree.create_item(good_line)
	cfg = {
		"title": "Name", 
		"type": ROW_TYPES.STRING,
		"args": { 
			"editable": true,
			"meta": ["name"],
			"expr": g.name,
		},
	}
	prep_row(c, cfg.title, cfg.type, cfg.args)
	
	# category
	c = tree.create_item(good_line)
	cfg = {
		"title": "Category", 
		"type": ROW_TYPES.STRING,
		"args": { 
			"editable": true,
			"meta": ["category"],
			"expr": g.category,
		},
	}
	prep_row(c, cfg.title, cfg.type, cfg.args)
	
	# color
	c = tree.create_item(good_line)
	cfg = {
		"title": "Color", 
		"type": ROW_TYPES.STRING,
		"args": { 
			"editable": false,
			"meta": ["color"],
			"expr": "Color not ready",
		},
	}
	prep_row(c, cfg.title, cfg.type, cfg.args)
	
	
	## SUPPLY ##
	var supply = tree.create_item(good_line)
	prep_row(supply, "Supply", ROW_TYPES.SUBHEAD2)
	
	c = tree.create_item(supply)
	cfg = {
		"title": "Coefficient", 
		"type": ROW_TYPES.RANGE,
		"args": { 
			"editable": true,
			"meta": ["supply", "coeff"],
			"min": -0.50, "max": 0.0, "step": 0.01,
			"expr": g.supply.coeff,
			},
		}
	prep_row(c, cfg.title, cfg.type, cfg.args)
	
	c = tree.create_item(supply)
	cfg = {
		"title": "Intercept", 
		"type": ROW_TYPES.RANGE,
		"args": { 
			"editable": true,
			"meta": ["supply", "intercept"],
			"min": 0.0, "max": 100.0, "step": 0.5,
			"expr": g.supply.intercept,
			},
		}
	prep_row(c, cfg.title, cfg.type, cfg.args)
	
	## DEMAND ##
	var demand = tree.create_item(good_line)
	prep_row(demand, "Demand", ROW_TYPES.SUBHEAD2)
	
	c = tree.create_item(demand)
	cfg = {
		"title": "Coefficient", 
		"type": ROW_TYPES.RANGE,
		"args": { 
			"editable": true,
			"meta": ["demand", "coeff"],
			"min": 0.0, "max": 0.5, "step": 0.01,
			"expr": g.demand.coeff,
			},
		}
	prep_row(c, cfg.title, cfg.type, cfg.args)
	
	c = tree.create_item(demand)
	cfg = {
		"title": "Intercept", 
		"type": ROW_TYPES.RANGE,
		"args": { 
			"editable": true,
			"meta": ["demand", "intercept"],
			"min": 0.0, "max": 100.0, "step": 0.5,
			"expr": g.demand.intercept,
			},
		}
	prep_row(c, cfg.title, cfg.type, cfg.args)

		
	var price = tree.create_item(good_line)
	prep_row(price, "Check Prices", ROW_TYPES.SUBHEAD2)
	
	# price
	c = tree.create_item(price)
	cfg = {
		"title": "Market Price", 
		"type": ROW_TYPES.STRING,
		"args": { 
			"editable": false,
			"meta": ["test_price"],
			"min": -INF, "max": INF, "step": 5,
			"expr": "$0.00",
		},
	}
	prep_row(c, cfg.title, cfg.type, cfg.args)
	
	# inventory
	c = tree.create_item(price)
	cfg = {
		"title": "@ Inventory", 
		"type": ROW_TYPES.RANGE,
		"args": { 
			"editable": true,
			"meta": ["test_inventory"],
			"min": -200.0, "max": 200.0, "step": 5,
			"expr": 0,
		},
	}
	prep_row(c, cfg.title, cfg.type, cfg.args)
	
	pass

#
# THIS IS SIMILAR TO, BUT *NOT* INTERCHANGABLE WITH Inspector.prep_row()
#
func prep_row(row: TreeItem, title: String, row_type: int, args: Dictionary = {}):
	row.set_text(0, title)
	row.set_editable(0, false)

	match row_type:
		ROW_TYPES.HEADER:
			row.set_selectable(0, false)
			row.set_text(0, title)
			row.set_text_align(0, TreeItem.ALIGN_CENTER)
			row.set_expand_right(0, true)
			row.set_custom_bg_color(0, Color(0.37, 0.12, 0.26))
			row.disable_folding = true
		ROW_TYPES.SUBHEAD:
			row.set_selectable(0, true)
			row.set_text_align(0, TreeItem.ALIGN_CENTER)
			row.set_expand_right(0, true)
			row.set_custom_bg_color(0, Color(0.15, 0.24, 0.31))
			row.disable_folding = false
		ROW_TYPES.SUBHEAD2:
			row.set_selectable(0, false)
			row.set_text_align(0, TreeItem.ALIGN_LEFT)
			row.set_expand_right(0, true)
			#row.set_custom_bg_color(0, Color(0.15, 0.24, 0.31))
			row.disable_folding = true
		ROW_TYPES.BOOL:
			row.set_selectable(0, false)
			row.set_selectable(1, args.editable)
			row.set_cell_mode(1, TreeItem.CELL_MODE_CHECK)
			row.set_checked(1, args.expr)
			row.set_text(1, "True" if args.expr else "False")
			row.set_editable(1, args.editable)
		ROW_TYPES.RANGE:
			row.set_selectable(0, false)
			row.set_selectable(1, args.editable)
			row.set_cell_mode(1, TreeItem.CELL_MODE_RANGE)
			row.set_metadata(1, args.meta)
			row.set_range_config(1, args.min, args.max, args.step, args.expr)
			row.set_editable(1, args.editable)
		ROW_TYPES.STRING:
			row.set_selectable(0, false)
			row.set_selectable(1, args.editable)
			row.set_cell_mode(1, TreeItem.CELL_MODE_STRING)
			row.set_metadata(1, args.meta)
			row.set_text(1, args.expr)
			row.set_editable(1, args.editable)
		_:
			assert(false, "invalid row type!")


func find_selected_row(item: TreeItem = null) -> TreeItem:
	var out: TreeItem = null
	if item == null:
		item = root
	var child: TreeItem = item.get_children()
	while child != null:
		if out == null:
			if child.is_selected(1):
				out = child
			else:
				out = find_selected_row(child)
		child = child.get_next()
	return out

func find_by_metadata(meta, start_root: TreeItem):
	var out: TreeItem = null
	if start_root == null:
		start_root = root
	var child: TreeItem = start_root.get_children()
	while child != null:
		if out == null:
			if child.get_metadata(1) == null: 
				#print(child.get_text(0), "has no (1) meta")
				out = find_by_metadata(meta, child)
			else:
				if compare_metadata(child.get_metadata(1), meta):
					out = child
				else:
					out = find_by_metadata(meta, child)
		child = child.get_next()
	return out

func get_from_metadata(good: Economy.Good, meta: Array):
	var out
	var temp = good
	
	for i in meta:
		temp = temp[i]
	
	out = temp
	return out

func compare_metadata(meta1: Array, meta2: Array) -> bool:
	var out: bool = true
	
	if meta1.size() != meta2.size():
		out = false
	else:
		var a: Array = meta1.duplicate(true)
		var b: Array = meta2.duplicate(true)
		
		while a.size() > 0:
			var b_idx = b.find(a[0])
			if b_idx > -1:
				a.remove(0)
				b.remove(b_idx)
			else:
				out = false
				break
	return out

func set_from_metadata(value, good: Economy.Good, meta: Array):
	var length = meta.size()
	var temp = good
	
	for i in meta:
		length -= 1
		if length > 0:
			temp = temp[i]
		else:
			temp[i] = value

func _goods_sorter(a, b):
	if a.name < b.name:
		return true
	return false


func _on_NewGood_pressed():
	 emit_signal("new_good_pressed")


func _on_GoodsTree_item_edited():
	var row: TreeItem = find_selected_row()
	var g_row: TreeItem = row
	var g: Economy.Good = null
	
	while not g_row.get_metadata(0) is Economy.Good:
		g_row = g_row.get_parent()
	g = g_row.get_metadata(0)
	
	if not compare_metadata(row.get_metadata(1), ["test_inventory"]):
		var val
		match row.get_cell_mode(1):
			TreeItem.CELL_MODE_RANGE:
				val = row.get_range(1)
			TreeItem.CELL_MODE_CHECK:
				val = row.is_checked(1)
			TreeItem.CELL_MODE_STRING:
				val = row.get_text(1)
			_:
				assert(false, "fisx this garbage")
		set_from_metadata(val, g, row.get_metadata(1))
		
		# update subheading if needed
		if compare_metadata(row.get_metadata(1), ["name"]):
			g_row.set_text(0, row.get_text(1))
		#print(row.get_text(0), " -->", val)
	
	# update good pricing
	var price = find_by_metadata(["test_price"], g_row)
	var inv = find_by_metadata(["test_inventory"], g_row)
	var p_str = "$%0.2f" % g.calculate_price(inv.get_range(1))
	price.set_text(1, p_str)
	
	emit_signal("good_edited", g, row)
	pass # Replace with function body.
