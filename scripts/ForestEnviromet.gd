extends Node3D

# Variáveis para controle do ambiente
@export var tree_density: float = 0.5  # Densidade das árvores na floresta
@export var grass_texture: Texture2D  # Textura do terreno
@export var tree_model: PackedScene  # Modelo 3D das árvores
@export var ambient_light_color: Color = Color(0.2, 0.3, 0.2)  # Cor da luz ambiente (verde escuro)

# Sistema de vento para animar as árvores
var wind_strength = 0.1
var wind_direction = Vector3.ZERO

# Sistema de som
var ambient_sound = AudioStreamPlayer3D.new()
var wind_sound = AudioStreamPlayer3D.new()

func _ready():
    """
    Inicializa o ambiente da floresta:
    - Configura a iluminação
    - Configura o som ambiente
    - Configura o terreno
    - Posiciona o jogador
    """
    setup_lighting()
    setup_sounds()
    setup_terrain()
    setup_player_spawn()

func setup_lighting():
    """
    Configura a iluminação da floresta:
    - Adiciona luz direcional para simular o sol
    - Configura a luz ambiente
    - Adiciona efeitos de sombra
    """
    var directional_light = DirectionalLight3D.new()
    directional_light.energy = 0.8
    directional_light.color = Color(0.9, 0.9, 0.8)
    directional_light.shadow_enabled = true
    add_child(directional_light)
    
    var environment = Environment.new()
    environment.background_mode = Environment.BACKGROUND_SKY
    environment.ambient_light_color = ambient_light_color
    environment.ambient_light_energy = 0.5
    get_viewport().environment = environment

func setup_sounds():
    """
    Configura os sons ambiente da floresta:
    - Som de pássaros
    - Som do vento
    - Efeitos ambientais
    """
    # Som ambiente
    ambient_sound.stream = preload("res://sounds/forest_ambient.ogg")
    ambient_sound.loop = true
    ambient_sound.max_distance = 1000
    add_child(ambient_sound)
    
    # Som do vento
    wind_sound.stream = preload("res://sounds/wind.ogg")
    wind_sound.loop = true
    wind_sound.max_distance = 1000
    add_child(wind_sound)
    
    # Inicia os sons
    ambient_sound.play()
    wind_sound.play()

func setup_terrain():
    """
    Configura o terreno da floresta:
    - Cria o terreno com textura de grama
    - Posiciona as árvores aleatoriamente
    - Adiciona detalhes do ambiente
    """
    var terrain = MeshInstance3D.new()
    var plane_mesh = PlaneMesh.new()
    plane_mesh.size = Vector2(100, 100)  # Tamanho do terreno
    terrain.mesh = plane_mesh
    
    # Material do terreno
    var material = StandardMaterial3D.new()
    material.albedo_texture = grass_texture
    terrain.material_override = material
    
    add_child(terrain)
    
    # Posiciona o terreno
    terrain.translation = Vector3(0, -1, 0)
    terrain.rotation_degrees = Vector3(90, 0, 0)

func setup_player_spawn():
    """
    Configura o ponto de spawn do jogador:
    - Posiciona o jogador no centro do terreno
    - Configura a câmera inicial
    - Define a orientação inicial do jogador
    """
    var spawn_point = Vector3(0, 0, 0)
    var spawn_rotation = Vector3(0, 0, 0)
    
    # Cria um marcador de spawn
    var spawn_marker = Spatial.new()
    spawn_marker.name = "PlayerSpawn"
    spawn_marker.translation = spawn_point
    spawn_marker.rotation_degrees = spawn_rotation
    add_child(spawn_marker)

func _process(delta):
    """
    Atualiza o ambiente a cada frame:
    - Anima as árvores com o vento
    - Atualiza os efeitos de som
    """
    update_wind()
    update_sounds(delta)

func update_wind():
    """
    Atualiza a direção e intensidade do vento:
    - Cria um movimento suave e natural
    - Aplica o efeito ao terreno e árvores
    """
    wind_direction = wind_direction.rotated(Vector3.UP, wind_strength * delta)
    update_tree_animation()

func update_tree_animation():
    """
    Aplica a animação ao vento nas árvores:
    - Cria um movimento suave e natural
    - Aplica o efeito ao terreno e árvores
    """
    for tree in get_children():
        if tree.name.begins_with("Tree"):
            var position = tree.translation
            var offset = wind_direction * wind_strength
            tree.translation = position + offset

func update_sounds(delta):
    """
    Atualiza os sons ambiente:
    - Ajusta o volume do vento
    - Gerencia os efeitos sonoros
    """
    var wind_volume = wind_strength * 0.5
    wind_sound.volume_db = wind_volume