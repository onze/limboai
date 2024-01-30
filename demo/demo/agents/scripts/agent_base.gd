extends CharacterBody2D

## Base agent script.

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var health: Health = $Health
@onready var root: Node2D = $Root


func _ready() -> void:
	health.damaged.connect(_damaged)
	health.death.connect(_die)


func _physics_process(_delta: float) -> void:
	_update_facing()


func _update_facing() -> void:
	if velocity.x > 0.0 and root.scale.x < 0.0:
		root.scale.x = 1.0;
	if velocity.x < 0.0 and root.scale.x > 0.0:
		root.scale.x = -1.0;


func _damaged(_amount: float) -> void:
	animation_player.play(&"hurt")


func _die() -> void:
	animation_player.play(&"death")

	for child in get_children():
		if child is BTPlayer or child is LimboHSM:
			child.set_active(false)

	await get_tree().create_timer(10.0).timeout
	queue_free()
