require "./ai.cr"

class Fighter < AI
  def initialize(unit : Unit)
    @unit = WeakRef(Unit).new(unit)
    @scaling_timer = TimeCallback.new
    @shooting_timer = TimeCallback.new

    @scaling_timer.add(SF.seconds(1.0 / 60.0), 20) do
      if me = @unit.value
        me.set_scale(me.scale.x - 0.5 / 20, me.scale.y + 0.05)
      end
    end

    @scaling_timer.add_ending do
      if me = @unit.value
        me.kill
      end
    end

    @shooting_timer.add(SF.seconds(1.1)) do
      if me = @unit.value
        if me.is_a?(EnemyFighter)
          me.fire_laser
        end
      end
    end
  end

  def think(dt : SF::Time)
    @unit.value.try do |me|
      _think(me, dt)
    end
  end

  private def _think(me : Unit, dt : SF::Time)
    if me.position_bottom > Window.size.y / 2.0
      @scaling_timer.update(dt)
    else
      player_position = Player.instance.position

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

    @shooting_timer.update(dt)
  end
end
