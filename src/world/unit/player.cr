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

  enum WeaponType
    SingleShot
    DoubleShot
  end

  class Laser < Unit
    getter weapon_type : WeaponType
    getter damage : Int32

    def initialize(@weapon_type)
      case @weapon_type
      when WeaponType::SingleShot
        @damage = 4
        template = UnitTemplate.new(
          type: Unit::Type::PlayerWeapon,
          max_health: 1,
          max_velocity: SF.vector2f(0.0, 600.0),
          acceleration: SF.vector2f(0.0, 800.0),
          texture: Game.resources[Resource::Texture::LASER_RED],
          texture_rect: nil,
          scale: SF.vector2f(0.95, 0.75)
        )
      when WeaponType::DoubleShot
        @damage = 1
        template = UnitTemplate.new(
          type: Unit::Type::PlayerWeapon,
          max_health: 1,
          max_velocity: SF.vector2f(0.0, 600.0),
          acceleration: SF.vector2f(0.0, 800.0),
          texture: Game.resources[Resource::Texture::LASER_RED],
          texture_rect: nil,
          scale: SF.vector2f(0.5, 0.5)
        )
      else
        raise "Invalid WeaponType value: '#{@weapon_type}'"
      end

      super(template)
    end

    def update(dt : SF::Time) : Nil
      accelerate(Direction::Up, dt)
      super
    end
  
    def on_collision(other : Unit) : Nil
      other.damage(@damage)
    end 
  end

  def initialize
    template = UnitTemplate.new(
      type: Unit::Type::Player,
      max_health: 25,
      max_velocity: SF.vector2f(200.0, 150.0),
      acceleration: SF.vector2f(200.0, 100.0),
      texture: Game.resources[Resource::Texture::PLAYER],
      texture_rect: nil,
      scale: SF.vector2f(0.5, 0.5)
    )
    
    super(template)

    @weapon_mode = WeaponType::SingleShot
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
        fire_weapon
      when SF::Keyboard::Q
        if @jump_ready
          @velocity.x = -@max_velocity.x
          @jump_ready = false
        end
      when SF::Keyboard::W
        if @weapon_mode == WeaponType::SingleShot
          @weapon_mode = WeaponType::DoubleShot
        else
          @weapon_mode = WeaponType::SingleShot
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

    if position_top < Game::WORLD_HEIGHT * 0.4f32
      @velocity.y += 5f32 * @acceleration.y * dt.as_seconds
    end

    super
    @jump_callback.update(dt)
  end

  def on_collision(other : Unit) : Nil
    other.damage(1)
  end

  def health_percent : Float32
    100f32 * @health.to_f32 / @max_health.to_f32
  end

  private def fire_weapon : Nil
    single_shot_count = 0
    double_shot_count = 0

    @children.each do |guid|
      if (child = world.get(guid)) && child.is_a? Laser
        case child.weapon_type
        when WeaponType::SingleShot
          single_shot_count += 1
        when WeaponType::DoubleShot
          double_shot_count += 1
        end
      end
    end

    case @weapon_mode
    when WeaponType::SingleShot
      if single_shot_count < 3
        laser = Laser.new(WeaponType::SingleShot)
        laser.position = self.position - {0f32, 8f32}
        laser.velocity = SF.vector2f(0f32, self.velocity.y)

        Game.audio.play_sound(Resource::Sound::LASER1, 100, 0.5)
        Game.audio.play_sound(Resource::Sound::LASER2, 80, 1.5)

        add_child(laser)
        world.add(laser)
      end
    when WeaponType::DoubleShot
      if double_shot_count < 30
        first = Laser.new(WeaponType::DoubleShot)
        second = Laser.new(WeaponType::DoubleShot)

        first.position = self.position - {10f32, 0f32}
        second.position = self.position + {10f32, 0f32}

        first.velocity = SF.vector2f(0f32, self.velocity.y)
        second.velocity = SF.vector2f(0f32, self.velocity.y)

        add_child(first)
        add_child(second)

        Game.audio.play_sound(Resource::Sound::PEP_SOUND4, 80, 1.3)
        Game.audio.play_sound(Resource::Sound::PEP_SOUND4, 80, 0.9)

        world.add(first)
        world.add(second)
      end
    end
  end
end
