require "crsfml/graphics"
require "./properties.cr"

# todo: rename class from XSlider to Slider (lines: 36, 52, 109)
# create getters and setters for almost anything

#
# Slider Mandatory Properties:
#
# BarColor                => SF::Color
# ArrowColor              => SF::Color
# LimitColor              => SF::Color
#
# BarSize                 => SF::Vector2f
# ArrowSize               => SF::Vector2f
# LimitSize               => SF::Vector2f
#
# Layer                   => Int32
#
# Origin                  => SF::Vector2f | String
# Scale                   => SF::Vector2f
# Position                => SF::Vector2f
# Rotation                => Float32
#
# Minimum                 => Int32
# Maximum                 => Int32
# Step                    => Int32
# Start                   => Float32
#
# Slider Optional Properties:
#
# BarTexture              => String
# BarTextureRect          => SF::FloatRect
#
# ArrowTexture            => String
# ArrowTextureRect        => SF::FloatRect
#
# LimitTexture            => String
# LimitTextureRect        => SF::FloatRect
#

class XSlider < SF::Transformable
  include SF::Drawable

  enum State
    Normal
    Moving
  end

  @bar : SF::RectangleShape
  @arrow : SF::RectangleShape
  @limit : SF::RectangleShape
  @layer : Int32
  @origin : Property
  @state = State::Normal
  getter value = 0
  @minimum = 0
  @maximum = 100
  @step = 1
  @start = 0f32

  def initialize(properties : Properties(XSlider))
    super()
    @bar = SF::RectangleShape.new
    @arrow = SF::RectangleShape.new
    @limit = SF::RectangleShape.new

    @bar.fill_color = properties["BarColor", SF::Color]
    @arrow.fill_color = properties["ArrowColor", SF::Color]
    @limit.fill_color = properties["LimitColor", SF::Color]

    @bar.size = properties["BarSize", SF::Vector2f]
    @arrow.size = properties["ArrowSize", SF::Vector2f]
    @limit.size = properties["LimitSize", SF::Vector2f]

    bounds = @bar.local_bounds
    @bar.origin = {0f32, bounds.height / 2f32}

    bounds = @arrow.local_bounds
    @arrow.origin = {bounds.width / 2f32, bounds.height / 2f32}

    bounds = @limit.local_bounds
    @limit.origin = {bounds.width / 2f32, bounds.height / 2f32}

    @layer = properties["Layer", Int32]

    # Transformation
    @origin = properties["Origin"]
    self.origin = update_origin(@origin)
    self.scale = properties["Scale", SF::Vector2f]
    self.position = properties["Position", SF::Vector2f]
    self.rotation = properties["Rotation", Float32]

    # Minimum, Maximum, Step
    @minimum = properties["Minimum", Int32]
    @maximum = properties["Maximum", Int32]
    @step = properties["Step", Int32]
    @start = properties["Start", Float32]

    unless @minimum < @maximum
      raise "Minimum must be smaller than maximum"
    end

    unless (@maximum - @minimum + 1) > @step
      raise "Maximum and minimum difference must be greater than step"
    end

    if @step == 0
      raise "Invalid step value: #{@step}"
    end

    @value = @minimum

     # BarTexture
     if properties.has_key?("BarTexture", String)
      @bar.texture = App.resources[properties["BarTexture", String], SF::Texture]
      if properties.has_key?("BarTextureRect", SF::FloatRect)
        @bar.texture_rect = properties["BarTextureRect", SF::IntRect]
      else
        size = @bar.texture.as(SF::Texture).size
        @bar.texture_rect = SF.int_rect(0, 0, size.x, size.y)
      end
    end

    # ArrowTexture
    if properties.has_key?("ArrowTexture", String)
      @arrow.texture = App.resources[properties["ArrowTexture", String], SF::Texture]
      if properties.has_key?("ArrowTextureRect", SF::FloatRect)
        @arrow.texture_rect = properties["ArrowTextureRect", SF::IntRect]
      else
        size = @arrow.texture.as(SF::Texture).size
        @arrow.texture_rect = SF.int_rect(0, 0, size.x, size.y)
      end
    end

    # LimitTexture
    if properties.has_key?("LimitTexture", String)
      @limit.texture = App.resources[properties["LimitTexture", String], SF::Texture]
      if properties.has_key?("LimitTextureRect", SF::FloatRect)
        @limit.texture_rect = properties["LimitTextureRect", SF::IntRect]
      else
        size = @limit.texture.as(SF::Texture).size
        @limit.texture_rect = SF.int_rect(0, 0, size.x, size.y)
      end
    end

    bounds = self.global_bounds
    move_arrow(bounds.left + @start / 100f32 * bounds.width)
  end

  def reinitialize(properties : Properties(XSlider))
    self.initialize(properties)
  end

  def draw(target : SF::RenderTarget, states : SF::RenderStates)
    states.transform *= transform()
    target.draw(@bar, states)
    target.draw(@limit, states)
    @limit.move(+@bar.local_bounds.width, 0f32)
    target.draw(@limit, states)
    @limit.move(-@bar.local_bounds.width, 0f32)
    target.draw(@arrow, states)
  end

  def handle_input(event : SF::Event)
    case event
      when SF::Event::MouseButtonPressed
        if event.button.left? && inside?(SF.vector2i(event.x, event.y))
          move_arrow(event.x.to_f32)
          @state = State::Moving
        end
      when SF::Event::MouseButtonReleased
        if event.button.left?
          @state = State::Normal
        end
      when SF::Event::MouseMoved
        if @state == State::Moving
          move_arrow(event.x.to_f32)
        end
    end
  end

  def local_bounds : SF::FloatRect
    SF::FloatRect.new(SF::Vector2f.new(0f32, 0f32), @bar.size)
  end

  def global_bounds : SF::FloatRect
    transform().transform_rect(local_bounds())
  end

  def on_value_changed(&block : Int32 ->)
    @on_value_changed_callback = block
  end

  private def value_changed(@value : Int32)
    if callback = @on_value_changed_callback
      callback.call(@value)
    end
  end

  private def inside?(position : SF::Vector2i)
    bar = self.global_bounds()
    arrow = @arrow.local_bounds

    position.x >= bar.left - arrow.width * 0.5f32 && 
    position.x < bar.left + bar.width + arrow.width * 0.5f32 &&
    position.y >= bar.top - arrow.height * 0.5f32 && 
    position.y < bar.top + bar.height + arrow.height * 0.5f32
  end

  private def update_origin(origin) : SF::Vector2f
    case origin
    when String
      case origin
      when "Center"
        bounds = local_bounds()
        SF.vector2f(bounds.left + bounds.width / 2f32, bounds.top + bounds.height / 2f32)
      else
        raise "Invalid origin value: `#{origin}`"
      end
    when SF::Vector2f
      origin
    else
      raise "Invalid origin type: `#{origin.class}`"
    end
  end

  private def move_arrow(x : Float32)
    bar = self.global_bounds()

    if x < bar.left
      @arrow.position = {0f32, 0f32}
      self.value_changed(@minimum)
    elsif x > bar.left + bar.width
      @arrow.position = {bar.width, 0f32}
      self.value_changed(@maximum)
    else
      # todo: this will probably need a rework in the future
      values_count = (@maximum - @minimum + 1) / @step
      width_per_step = bar.width / values_count
      dx = x - bar.left
      steps = (dx / width_per_step)

      if steps >= values_count
        steps = values_count - 1
      end

      @arrow.position = {dx, 0f32}
      self.value_changed(@minimum + @step * steps.to_i32)
    end
  end
end