require "../../../common/utilities"
require "../world"
require "./unit"
require "./weapons"

class Meteor < Unit
  enum Type
    Big    = 0
    Medium = 1
    Small  = 2
    Tiny   = 3
  end

  def initialize(@meteor_type : Type)
    index = Textures::METEOR_BIG1.value
    case @meteor_type
    when Type::Big
      texture = App.resources[Textures.new(Random.rand(index..index+3))]
    when Type::Medium
      texture = App.resources[Textures.new(Random.rand(index+1..index+2))]
    when Type::Small
      texture = App.resources[Textures.new(Random.rand(index+3..index+4))]
    when Type::Tiny
      texture = App.resources[Textures.new(Random.rand(index+5..index+6))]
    else
      raise "Invalid Meteor::Type value: #{meteor_type}"
    end

    template = UnitTemplate.new(
      type: Unit::Type::Environment,
      acceleration: SF.vector2f(200.0, 200.0),
      max_velocity: SF.vector2f(200.0, 200.0),
      max_health: 1,
      texture: texture
    )

    super(template)
  end

  def on_death : Nil
    value = @meteor_type.value
    if value < 3
      spawn_children(Meteor::Type.new(value + 1))
    end
  end

  def on_collision(other : Unit) : Nil
    other.damage((@meteor_type.value - 4).abs)
  end

  def update(dt : SF::Time) : Nil
    @velocity.y += @acceleration.y * dt.as_seconds
    super
  end

  private def spawn_children(meteor_type : Type)
    radius = Math.hypot(@velocity.x, @velocity.y)
    angle = Math.atan2(@velocity.y, @velocity.x)
    da = Random.rand( Math::PI/6 .. Math::PI/3 )

    velocity_a = SF.vector2f(radius * Math.cos(angle + da), radius * Math.sin(angle + da))
    velocity_b = SF.vector2f(radius * Math.cos(angle - da), radius * Math.sin(angle - da))

    child_a = Meteor.new(meteor_type)
    child_a.position = position
    child_a.velocity = velocity_a

    child_b = Meteor.new(meteor_type)
    child_b.position = position
    child_b.velocity = velocity_b

    world.add(child_a)
    world.add(child_b)
  end
end
