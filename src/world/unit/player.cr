require "./weapons"
require "../world"
require "../unit"
require "../../common/time_callback"

class Player < Unit
  @@instance : Player?

  def self.create : Player
    player = Player.new
    player
  end

  def self.instance : Player
    @@instance ||= create
  end

  enum WeaponMode
    Missile,
    Beam
  end

  def initialize
    template = UnitTemplate.new(
      type: Unit::Type::Player,
      max_health: 25,
      max_velocity: SF.vector2f(300.0, 150.0),
      acceleration: SF.vector2f(200.0, 250.0),
      texture: Game.resources[Resource::Texture::PLAYER],
      texture_rect: nil,
      scale: SF.vector2f(0.5, 0.5)
    )
    
    super(template)

    @weapon_mode = WeaponMode::Missile

    @jump_ready = false
    @jump_callback = TimeCallback.new
    @jump_callback.add(SF.seconds(1f32)) do
      @jump_ready = true
    end
  end

  def input(event : SF::Event) : Nil
    case event
    when SF::Event::KeyPressed
      case event.code
      when SF::Keyboard::Space
        fire_laser
      when SF::Keyboard::Q
        if @jump_ready
          @velocity.x = -@max_velocity.x
          @jump_ready = false
        end
      when SF::Keyboard::W
        if @weapon_mode == WeaponMode::Missile
          @weapon_mode = WeaponMode::Beam
        else
          @weapon_mode = WeaponMode::Missile
        end
      when SF::Keyboard::E
        if @jump_ready
          @velocity.x = @max_velocity.x
          @jump_ready = false
        end
      end
    end
  end

  def update(dt : SF::Time) : Nil
    if position_left < 0f32
      @velocity.x = @velocity.x.abs * 0.5f32
      move(@max_velocity.x * dt.as_seconds, 0f32)
    elsif position_right > Game::WORLD_WIDTH
      @velocity.x = -@velocity.x.abs * 0.5f32
      move(-@max_velocity.x * dt.as_seconds, 0f32)
    elsif position_bottom > Game::WORLD_HEIGHT
      @velocity.y = -@velocity.y.abs * 0.5f32
      move(0, -@max_velocity.y * dt.as_seconds)
    end

    if SF::Keyboard.key_pressed? SF::Keyboard::Left
      accelerate(Direction::Left, dt)
    elsif SF::Keyboard.key_pressed? SF::Keyboard::Right
      accelerate(Direction::Right, dt)
    end

    if SF::Keyboard.key_pressed? SF::Keyboard::Up
      accelerate(Direction::Up, dt)
    elsif SF::Keyboard.key_pressed? SF::Keyboard::Down
      accelerate(Direction::Down, dt)
    end

    if position_top < Game::WORLD_HEIGHT / 2f32
      @velocity.y += 5f32 * @acceleration.y * dt.as_seconds
    end

    p @velocity

    super
    @jump_callback.update(dt)
  end

  def on_collision(other : Unit) : Nil
    other.damage(1)
  end

  def health_percent : Float32
    100f32 * @health.to_f32 / @max_health.to_f32
  end

  private def fire_laser : Nil
    beams = @children.select do |guid|
      if child = world.get(guid)
        child.scale.x == 0.5f32
      end
      false
    end

    beams_count = beams.size
    missiles_count = @children.size - beams.size

    case @weapon_mode
    when WeaponMode::Missile
      if missiles_count < 5
        laser = Laser.new(WeaponType::Player, 5)
        laser.position = self.position
        laser.scale = {1.15f32, 0.9f32}

        Game.audio.play_sound(Resource::Sound::LASER1, 100, 0.5)
        Game.audio.play_sound(Resource::Sound::LASER2, 80, 1.5)

        add_child(laser)
        world.add(laser)
      end
    when WeaponMode::Beam
      if beams_count < 50
        left_laser = Laser.new(WeaponType::Player, 1)
        right_laser = Laser.new(WeaponType::Player, 1)

        left_laser.position = self.position - {10f32, 0f32}
        right_laser.position = self.position + {10f32, 0f32}
        add_child(left_laser)
        add_child(right_laser)

        Game.audio.play_sound(Resource::Sound::PEP_SOUND4, 80, 1.3)
        Game.audio.play_sound(Resource::Sound::PEP_SOUND4, 80, 0.9)

        world.add(left_laser)
        world.add(right_laser)
      end
    end
  end
end
