require "./properties.cr"

class Button < SF::RectangleShape
  enum State
    Normal
    Pressed
    Hover
  end

  @properties : Properties(Button)
  @layer = 0

  def properties=(@properties)
    self.size = @properties["Size", SF::Vector2f]
    self.fill_color = @properties["NormalColor", SF::Color]
    self.outline_color = @properties["OutlineColor", SF::Color]
    self.outline_thickness = @properties["OutlineThickness", Float32]
    self.texture = Resources.textures.get(@properties["TextureName", String])

    # transformation
    apply_origin
    self.scale = @properties["Scale", SF::Vector2f]
    self.position = @properties["Position", SF::Vector2f]
    self.rotation = @properties["Rotation", Float32]

    apply_layer
  end

  def properties
    @properties
  end

  def layer
    @layer
  end

  def initialize(@properties)
    super()
    @state = State::Normal
    @need_update = false
    self.properties = @properties
  end

  def draw(target, states)
    if @need_update
      case @state
        when .normal?
          self.fill_color = @properties["NormalColor", SF::Color]
        when .pressed?
          self.fill_color = @properties["PressedColor", SF::Color]
        when .hover?
          self.fill_color = @properties["HoverColor", SF::Color]
      end
      @need_update = false
    end
    super
  end

  def handle_input(event : SF::Event)
    case event
      when SF::Event::MouseButtonPressed
        if event.button.left? && inside?(event.x, event.y)
          @state = State::Pressed
          @need_update = true
          click
        end
      when SF::Event::MouseButtonReleased
        if event.button.left?
          @state = State::Normal
          @need_update = true
        end
      when SF::Event::MouseMoved
        if inside?(event.x, event.y) && @state != State::Pressed
          @state = State::Hover
          @need_update = true
        elsif !inside?(event.x, event.y) && @state == State::Hover
          @state = State::Normal
          @need_update = true
        end
    end
  end

  def on_click(&block)
    @on_click_callback = block
  end

  private def click
    if callback = @on_click_callback
      callback.call
    end
  end

  private def inside?(x : Number, y : Number)
    bounds = global_bounds
    x >= bounds.left && x < bounds.left + bounds.width &&
    y >= bounds.top && y < bounds.top + bounds.height
  end

  private def apply_origin
    unless @properties.has_key? "Origin" 
      self.center_origin
    end

    value = @properties["Origin"]

    case value
    when String
      case value
      when "Center"
        center_origin
      else
        center_origin
      end
    when SF::Vector2f
      self.origin = value
    end
  end

  private def center_origin
    bounds = local_bounds
    self.origin = {bounds.left + bounds.width / 2.0, bounds.top + bounds.height / 2.0}
  end

  private def apply_layer
    unless @properties.has_key? "Layer" 
      @layer = 0
    end

    @layer = @properties["Layer", Int32]    
  end
end