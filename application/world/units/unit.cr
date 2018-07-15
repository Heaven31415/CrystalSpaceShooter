require "crsfml/graphics"
require "../../state/cache.cr"
require "../../state/game.cr"

struct UnitDefinition
  property type : Unit::Type
  property acceleration : SF::Vector2f
  property max_velocity : SF::Vector2f
  property max_health : Int32
  property texture : SF::Texture
  property texture_rect : SF::IntRect | Nil

  def initialize
    @type = Unit::Type::None
    @acceleration = SF::Vector2f.new
    @max_velocity = SF::Vector2f.new
    @max_health = 1
    @texture = SF::Texture.new
    @texture_rect = nil
  end
end

enum Direction
  Up
  Right
  Down
  Left
end

class Unit < SF::Sprite
  @[Flags]
  enum Type
    Background   # 1
    EnemyWeapon  # 2
    Enemy        # 4
    PlayerWeapon # 8
    Player       # 16
    Special      # 32
  end

  getter type, alive, acceleration, health, max_health, children
  property velocity, max_velocity

  @type : Unit::Type
  @alive = true
  @velocity : SF::Vector2f
  @max_velocity : SF::Vector2f
  @acceleration : SF::Vector2f
  @health : Int32
  @max_health : Int32

  def initialize(definition : UnitDefinition)
    if definition.texture_rect == nil
      super(definition.texture)
    else
      super(definition.texture, definition.texture_rect)
    end

    @type = definition.type
    @acceleration = definition.acceleration
    @velocity = SF.vector2f(0.0, 0.0)
    @max_velocity = definition.max_velocity
    @health = @max_health = definition.max_health

    @children = [] of Unit

    center_origin
    set_scale(0.5, 0.5)
  end

  def update(dt)
    @children.select! { |child| child.alive }
    @velocity.x = @velocity.x.clamp(-@max_velocity.x, @max_velocity.x)
    @velocity.y = @velocity.y.clamp(-@max_velocity.y, @max_velocity.y)
    move(@velocity * dt.as_seconds)
  end

  def add_child(unit : Unit)
    if !@children.find { |child| child == unit }
      @children.push(unit)
    end
  end

  def accelerate(direction : Direction, dt : SF::Time)
    case direction
    when .up?
      @velocity.y -= @acceleration.y * dt.as_seconds
    when .down?
      @velocity.y += @acceleration.y * dt.as_seconds
    when .right?
      @velocity.x += @acceleration.x * dt.as_seconds
    when .left?
      @velocity.x -= @acceleration.x * dt.as_seconds
    else
      raise "Invalid Direction value: #{direction}"
    end
  end

  def damage(value : Int32)
    if @health > value
      @health -= value
    else
      kill
    end
  end

  def heal(value : Int32)
    @health += value
    if @health > @max_health
      @health = @max_health
    end
  end

  def kill
    @health = 0
    @alive = false
    on_death
  end

  def on_collision(other : self)
  end

  def on_death
  end

  def hostile?(other : self)
    case @type
    when Type::Player, Type::PlayerWeapon
      (Type::Enemy | Type::EnemyWeapon).includes? other.type
    when Type::Enemy, Type::EnemyWeapon
      (Type::Player | Type::PlayerWeapon).includes? other.type
    else
      false
    end
  end

  def close?(other : self)
    bounds_a = global_bounds
    bounds_b = other.global_bounds
    bounds_a.intersects?(bounds_b)
  end

  # todo: make it use vector2
  def close?(x : Number, y : Number)
    global_bounds.contains?(x, y)
  end

  def default_transform
    set_position(0.0, 0.0)
    set_origin(0.0, 0.0)
    set_scale(1.0, 1.0)
  end

  def center_origin
    set_origin(global_bounds.width / 2.0, global_bounds.height / 2.0)
  end

  def position_left
    global_bounds.left
  end

  def position_right
    global_bounds.left + global_bounds.width
  end

  def position_top
    global_bounds.top
  end

  def position_bottom
    global_bounds.top + global_bounds.height
  end

  def <(other : self)
    @type.value < other.type.value
  end

  def <=(other : self)
    @type.value <= other.type.value
  end

  def world
    Cache.get(State::Type::Game).as(Game).world
  end

  def to_s(io)
    # unit information
    unit_information =
      "Unit Information:\n" \
      "class| #{self.class}\ttype| #{@type}\n" \
      "alive| #{@alive}\n" \
      "hp| #{@health} / #{@max_health}\n" \
      "velocity| #{@velocity}\n" \
      "max_velocity| #{@max_velocity}\n"

    # sprite information
    sprite_information =
      "Sprite Information:\n" \
      "color| #{color}\n" \
      "global_bounds| #{global_bounds}\n" \
      "local_bounds| #{local_bounds}\n" \
      "texture| #{texture}\n" \
      "texture_rect| #{texture_rect}\n" \

    # transformation information
    transformation_information =
      "Sprite Transformation:\n" \
      "origin| #{origin}\n" \
      "position| #{position}\n" \
      "scale| #{scale}\n" \
      "rotation| #{rotation}\n" \

    # children information
    children_information =
      "Children Information:\n" \
      "count| #{@children.size}\n"
    @children.each do |child|
      children_information += "#{child.type}| hash: #{child.hash}\n"
    end

    io << unit_information << "\n"
    io << sprite_information << "\n"
    io << transformation_information << "\n"
    io << children_information
  end
end

struct SF::Vector2(T)
  def to_s(io)
    if (x = @x).is_a?(Float)
      io.printf("%s x: %.2f y: %.2f", self.class, @x, @y)
    else
      io.printf("%s x: %d y: %d", self.class, @x, @y)
    end
  end
end

struct SF::Rect(T)
  def to_s(io)
    if (left = @left).is_a?(Float)
      io.printf("%s left: %.2f top: %.2f width: %.2f height: %.2f", self.class, @left, @top, @width, @height)
    else
      io.printf("%s left: %d top: %d width: %d height: %d", self.class, @left, @top, @width, @height)
    end
  end
end

struct SF::Color
  def to_s(io)
    io.printf("%s red: %d green: %d blue: %d alpha: %d", self.class, @r, @g, @b, @a)
  end
end

class SF::Texture
  def to_s(io)
    io.printf("%s width: %d height: %d smooth: %s repeated: %s", self.class, size.x, size.y, smooth?, repeated?)
  end
end
