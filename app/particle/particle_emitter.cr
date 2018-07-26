require "./particle.cr"

# todo: remove me when https://github.com/crystal-lang/crystal/pull/6445 is merged

module Random
  # Returns a random `Float64` in the given *range*.
  #
  # ```
  # Random.new.rand(6.2..21.768) # => 15.2989
  # ```
  def rand(range : Range(Float, Float)) : Float
    span = range.end - range.begin
    if range.excludes_end?
      unless range.begin < range.end
        raise ArgumentError.new "Invalid range for rand: #{range}"
      end
      range.begin + rand(span)
    else
      unless range.begin <= range.end
        raise ArgumentError.new "Invalid range for rand: #{range}"
      end
      range.begin + rand * span
    end
  end
end

private def rotateVector2f(v : SF::Vector2f, angle : Float32) : SF::Vector2f
  length = Math.sqrt(v.x * v.x + v.y * v.y)
  old_angle = Math.atan(v.y / v.x)
  new_angle = old_angle + angle / 180f32 * Math::PI
  dx = Math.cos(new_angle)
  dy = Math.sin(new_angle)

  SF::Vector2f.new(dx, dy) * length
end

class ParticleEmitterDefinition
  property particles_max_count = 0u32
  property particles_per_second = 0u32

  property min_lifetime = SF::Time.new
  property max_lifetime = SF::Time.new
  property texture : SF::Texture
  property initial_color = SF::Color.new

  property initial_position = SF::Vector2f.new
  property initial_scale = SF::Vector2f.new(1f32, 1f32)
  property initial_rotation = 0f32

  property direction = SF::Vector2f.new
  property min_angle_offset = 0f32
  property max_angle_offset = 0f32
  property min_linear_velocity = 0f32
  property max_linear_velocity = 0f32
  property min_angular_velocity = 0f32 
  property max_angular_velocity = 0f32

  def initialize(@texture : SF::Texture)
  end
end

class ParticleEmitter < SF::Transformable
  include SF::Drawable
  
  @particles_max_count : UInt32
  @particles_per_second : UInt32

  @lifetime : Range(Float32, Float32)
  @texture : SF::Texture
  @initial_color : SF::Color

  @initial_position : SF::Vector2f
  @initial_scale : SF::Vector2f
  @initial_rotation : Float32

  @direction : SF::Vector2f
  @angle_offset : Range(Float32, Float32)
  @angular_velocity : Range(Float32, Float32)
  @linear_velocity : Range(Float32, Float32)

  @particles : Array(Particle)

  @random = Random.new
  @elapsed_time = SF::Time.new
  property active = false

  def initialize(ped : ParticleEmitterDefinition)
    super()

    @particles_max_count = ped.particles_max_count
    @particles_per_second = ped.particles_per_second

    @lifetime = ped.min_lifetime.as_seconds()..ped.max_lifetime.as_seconds()
    @texture = ped.texture
    @initial_color = ped.initial_color

    @initial_position = ped.initial_position
    @initial_scale = ped.initial_scale
    @initial_rotation = ped.initial_rotation

    @direction = ped.direction
    @angle_offset = ped.min_angle_offset..ped.max_angle_offset
    @angular_velocity= ped.min_angular_velocity..ped.max_angular_velocity
    @linear_velocity = ped.min_linear_velocity..ped.max_linear_velocity

    @particles = Array(Particle).new(@particles_max_count)
  end

  def draw(target : SF::RenderTarget, states : SF::RenderStates)
    states.transform *= transform()
    @particles.each do |p|
      target.draw(p, states) if p.alive?
    end
  end

  def update(dt : SF::Time)
    return unless @active

    @elapsed_time += dt
    time_per_particle = SF.seconds(1f32 / @particles_per_second)

    while @elapsed_time >= time_per_particle
      @elapsed_time -= time_per_particle

      if @particles.size < @particles_max_count
        @particles << new_particle
      else
        i = 0
        while true
          unless @particles[i].alive?
            reconstruct_particle(@particles[i])
            break
          end
          i += 1
        end
      end

      if effector = @effector
        @particles.each do |p|
          p.update(dt)
          effector.call(p, dt)
        end
      else
        @particles.each do |p|
          p.update(dt)
        end
      end

    end
  end

  def effector(&block : Particle, SF::Time -> Void)
    @effector = block
  end

  def new_particle : Particle
    lifetime = SF.seconds(@random.rand(@lifetime))
    texture = @texture
    color = @initial_color

    position = @initial_position
    scale = @initial_scale
    rotation = @initial_rotation

    direction = @direction
    angle_offset = @random.rand(@angle_offset)
    direction = rotateVector2f(direction, angle_offset)

    linear_velocity = @random.rand(@linear_velocity)
    angular_velocity = @random.rand(@angular_velocity)

    Particle.new(lifetime, texture, color, position, scale, rotation, direction, linear_velocity, angular_velocity)
  end

  def reconstruct_particle(p : Particle)
    lifetime = SF.seconds(@random.rand(@lifetime))
    texture = @texture
    color = @initial_color

    position = @initial_position
    scale = @initial_scale
    rotation = @initial_rotation

    direction = @direction
    angle_offset = @random.rand(@angle_offset)
    direction = rotateVector2f(direction, angle_offset)

    linear_velocity = @random.rand(@linear_velocity)
    angular_velocity = @random.rand(@angular_velocity)

    p.reinitialize(lifetime, texture, color, position, scale, rotation, direction, linear_velocity, angular_velocity)
  end
end