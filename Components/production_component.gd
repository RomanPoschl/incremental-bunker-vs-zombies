class_name ProductionComponent extends Resource

@export var recipe_blueprint: FactoryType
var current_input_inventory: Dictionary = {}

var current_progress: float = 0.0
var internal_inventory: int = 0 # Output Count

var modified_production_time: float = 0.0
var modified_max_storage: int = 200
var modified_production_amount: int = 1
var modified_stack_size: int = 10

func can_produce() -> bool:
    var recipe = recipe_blueprint
    
    if recipe.ingredients.is_empty():
        return true 
    
    for ingredient in recipe.ingredients:
        var required_id = ingredient.ammo_type.id
        var required_count = ingredient.count
        
        if current_input_inventory.get(required_id, 0) < required_count:
            return false
            
    return true
    
func has_input_space(ammo_type_id: String) -> bool:
    var current_count = current_input_inventory.get(ammo_type_id, 0)

    for ingredient in recipe_blueprint.ingredients:
        if ingredient.ammo_type.id == ammo_type_id:
            return current_count < modified_max_storage
            
    return false
