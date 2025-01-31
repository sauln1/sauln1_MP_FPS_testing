class_name PlayerStats
extends PlayerCharacter

@onready var healthBar: ProgressBar = %HealthProgressBar
@onready var armorBar: ProgressBar = %ArmorProgressBar


func _ready() -> void:
	healthBar.max_value = playerMaxHealth
	armorBar.max_value = playerMaxArmor


func updateHealth(damageValue: float):
	if armorBar.value > 0:
		updateArmor(damageValue)
	else:
		healthBar.value -= damageValue
		return healthBar.value


func updateArmor(damageValue: float):
	var currentArmor: float = armorBar.value
	
	
