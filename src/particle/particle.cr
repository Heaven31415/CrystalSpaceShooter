require "crsfml/graphics"

class Particle
  include SF::Drawable

  property initial_lifetime : SF::Time
  property lifetime : SF::Time

  def color : SF::Color
    @sprite.color
  end

  def color=(color : SF::Color)
    @sprite.color = color
  end

  def position : SF::Vector2f
    @sprite.position
  end

  def position=(position : SF::Vector2f)
    @sprite.position = position
  end

  def scale : SF::Vector2f
    @sprite.scale
  end

  def scale=(scale : SF::Vector2f)
    @sprite.scale = scale
  end

  def rotation : Float32
    @sprite.rotation
  end

  def rotation=(rotation : Float32)
    @sprite.rotation = rotation
  end

  property direction : SF::Vector2f
  property linear_velocity : Float32
  property angular_velocity : Float32

  def reinitialize(
    lifetime           : SF::Time,
    texture            : SF::Texture, 
    color              : SF::Color,

    position           : SF::Vector2f, 
    scale              : SF::Vector2f, 
    rotation           : Float32, 

    direction          : SF::Vector2f,
    linear_velocity    : Float32,
    angular_velocity   : Float32
    )

    self.initialize(lifetime, texture, color, position, scale, rotation, direction, linear_velocity, angular_velocity)
  end

  def initialize(
    lifetime           : SF::Time,
    texture            : SF::Texture, 
    color              : SF::Color,

    position           : SF::Vector2f, 
    scale              : SF::Vector2f, 
    rotation           : Float32, 

    @direction         : SF::Vector2f,
    @linear_velocity   : Float32,
    @angular_velocity  : Float32
    )

    @initial_lifetime = @lifetime = lifetime
    @sprite = SF::Sprite.new(texture)
    @sprite.color = color

    @sprite.position = position
    @sprite.scale = scale
    @sprite.rotation = rotation

    bounds = @sprite.local_bounds
    @sprite.origin = {bounds.width / 2f32, bounds.height / 2f32}
  end

  def alive? : Bool
    @lifetime > SF::Time::Zero
  end

  def draw(target : SF::RenderTarget, states : SF::RenderStates)
    target.draw(@sprite, states)
  end

  def update(dt : SF::Time)
    @lifetime -= dt
    @sprite.move(@direction * @linear_velocity * dt.as_seconds())
    @sprite.rotate(@angular_velocity * dt.as_seconds())
  end
end