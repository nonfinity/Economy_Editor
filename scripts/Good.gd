extends Node
class_name Good

### ### ## ## ## ### ###
### VARIABLES GALORE ###
### ### ## ## ## ### ###

enum CATEGORIES { FARM, FOOD, GOODS, CREW, GEAR }

var category: int
var density: float
var graph_color: Color
var supply = { "coeff": -0.05, "intercept": 30.0 }
var demand = { "coeff":  0.05, "intercept": 40.0 }

signal new_good_created(which)

### ### ### ### ## ### ### ###
### CORE PROCESS FUNCTIONS ###
### ### ### ### ## ### ### ###
func _init(set_name: String, set_density: float, set_category: int):
	name = set_name
	density = set_density
	category = set_category
#		supply.coefficient = s_coeff
#		supply.intercept = s_int
#		demand.coefficient = d_coeff
#		demand.intercept = d_int
	
	# maybe do a random initialization?
	emit_signal("new_good_created", self)


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
func calculate_price(inv: float) -> float:
	var out: float = 0.0
	var adjX: float = 0.0
	
	if (demand.coeff - supply.coeff) == 0:
		return -INF
	
	adjX += inv * (supply.coeff + demand.coeff)
	adjX += supply.intercept - demand.intercept
	adjX /= (demand.coeff - supply.coeff)
	
	out = round(100 * (supply.coeff * (inv + adjX) + supply.intercept))
	out /= 100 # get them pennies!
	
	return out

func serialize() -> Dictionary:
	var out: Dictionary = {}
	
	out.name = name
	out.category = category
	out.graph_color = graph_color.to_html()
	
	out.supply = supply
	out.demand = demand
	
	return out



# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
#	MUTATOR FUCNTIONS
#	These functions change values
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
func set_supply(coeff: float, intercept: float):
	supply.coeff = coeff
	supply.intercept = intercept

func set_demand(coeff: float, intercept: float):
	demand.coeff = coeff
	demand.intercept = intercept



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
#	LISTENER FUNCTIONS
#	Functions connected to signals
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *


