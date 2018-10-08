require "./ai"

class AICarrier < AI
  def initialize(unit : Unit)
    @unit = WeakRef(Unit).new(unit)
    @spawn_cb = TimeCallback.new

    @spawn_cb.add(SF.seconds(0.4), 5) do
      if u = unit
        interceptor = EnemyInterceptor.new
        interceptor.position = u.position
        u.add_child(interceptor)
        u.world.add(interceptor)
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
      elsif u.position_bottom > App.window.size.y / 5.0
        u.accelerate(Direction::Up, dt)
      end

      @spawn_cb.update(dt)
    end
  end
end
