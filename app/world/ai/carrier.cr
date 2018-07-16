require "./ai.cr"

class Carrier < AI
  def initialize(unit : Unit)
    @unit = WeakRef(Unit).new(unit)
  end

  def think(dt : SF::Time)
    @unit.value.try do |me|
      _think(me, dt)
    end
  end

  private def _think(me : Unit, dt : SF::Time)
    player_position = Player.instance.position

    if player_position.x > me.position.x
      me.accelerate(Direction::Right, dt)
    else
      me.accelerate(Direction::Left, dt)
    end

    if me.position_top < 0.0
      me.accelerate(Direction::Down, dt)
    elsif me.position_bottom > App.window.size.y / 5.0
      me.accelerate(Direction::Up, dt)
    end
  end
end
