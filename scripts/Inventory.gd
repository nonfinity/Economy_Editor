extends Node
class_name Inventory

### ### ## ## ## ### ###
### VARIABLES GALORE ###
### ### ## ## ## ### ###
enum { SORTBY_NAME, SORTBY_QUANTITY, SORTBY_VOLUME }

var _goods_list: Array = []
# { name, balance, volume, obj }

signal good_registered(which_inv, which_good)
signal good_unregistered(which_inv, which_good)
signal balance_changed(which_inv, which_good, new_balance, amount)
signal balance_at_zero(which_inv, which_good)
signal balance_exits_zero(which_inv, which_good)
signal goods_sorted(which_inv, sorted_by, is_ascending)

### ### ### ### ## ### ### ###
### CORE PROCESS FUNCTIONS ###
### ### ### ### ## ### ### ###

func _ready():
	pass # Replace with function body.

func _process(_delta):
	pass # Replace with function body.



# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
#	CALCULATOR FUCNTIONS
#	These functions calculate things, but do not change values
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
func is_empty() -> bool:
	var out: bool = false
	out = _goods_list.empty()
	
	return out

func has_good(which: Good) -> bool:
	var out: bool = false
	#out = _goods_list.has(which.name)
	for i in _goods_list:
		#if i.name == which.name:
		if i.obj == which:
			out = true
			break
	
	return out

func _get_inventory_line(which: Good) -> Dictionary:
	var out = {}
	for i in _goods_list:
		if i.obj == which:
			out = i
			break

	return out

func get_balance(which: Good) -> float:
	var out: float = 0.0
#	if self.has_good(which):
#		out = _goods_list[which.name].balance
	var inv_line := _get_inventory_line(which)
	if not inv_line.empty():
		out = inv_line.balance
	
	return out

func get_volume(which: Good) -> float:
	var out: float = 0.0
#	if self.has_good(which):
#		out = _goods_list[which.name].volume
	var inv_line := _get_inventory_line(which)
	if not inv_line.empty():
		out = inv_line.volume
	
	return out

func get_goods_list() -> Array:
	return _goods_list.duplicate(true)


# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
#	MUTATOR FUCNTIONS
#	These functions change values
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
func register(which: Good, init_balance: float):
	var inv_line := _get_inventory_line(which)
	#if which.name in _goods_list.keys():
	if not inv_line.empty():
		print("Duplicate good registered with inventory")
		breakpoint
	else:
#		_goods_list[which.name] = {}
#		_goods_list[which.name].balance = init_balance
#		_goods_list[which.name].volume = init_balance / which.density
		var new_good = {
			"name": which.name,
			"obj": which,
			"balance": init_balance,
			"volume": init_balance / which.density,
		}
		_goods_list.push_back(new_good)
		emit_signal("good_registered", self, which)


func unregister(which):
	#if _goods_list.erase(which.name):
	var inv_line := _get_inventory_line(which)
	if inv_line.empty():
		print("Attempted to remove unregistered good from inventory")
		breakpoint
	else:
		_goods_list.erase(inv_line)
		emit_signal("good_unregistered", self, which)


func add_good(which: Good, amount: float):
	if not has_good(which):
		print("attempted to add unregistered good")
		breakpoint
	else:
#		var list_item: Dictionary = _goods_list[which.name]
#		var prior_balance = list_item.balance
#
#		list_item.balance += amount
#		list_item.volume = list_item.balance / which.density
#		emit_signal("balance_changed", self, which, list_item.balance, prior_balance)
		
		if amount == 0.0:
			# don't waste my fucking time
			return
		
		var inv_line := _get_inventory_line(which)
		var old_balance = inv_line.balance
		var new_balance = old_balance + amount
		
		if old_balance == 0.0:
			emit_signal("balance_exits_zero", self, which)
		
		inv_line.balance = new_balance
		inv_line.volume = inv_line.balance / which.density
		emit_signal("balance_changed", self, which, new_balance, amount)
		
		if new_balance == 0.0:
			# remove listing
			#_goods_list.erase(inv_line)
			emit_signal("balance_at_zero", self, which)


func sort(sort_by: int, is_ascending: bool = true):
	var sort_func: String = ""
	
	match sort_by:
		SORTBY_NAME:
			sort_func = "_sort_name_asc" if is_ascending else "_sort_name_desc"
		SORTBY_QUANTITY:
			sort_func = "_sort_quantity_asc" if is_ascending else "_sort_quantity_desc"
		SORTBY_VOLUME:
			sort_func = "_sort_volumey_asc" if is_ascending else "_sort_volume_desc"
	
	if not sort_func == "":
		_goods_list.sort_custom(self, sort_func)
		emit_signal("goods_sorted", self, sort_by, is_ascending)


# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
#	SETGET DEFINITIONS
#	Functions identified as setters or getters
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *



# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
#	ABSTRACT FUCNTIONS.
#	Child classes must define
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *

#func abstract_example(): 
#	assert(false, "Child classes must declare abstract_example()")



# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
#	INHERITED ABSTRACT FUNCTIONS
#	Parent class functions this child MUST override
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *



# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
#	PARENT OVERRIDE FUNCTIONS
#	Parent class functions this child optionally overrides
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *


# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
#	CUSTOM SORT FUNCTIONS
#	Used for sorthing things
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
static func _sort_name_asc(a, b) -> bool:
	return a.name < b.name

static func _sort_name_desc(a, b) -> bool:
	return a.name < b.name

static func _sort_quantity_asc(a, b) -> bool:
	return a.balance < b.balance

static func _sort_quantity_desc(a, b) -> bool:
	return a.balance < b.balance

static func _sort_volume_asc(a, b) -> bool:
	return a.volume < b.volume

static func _sort_volume_desc(a, b) -> bool:
	return a.volume < b.volume


# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
#	LISTENER FUNCTIONS
#	Functions connected to signals
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *



