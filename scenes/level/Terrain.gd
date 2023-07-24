extends Node2D

const FOAM: PackedScene = preload("res://scenes/level/foam.tscn")
const DEFAULT_LAYER: int = 0

@onready var grass_tilemap: TileMap = $Grass
@onready var water_tilemap: TileMap = $Water

var grass_used_cells: Array
var water_used_cells: Array

func  _ready() -> void:
	var used_grass_rect: Rect2 = grass_tilemap.get_used_rect()
	grass_used_cells = grass_tilemap.get_used_cells(DEFAULT_LAYER)
	generate_water_tiles(used_grass_rect)
	generate_foam_tiles()


func generate_water_tiles(used_rect: Rect2):
	for x in range(used_rect.position.x -10 , used_rect.size.x + 10):
		for y in range(used_rect.position.y -10, used_rect.size.y +10):
			
			if grass_used_cells.has(Vector2i(x, y)):
				continue
				
			water_tilemap.set_cell(DEFAULT_LAYER, Vector2i(x, y), DEFAULT_LAYER, Vector2i(0, 0))
	
	water_used_cells = water_tilemap.get_used_cells(DEFAULT_LAYER)
		
func generate_foam_tiles() -> void:
	for cell in grass_used_cells:
		if check_grass_neighbors(cell):
			spawn_foam(cell)
			print("spawn mare")
	
func check_grass_neighbors(cell: Vector2i) -> bool:
	var left_neigbor: Vector2i = Vector2i(cell.x - 1, cell.y)
	var right_neigbor: Vector2i = Vector2i(cell.x + 1, cell.y)
	var top_neigbor: Vector2i = Vector2i(cell.x, cell.y - 1)
	var botton_neigbor: Vector2i = Vector2i(cell.x, cell.y + 1)
	
	var neighbors_list: Array = [left_neigbor, right_neigbor, top_neigbor, botton_neigbor]
	
	for neighbor in neighbors_list:
		if water_used_cells.has(neighbor):
			return true
	return false

func spawn_foam(foam_cell: Vector2) -> void:
	var foam = FOAM.instantiate() as AnimatedSprite2D
	foam.position = (foam_cell * 64.0) + Vector2(32, 32)
	add_child(foam)
