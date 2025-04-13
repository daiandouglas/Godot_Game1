extends Node3D

# Variáveis para controle do terremoto
var earthquake_duration = 3.0
var earthquake_intensity = 0.5
var earthquake_timer = Timer.new()

# Variáveis para o efeito de luz
var light_intensity = 0.0
var light_target = 1.0
var light_speed = 0.1

func _ready():
    earthquake_timer.wait_time = earthquake_duration
    earthquake_timer.connect("timeout", self, "_on_earthquake_finished")
    earthquake_timer.start()

func _process(delta):
    # Atualizar intensidade da luz
    light_intensity = lerp(light_intensity, light_target, delta * light_speed)
    if $DirectionalLight3D:
        $DirectionalLight3D.energy = light_intensity

func trigger_earthquake():
    earthquake_timer.start()
    light_target = 1.0

func _on_earthquake_finished():
    light_target = 0.0