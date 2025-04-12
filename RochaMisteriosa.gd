extends Node3D

var is_activated = false
var glow_amount = 0.0
var glow_speed = 0.1

func _ready():
    if $Material:
        $Material.params.glow_amount = glow_amount

func _process(delta):
    if is_activated:
        glow_amount = lerp(glow_amount, 1.0, delta * glow_speed)
    else:
        glow_amount = lerp(glow_amount, 0.0, delta * glow_speed)
    
    if $Material:
        $Material.params.glow_amount = glow_amount

func activate():
    is_activated = true