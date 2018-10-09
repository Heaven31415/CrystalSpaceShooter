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
    definition = UnitDefinition.new
    definition.type = Unit::Type::EnemyWeapon
    definition.acceleration = SF.vector2f(200.0, 200.0)
    definition.max_velocity = SF.vector2f(200.0, 200.0)
    case @meteor_type
    when Type::Big
      definition.texture = App.resources[Textures.new(Random.rand(7..10))]
    when Type::Medium
      definition.texture = App.resources[Textures.new(Random.rand(11..12))]
    when Type::Small
      definition.texture = App.resources[Textures.new(Random.rand(13..14))]
    when Type::Tiny
      definition.texture = App.resources[Textures.new(Random.rand(15..16))]
    else
      raise "Invalid Meteor::Type value: `#{meteor_type}`"
    end
    super(definition)
  end

  def on_death
    value = @meteor_type.value
    if value < 3
      spawn_children(Meteor::Type.new(value + 1))
    end
  end

  def on_collision(other)
    other.damage((@meteor_type.value - 4).abs)
  end

  def update(dt)
    @velocity.y += @acceleration.y * dt.as_seconds
    super
  end

  private def spawn_children(meteor_type : Type)
    # todo: rework those Math functions to use vector2 instead of tuple
    polar = Math.cartesian_to_polar(@velocity.x, @velocity.y)
    angle = Random.rand( Math::PI/6 .. Math::PI/3 )
    velocity_a = Math.polar_to_cartesian(polar[:radius], polar[:angle] + angle)
    velocity_b = Math.polar_to_cartesian(polar[:radius], polar[:angle] - angle)

    child_a = Meteor.new(meteor_type)
    child_a.position = position
    child_a.velocity = SF.vector2f(velocity_a[:x], velocity_a[:y])

    child_b = Meteor.new(meteor_type)
    child_b.position = position
    child_b.velocity = SF.vector2f(velocity_b[:x], velocity_b[:y])

    world.add(child_a)
    world.add(child_b)
  end
end
