require "./ai"

class AIFighter < AI
  MAX_HEIGHT = 0.35

  def initialize(unit : Unit)
    @unit = WeakRef(Unit).new(unit)
    @scale_cb = TimeCallback.new
    @shoot_cb = TimeCallback.new

    @scale_cb.add(SF.seconds(1.0 / 60.0), 20) do
      if u = unit
        u.set_scale(u.scale.x - 0.5 / 20, u.scale.y + 0.05)
      end
    end

    @scale_cb.add_ending do
      if u = unit
        u.kill
      end
    end

    @shoot_cb.add(SF.seconds(rand(0.4..0.6))) do
      if u = unit
        u.fire_laser
      end
    end
  end

  def update(dt : SF::Time)
    if u = @unit.value
      if u.position_bottom > App.render_size.y * MAX_HEIGHT
        @scale_cb.update(dt)
      else
        if App.player.position.x > u.position.x
          u.accelerate(Direction::Right, dt)
        else
          u.accelerate(Direction::Left, dt)
        end
  
        if App.player.position.y > u.position.y
          u.accelerate(Direction::Down, dt)
        else
          u.accelerate(Direction::Up, dt)
        end
        @shoot_cb.update(dt)
      end
    end
  end
end
