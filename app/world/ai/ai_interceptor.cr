require "./ai"

class AIInterceptor < AI
  @radius : Float32
  @normal_radius : Float32
  @unleashed_radius : Float32
  @angle : Float32
  @angular_speed : Float32
  property unleashed

  def initialize(unit : Unit)
    @unit = WeakRef(Unit).new(unit)

    @unleashed = false

    min = Math.hypot(App.render_size.x * 0.010, App.render_size.y * 0.010).to_f32
    max = Math.hypot(App.render_size.x * 0.015, App.render_size.y * 0.015).to_f32
    @normal_radius = rand(min..max)
    @radius = @normal_radius

    min = Math.hypot(App.render_size.x * 0.030, App.render_size.y * 0.030).to_f32
    max = Math.hypot(App.render_size.x * 0.040, App.render_size.y * 0.040).to_f32
    @unleashed_radius =  rand(min..max)

    @angle = rand(0f32..2f32*Math::PI)

    min = 0.9f32 * Math::PI
    max = 1.0f32 * Math::PI
    @angular_speed = rand(min..max)

    @laser_cb = TimeCallback.new
    @laser_cb.add(SF.seconds(rand(2.0..4.0))) do
      if u = unit
        u.fire_laser
      end
    end
  end

  def update(dt : SF::Time)
    if u = @unit.value.as?(EnemyInterceptor)
      if @unleashed
        if @radius < @unleashed_radius
          @radius += (@unleashed_radius - @normal_radius) * dt.as_seconds
        end
      else
        if @radius > @normal_radius
          @radius -= (@unleashed_radius - @normal_radius) * dt.as_seconds
        end
      end

      @angle += @angular_speed * dt.as_seconds
      pos = u.carrier.position

      x = pos.x + Math.cos(@angle) * @radius
      y = pos.y + Math.sin(@angle) * @radius

      u.position = {x, y}


      # if App.player.position.x > u.position.x
      #   u.accelerate(Direction::Right, dt)
      # else
      #   u.accelerate(Direction::Left, dt)
      # end

      # if u.position_top < 0.0
      #   u.accelerate(Direction::Down, dt)
      # elsif u.position_bottom > App.render_size.y * MAX_HEIGHT
      #   u.accelerate(Direction::Up, dt)
      # end

      if @unleashed
        @laser_cb.update(dt)
      end
    end
  end
end
