require "./unit.cr"
require "./weapons.cr"
require "../common/time_callback.cr"

class Player < Unit
  enum WeaponMode
    Missile,
    Beam
  end

  def initialize
    definition = UnitDefinition.new
    definition.type = Unit::Type::Player
    definition.acceleration = SF.vector2f(200.0, 250.0)
    definition.max_velocity = SF.vector2f(300.0, 150.0)
    definition.max_health = 25
    definition.texture = Resources.textures.get("player.png")
    super(definition)

    @weapon_mode = WeaponMode::Missile
    @jump_ready = false
    @jump_timer = TimeCallback.new
    @jump_timer.add(SF.seconds(1)) do
      @jump_ready = true
    end
  end

  def handle_input(event : SF::Event)
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

  def update(dt)
    if position_left < 0.0
      @velocity.x = @velocity.x.abs * 0.5
      move(@max_velocity.x * dt.as_seconds, 0)
    elsif position_right > Config.window_size.x
      @velocity.x = -@velocity.x.abs * 0.5
      move(-@max_velocity.x * dt.as_seconds, 0)
    elsif position_bottom > Config.window_size.y
      @velocity.y = -@velocity.y.abs * 0.5
      move(0, -@max_velocity.y * dt.as_seconds)
    end

    if SF::Keyboard.key_pressed? SF::Keyboard::Left
      @velocity.x -= @acceleration.x * dt.as_seconds
    elsif SF::Keyboard.key_pressed? SF::Keyboard::Right
      @velocity.x += @acceleration.x * dt.as_seconds
    end

    if SF::Keyboard.key_pressed? SF::Keyboard::Up
      @velocity.y -= @acceleration.y * dt.as_seconds
    elsif SF::Keyboard.key_pressed? SF::Keyboard::Down
      @velocity.y += @acceleration.y * dt.as_seconds
    end

    if position_top < Config.window_size.y / 2.0
      @velocity.y += 5.1 * @acceleration.y * dt.as_seconds
    end

    super

    @jump_timer.update(dt)
  end

  def on_collision(other)
    other.damage(1)
  end

  def health_percent
    100_f32 * @health.to_f32 / @max_health.to_f32
  end

  private def fire_laser
    case @weapon_mode
    when WeaponMode::Missile
      if @children.size < 5
        laser = Laser.new(WeaponType::Player, 5)
        laser.position = self.position
        laser.scale = {1.25f32, 1.0f32}

        add_child(laser)
        Game.world.add(laser)
        #Game.audio.play("laser.wav")
      end
    when WeaponMode::Beam
      if @children.size < 49
        left_laser = Laser.new(WeaponType::Player, 1)
        right_laser = Laser.new(WeaponType::Player, 1)

        left_laser.position = self.position - {10f32, 0f32}
        right_laser.position = self.position + {10f32, 0f32}
        add_child(left_laser)
        add_child(right_laser)

        Game.world.add(left_laser)
        Game.world.add(right_laser)
        #Game.audio.play("laser.wav")
      end
    end
  end
end
