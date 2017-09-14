require "./unit.cr"
require "../ai/*"

class EnemyFighter < Unit
  @ai : AI | Nil

  def initialize
    definition = UnitDefinition.new
    definition.type = Unit::Type::Enemy
    definition.acceleration = SF.vector2f(150.0, 200.0)
    definition.max_velocity = SF.vector2f(100.0, 200.0)
    definition.texture = Game.textures.get("enemyFighter.png")
    super(definition)

    @ai = Fighter.new(self)
  end

  def update(dt)
    if ai = @ai
      ai.think(dt)
    end
    super
  end

  def on_collision(other)
    other.damage(1)
  end
end

class EnemyCarrier < Unit
  @ai : AI | Nil

  def initialize
    definition = UnitDefinition.new
    definition.type = Unit::Type::Enemy
    definition.acceleration = SF.vector2f(25.0, 25.0)
    definition.max_velocity = SF.vector2f(50.0, 50.0)
    definition.max_health = 25
    definition.texture = Game.textures.get("enemyCarrier.png")
    super(definition)

    @ai = Carrier.new(self)
    set_scale(0.8, 0.8)
  end

  def update(dt)
    if ai = @ai
      ai.think(dt)
    end
    super
  end

  def on_collision(other)
    other.damage(1)
  end
end

class EnemyInterceptor < Unit
  @ai : AI | Nil

  def initialize
    definition = UnitDefinition.new
    definition.type = Unit::Type::Enemy
    definition.acceleration = SF.vector2f(100.0, 100.0)
    definition.max_velocity = SF.vector2f(200.0, 200.0)
    definition.texture = Game.textures.get("enemyInterceptor.png")
    super(definition)

    @ai = Interceptor.new(self)
    set_scale(0.15, 0.15)
  end

  def update(dt)
    if ai = @ai
      ai.think(dt)
    end
    super
  end

  def on_collision(other)
    other.damage(1)
  end

  def fire_laser
    if @children.size < 3
      laser = Laser.new(WeaponType::Enemy)
      laser.position = self.position
      laser.set_scale(0.15, 0.15)
      add_child(laser)
      Game.world.add(laser)
    end
  end
end
