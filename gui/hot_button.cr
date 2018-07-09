require "./style.cr"

class Button < SF::RectangleShape
  enum State
    Normal
    Pressed
    Hover
  end

  @style : Style(Button)

  def style=(@style)
    self.size = @style["Size", SF::Vector2f]
    self.fill_color = @style["NormalColor", SF::Color]
    self.outline_color = @style["OutlineColor", SF::Color]
    self.outline_thickness = @style["OutlineThickness", Float32]
    self.texture = Resources.textures.get(@style["TextureName", String])
  end

  def style
    @style
  end

  def initialize(@style)
    super(@style["Size", SF::Vector2f])
    @state = State::Normal
    @need_update = false
    self.fill_color = @style["NormalColor", SF::Color]
    self.outline_color = @style["OutlineColor", SF::Color]
    self.outline_thickness = @style["OutlineThickness", Float32]
    self.texture = Resources.textures.get(@style["TextureName", String])
  end

  def draw(target, states)
    if @need_update
      case @state
        when .normal?
          self.fill_color = @style["NormalColor", SF::Color]
        when .pressed?
          self.fill_color = @style["PressedColor", SF::Color]
        when .hover?
          self.fill_color = @style.["HoverColor", SF::Color]
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
end