require "./ai"

class AIInterceptor < AI
  MAX_HEIGHT = 0.3

  def initialize(unit : Unit)
    @unit = WeakRef(Unit).new(unit)
    @laser_cb = TimeCallback.new

    @laser_cb.add(SF.seconds(rand(2.0..4.0))) do
      if u = unit
        u.fire_laser
      end
    end
  end

  def update(dt : SF::Time)
    if u = @unit.value
      if App.player.position.x > u.position.x
        u.accelerate(Direction::Right, dt)
      else
        u.accelerate(Direction::Left, dt)
      end

      if u.position_top < 0.0
        u.accelerate(Direction::Down, dt)
      elsif u.position_bottom > App.render_size.y * MAX_HEIGHT
        u.accelerate(Direction::Up, dt)
      end

      @laser_cb.update(dt)
    end
  end
end
