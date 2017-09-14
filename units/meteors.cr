require "../common/utilities.cr"
require "./unit.cr"
require "./weapons.cr"

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
      definition.texture = Game.textures.get("meteorBig" + Random.rand(1..4).to_s + ".png")
    when Type::Medium
      definition.texture = Game.textures.get("meteorMed" + Random.rand(1..2).to_s + ".png")
    when Type::Small
      definition.texture = Game.textures.get("meteorSmall" + Random.rand(1..2).to_s + ".png")
    when Type::Tiny
      definition.texture = Game.textures.get("meteorTiny" + Random.rand(1..2).to_s + ".png")
    else # todo: think whether it's a right way to do it
      raise "Invalid Meteor::Type enum value: #{meteor_type}"
    end
    super(definition)
  end

  def on_death
    value = @meteor_type.value
    if value < 3
      spawn_children(Meteor::Type.new(value + 1))
    end
  end

  def update(dt)
    @velocity.y += @acceleration.y * dt.as_seconds
    super
  end

  private def spawn_children(meteor_type : Type)
    # todo: rework those Math functions to use vector2 instead of tuple
    polar = Math.cartesian_to_polar(@velocity.x, @velocity.y)
    angle = Random.rand(Math::PI / 6..Math::PI / 3)
    velocity_a = Math.polar_to_cartesian(polar[:radius], polar[:angle] + angle)
    velocity_b = Math.polar_to_cartesian(polar[:radius], polar[:angle] - angle)

    child_a = Meteor.new(meteor_type)
    child_a.position = position
    child_a.velocity = SF.vector2f(velocity_a[:x], velocity_a[:y])

    child_b = Meteor.new(meteor_type)
    child_b.position = position
    child_b.velocity = SF.vector2f(velocity_b[:x], velocity_b[:y])

    Game.world.add(child_a)
    Game.world.add(child_b)
  end
end
