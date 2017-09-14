require "./ai.cr"

class Fighter < AI
  def initialize(unit : Unit)
    @unit = WeakRef(Unit).new(unit)
    @time_callback = TimeCallback.new

    @time_callback.add(SF.seconds(1.0 / 60.0), 20) do
      if me = @unit.value
        me.set_scale(me.scale.x - 0.5 / 20, me.scale.y + 0.05)
      end
    end

    @time_callback.add_ending do
      if me = @unit.value
        me.kill
      end
    end
  end

  def think(dt : SF::Time)
    @unit.value.try do |me|
      _think(me, dt)
    end
  end

  private def _think(me : Unit, dt : SF::Time)
    if me.position_bottom > Config.window_size.y / 2.0
      @time_callback.update(dt)
    else
      player_position = Game.world.player.position

      if player_position.x > me.position.x
        me.accelerate(Direction::Right, dt)
      else
        me.accelerate(Direction::Left, dt)
      end

      if player_position.y > me.position.y
        me.accelerate(Direction::Down, dt)
      else
        me.accelerate(Direction::Up, dt)
      end
    end
  end
end
