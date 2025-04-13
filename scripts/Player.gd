extends CharacterBody3D

# Variáveis de movimento
@export var speed: float = 5.0  # Velocidade de movimento do jogador
@export var jump_force: float = 10.0  # Força do pulo
@export var gravity: float = -10.0  # Força da gravidade

# Variáveis de estado
var velocity: Vector3 = Vector3.ZERO  # Velocidade atual do jogador
var is_on_floor: bool = false  # Se o jogador está no chão
var can_jump: bool = true  # Se o jogador pode pular
var is_interacting: bool = false  # Se o jogador está interagindo

# Variáveis de animação
var current_animation: String = "idle"  # Animação atual
var animation_speed: float = 1.0  # Velocidade da animação

func _ready():
    """
    Inicializa o jogador:
    - Configura a física
    - Configura a animação
    - Configura a câmera
    - Define o estado inicial
    """
    velocity = Vector3.ZERO
    is_on_floor = false
    can_jump = true
    is_interacting = false
    current_animation = "idle"
    
    # Cria e configura a câmera
    var camera = Camer3D.new()
    camera.name = "Camera3D"
    camera.make_current()
    camera.current = true
    camera.rotation_degrees = Vector3(-30, 0, 0)
    camera.translation = Vector3(0, 1.5, 0)
    add_child(camera)
    
    # Cria e configura o AnimationPlayer
    var animation_player = AnimationPlayer.new()
    animation_player.name = "AnimationPlayer"
    add_child(animation_player)

    # Configura as ações de input
    InputMap.add_action("move_forward")
    InputMap.add_action("move_backward")
    InputMap.add_action("move_left")
    InputMap.add_action("move_right")
    InputMap.add_action("jump")
    InputMap.add_action("interact")
    
    # Configura os botões para cada ação
    InputMap.action_add_event("move_forward", InputEventKey.new().keycode = KEY_W)
    InputMap.action_add_event("move_backward", InputEventKey.new().keycode = KEY_S)
    InputMap.action_add_event("move_left", InputEventKey.new().keycode = KEY_A)
    InputMap.action_add_event("move_right", InputEventKey.new().keycode = KEY_D)
    InputMap.action_add_event("jump", InputEventKey.new().keycode = KEY_SPACE)
    InputMap.action_add_event("interact", InputEventKey.new().keycode = KEY_E)

func _physics_process(delta):
    """
    Processa a física do jogador em cada frame:
    - Movimentação
    - Pulo
    - Gravidade
    - Interatividade
    """
    process_movement(delta)
    process_gravity(delta)
    process_jump()
    process_interactions()
    update_animation()

func process_movement(delta):
    """
    Processa o movimento do jogador:
    - Captura input do teclado
    - Aplica velocidade
    - Limita a velocidade máxima
    """
    var input_direction = Vector3.ZERO
    
    # Captura input do teclado
    if Input.is_action_pressed("move_forward"):
        input_direction += -transform.basis.z
    if Input.is_action_pressed("move_backward"):
        input_direction += transform.basis.z
    if Input.is_action_pressed("move_left"):
        input_direction += -transform.basis.x
    if Input.is_action_pressed("move_right"):
        input_direction += transform.basis.x
    
    # Normaliza a direção para evitar velocidade diagonal maior
    if input_direction.length() > 0:
        input_direction = input_direction.normalized()
    
    # Aplica a velocidade
    velocity.x = input_direction.x * speed
    velocity.z = input_direction.z * speed
    
    # Move o jogador
    move_and_slide(velocity, Vector3.UP)

func process_gravity(delta):
    """
    Aplica a gravidade ao jogador:
    - Acelera o jogador para baixo
    - Limita a velocidade máxima
    """
    if not is_on_floor:
        velocity.y += gravity * delta
        if velocity.y < -20:
            velocity.y = -20

func process_jump():
    """
    Processa o pulo do jogador:
    - Verifica input de pulo
    - Aplica força de pulo
    """
    if Input.is_action_just_pressed("jump") and is_on_floor:
        velocity.y = jump_force
        is_on_floor = false
        can_jump = false

func process_interactions():
    """
    Processa interações do jogador:
    - Verifica input de interação
    - Trata eventos de interação
    """
    if Input.is_action_just_pressed("interact"):
        var interactable = get_interactable()
        if interactable:
            interactable.interact(self)

func get_interactable():
    """
    Verifica se há objetos interativos próximos:
    - Faz um raio de detecção
    - Retorna o objeto interativo mais próximo
    """
    var ray_length = 3.0
    var ray_origin = global_transform.origin
    var ray_end = ray_origin + global_transform.basis.x * ray_length
    
    var space_state = get_world_3d().direct_space_state
    var result = space_state.intersect_ray(ray_origin, ray_end, [self])
    
    if result:
        var target = result.collider
        if target and target.has_method("interact"):
            return target
    return null

func update_animation():
    """
    Atualiza a animação do jogador:
    - Muda entre estados (idle, walk, run, jump)
    - Atualiza a velocidade da animação
    """
    var new_animation = "idle"
    
    if velocity.x != 0 or velocity.z != 0:
        new_animation = "walk"
        if velocity.length() > speed * 0.8:
            new_animation = "run"
    
    if velocity.y > 0:
        new_animation = "jump"
    elif velocity.y < 0:
        new_animation = "fall"
    
    if new_animation != current_animation:
        current_animation = new_animation
        # Aqui você implementaria a mudança de animação
        # Se estiver usando um AnimationPlayer
        if $AnimationPlayer:
            $AnimationPlayer.play(current_animation)

func configure_camera():
    """
    Configura a câmera do jogador:
    - Posiciona a câmera
    - Configura o follow
    - Define limites de rotação
    """
    if $Camera3D:
        $Camera3D.make_current()
        $Camera3D.current = true
        $Camera3D.rotation_degrees = Vector3(-30, 0, 0)
        $Camera3D.translation = Vector3(0, 1.5, 0)
#