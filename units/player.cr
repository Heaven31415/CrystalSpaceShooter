require "./unit.cr"
require "./weapons.cr"

class Player < Unit
  def initialize
    definition = UnitDefinition.new
    definition.type = Unit::Type::Player
    definition.acceleration = SF.vector2f(200.0, 250.0)
    definition.max_velocity = SF.vector2f(300.0, 150.0)
    definition.max_health = 25
    definition.texture = Game.textures.get("player.png")
    super(definition)
  end

  def handle_input(event : SF::Event)
    case event
    when SF::Event::KeyPressed
      case event.code
      when SF::Keyboard::Space
        fire_laser
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
  end

  def on_collision(other)
    other.damage(1)
  end

  def health_percent
    100_f32 * @health.to_f32 / @max_health.to_f32
  end

  private def fire_laser
    if @children.size < 5
      laser = Laser.new(WeaponType::Player)
      laser.position = self.position
      add_child(laser)
      Game.world.add(laser)
      Game.audio.play("laser.wav")
    end
  end
end
