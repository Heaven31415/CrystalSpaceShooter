require "../ai"

class AIInterceptor < AI
  @unleashed = false
  @radius : Float32
  @normal_radius : Float32
  @unleashed_radius : Float32
  @angle : Float32
  @angular_speed : Float32
  property unleashed

  def initialize(unit : Unit)
    @unit = WeakRef(Unit).new(unit)

    min = Math.hypot(Game::WORLD_WIDTH * 0.010f32, Game::WORLD_HEIGHT * 0.010f32)
    max = Math.hypot(Game::WORLD_WIDTH * 0.015f32, Game::WORLD_HEIGHT * 0.015f32)
    @radius = @normal_radius = rand(min .. max)

    min = Math.hypot(Game::WORLD_WIDTH * 0.030f32, Game::WORLD_HEIGHT * 0.030f32)
    max = Math.hypot(Game::WORLD_WIDTH * 0.040f32, Game::WORLD_HEIGHT * 0.040f32)
    @unleashed_radius =  rand(min .. max)

    @angle = rand(0f32 .. 2f32 * Math::PI)

    min = 0.9f32 * Math::PI
    max = 1.0f32 * Math::PI
    @angular_speed = rand(min .. max)

    @laser_callback = TimeCallback.new
    @laser_callback.add(SF.seconds(rand(1f32..2f32))) do
      if u = unit
        u.fire_laser
      end
    end
  end

  def on_update(dt : SF::Time)
    # TODO: Should @unit be an EnemyInterceptor?
    if u = @unit.value.as?(EnemyInterceptor)
      if (parent = u.parent) && (carrier = u.world.get(parent))
        if @unleashed
          @laser_callback.update(dt)

          if @radius < @unleashed_radius
            @radius += (@unleashed_radius - @normal_radius) * dt.as_seconds
          end
        else
          if @radius > @normal_radius
            @radius -= (@unleashed_radius - @normal_radius) * dt.as_seconds
          end
        end
  
        @angle += @angular_speed * dt.as_seconds
        position = carrier.position
        x = position.x + Math.cos(@angle) * @radius
        y = position.y + Math.sin(@angle) * @radius
        u.position = {x, y}
      else
        u.kill
      end
    end
  end
end
