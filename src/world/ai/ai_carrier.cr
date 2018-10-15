require "../ai"

class AICarrier < AI
  @height : Float32
  @dx : Float32

  def initialize(unit : Unit)
    @unit = WeakRef(Unit).new(unit)
    @spawn_callback = TimeCallback.new
    @unleash_callback = TimeCallback.new
    @unleash = true

    min = Game::WORLD_HEIGHT * 0.1f32
    max = Game::WORLD_HEIGHT * 0.4f32
    @height = rand(min..max)

    min = Game::WORLD_WIDTH * 0.1f32
    max = Game::WORLD_WIDTH * 0.2f32
    @dx = rand(min..max)

    @spawn_callback.add(SF.seconds(0.4), 5) do
      if u = unit
        interceptor = EnemyInterceptor.new
        interceptor.parent = u.guid
        interceptor.position = u.position
        u.add_child(interceptor)
        u.world.add(interceptor)
      end
    end

    @unleash_callback.add(SF.seconds(2)) do
      if u = unit
        @unleash = !@unleash
        u.children.each do |guid|
          if (child = u.world.get(guid))
            if (ai = child.ai) && ai.is_a? AIInterceptor
              ai.unleashed = @unleash
            end
          end
        end
      end
    end
  end

  def on_update(dt : SF::Time) : Nil
    if u = @unit.value

      if (Game.player.position.x - u.position.x).abs < @dx
        if Game.player.position.x > u.position.x
          u.accelerate(Direction::Left, dt)
        else
          u.accelerate(Direction::Right, dt)
        end
      else
        if Game.player.position.x > u.position.x
          u.accelerate(Direction::Right, dt)
        else
          u.accelerate(Direction::Left, dt)
        end
      end

      if (@height - u.position.y).abs > Game::WORLD_HEIGHT * 0.01
        if @height > u.position.y
          u.accelerate(Direction::Down, dt)
        else
          u.accelerate(Direction::Up, dt)
        end
      end

      @spawn_callback.update(dt)
      @unleash_callback.update(dt)
    end
  end
end
