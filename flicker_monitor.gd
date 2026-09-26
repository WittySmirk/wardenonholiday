extends MeshInstance3D

@onready var light = $AreaLight3D

var material: StandardMaterial3D

func _ready():
	material = get_active_material(1)

	while true:
		var enabled = randf() > 0.95
		
		light.visible = enabled
		material.emission_enabled = enabled
		
		await get_tree().create_timer(randf_range(0.1, 0.7)).timeout
