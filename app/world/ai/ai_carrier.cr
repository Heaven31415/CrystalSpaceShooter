require "./ai"

class AICarrier < AI
  @height : Float32
  @dx : Float32

  def initialize(unit : Unit)
    @unit = WeakRef(Unit).new(unit)
    @spawn_cb = TimeCallback.new
    @unleash_cb = TimeCallback.new
    @unleash = true

    min = (App.render_size.y * 0.1).to_f32
    max = (App.render_size.y * 0.4).to_f32
    # NOTE: why the hell compiler cannot figure it out?
    # This method clearly returns Float32, which should be
    # inferred very easily...
    @height = rand(min..max)

    min = (App.render_size.x * 0.1).to_f32
    max = (App.render_size.x * 0.2).to_f32
    @dx = rand(min..max)

    @spawn_cb.add(SF.seconds(0.4), 5) do
      if u = unit
        interceptor = EnemyInterceptor.new(u)
        interceptor.position = u.position
        u.add_child(interceptor)
        u.world.add(interceptor)
      end
    end

    @unleash_cb.add(SF.seconds(2)) do
      if u = unit
        @unleash = !@unleash
        u.children.each do |child|
          # I think that my design is a little bit flawed,
          # every Unit should have an AI of it's own, so I
          # could directly check whether it is AIInterceptor
          if child.is_a? EnemyInterceptor && (ai = child.ai)
            if ai.is_a?(AIInterceptor)
              ai.unleashed = @unleash
            end
          end
        end
      end
    end
  end

  def update(dt : SF::Time)
    if u = @unit.value

      if (App.player.position.x - u.position.x).abs < @dx
        if App.player.position.x > u.position.x
          u.accelerate(Direction::Left, dt)
        else
          u.accelerate(Direction::Right, dt)
        end
      else
        if App.player.position.x > u.position.x
          u.accelerate(Direction::Right, dt)
        else
          u.accelerate(Direction::Left, dt)
        end
      end

      if (@height - u.position.y).abs > App.render_size.y * 0.01
        if @height > u.position.y
          u.accelerate(Direction::Down, dt)
        else
          u.accelerate(Direction::Up, dt)
        end
      end

      @spawn_cb.update(dt)
      @unleash_cb.update(dt)
    end
  end
end
