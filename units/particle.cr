require "crsfml/graphics"

struct Particle
  def initialize(@position, @velocity, @lifetime)
    @orbit = false
    @angular_velocity = 0.0
    @radius = 0.0
    @angle = 0.0
    @total_lifetime = @lifetime
  end

  def initialize(@radius, @angle, @angular_velocity, @lifetime)
    @position = SF::Vector2f.new
    @velocity = SF::Vector2f.new
    @orbit = true
    @total_lifetime = @lifetime
  end

  property position : SF::Vector2f
  property velocity : SF::Vector2f
  property lifetime : SF::Time
  getter total_lifetime : SF::Time

  property angular_velocity : Float64
  property radius : Float64
  property angle : Float64
  property orbit : Bool
end

abstract class ParticleEmitter
  abstract def emit : Particle
end

class ParticleSystem < SF::Transformable
  include SF::Drawable

  def initialize
    super()
    @emitters = [] of NamedTuple(time: SF::Time, emitter: ParticleEmitter, pps: Int32)
    @particles = [] of Particle
  end

  def add_emitter(time : SF::Time, emitter : ParticleEmitter, pps : Int32)
    @emitters << {time: time, emitter: emitter, pps: pps}
  end

  def update(dt)
    @emitters.each do |e|
      count = (e[:pps] * dt.as_seconds).ceil.to_i32
      count.times { @particles << e[:emitter].emit }
    end
    @particles.map! do |p|
      if p.orbit
        p.angle += p.angular_velocity * dt.as_seconds
      else
        p.position += p.velocity * dt.as_seconds
      end
      p.lifetime -= dt
      p
    end
    @emitters.map! { |e| {time: e[:time] - dt, emitter: e[:emitter], pps: e[:pps]} }
    @emitters.select! { |e| e[:time] > SF::Time::Zero }
    @particles.select! { |p| p.lifetime > SF::Time::Zero }
  end

  def draw(target, states)
    vertices = @particles.map do |p|
      ratio = p.lifetime / p.total_lifetime
      color = SF.color(255, 255, 255, (ratio * 255).to_u8)

      if p.orbit
        SF::Vertex.new(SF.vector2f(Math.cos(p.angle), Math.sin(p.angle)) * p.radius, color)
      else
        SF::Vertex.new(p.position, color)
      end
    end

    states.transform *= transform()
    target.draw(vertices, SF::Points, states)
  end
end

# add_emitter(SF.seconds(10.0), SpiralEmitter.new, 240)
class SpiralEmitter < ParticleEmitter
  def initialize
    @random = Random.new
    @radius = 10.0
    @angle = 0.0
  end

  def emit
    @radius += 0.1
    @angle += 0.1
    angular_velocity = Math::PI
    lifetime = SF.seconds(10.0)
    Particle.new(@radius, @angle, angular_velocity, lifetime)
  end
end

# add_emitter(
# SF.seconds(10.0),
# OrbitingEmitter.new(100.0..105.0, Math::PI/40.0..Math::PI/1.0, 1.0..10.0),
# 60)
class OrbitingEmitter < ParticleEmitter
  @radius_interval : Range(Float64, Float64)
  @velocity_interval : Range(Float64, Float64)
  @lifetime_interval : Range(Float64, Float64)

  def initialize(@radius_interval, @velocity_interval, @lifetime_interval)
    @random = Random.new
  end

  def emit
    radius = @random.rand(@radius_interval)
    angle = @random.rand(2 * Math::PI)
    angular_velocity = @random.rand(@velocity_interval)
    lifetime = SF.seconds(@random.rand(@lifetime_interval))
    Particle.new(radius, angle, angular_velocity, lifetime)
  end
end

# add_emitter(
# SF.seconds(600.0),
# ExhaustEmitter.new(-25.0..25.0, 100.0..120.0, 3.0..5.0),
# 600)
class ExhaustEmitter < ParticleEmitter
  @angle_interval : Range(Float64, Float64)
  @speed_interval : Range(Float64, Float64)
  @lifetime_interval : Range(Float64, Float64)

  def initialize(@angle_interval, @speed_interval, @lifetime_interval)
    @random = Random.new
  end

  def emit
    angle = Math::PI * @random.rand(@angle_interval) / 180.0
    velocity = SF.vector2f(Math.cos(angle), Math.sin(angle)) * @random.rand(@speed_interval)
    lifetime = SF.seconds(@random.rand(@lifetime_interval))
    Particle.new(SF.vector2f(0.0, 0.0), velocity, lifetime)
  end
end
