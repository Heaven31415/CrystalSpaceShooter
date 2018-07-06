require "./label.cr"

class ButtonStyle
  property normal_color : SF::Color
  property pressed_color : SF::Color
  property hover_color : SF::Color
  property label_normal_color : SF::Color
  property label_pressed_color : SF::Color
  property label_hover_color : SF::Color
  property outline_color : SF::Color
  property outline_thickness : Float32

  def initialize
    # button colors
    @normal_color = SF.color(150, 150, 150, 255)
    @pressed_color = SF.color(120, 120, 120, 255)
    @hover_color = SF.color(200, 200, 200, 255)
    # label colors
    @label_normal_color = SF.color(255, 255, 255, 255)
    @label_pressed_color = SF.color(220, 220, 220, 255)
    @label_hover_color = SF.color(120, 120, 120, 255)
    # outline settings
    @outline_color = SF.color(100, 100, 100, 255)
    @outline_thickness = -2_f32
  end
end

class RedButtonStyle < ButtonStyle
  def initialize
    @normal_color = SF.color(180, 63, 63, 255)
    @pressed_color = SF.color(180, 105, 105, 255)
    @hover_color = SF.color(180, 164, 164, 255)

    @label_normal_color = SF.color(230, 216, 216, 255)
    @label_pressed_color = SF.color(161, 153, 153, 255)
    @label_hover_color = SF.color(92, 87, 87, 255)

    @outline_color = SF.color(133, 127, 127, 255)
    @outline_thickness = -1_f32
  end
end

class GreenButtonStyle < ButtonStyle
  def initialize
    @normal_color = SF.color(63, 152, 63, 255)
    @pressed_color = SF.color(105, 163, 105, 255)
    @hover_color = SF.color(164, 174, 164, 255)

    @label_normal_color = SF.color(216, 230, 216, 255)
    @label_pressed_color = SF.color(153, 163, 153, 255)
    @label_hover_color = SF.color(87, 92, 87, 255)

    @outline_color = SF.color(127, 133, 127, 255)
    @outline_thickness = -1_f32
  end
end

class BlueButtonStyle < ButtonStyle
  def initialize
    @normal_color = SF.color(63, 63, 224, 255)
    @pressed_color = SF.color(105, 105, 219, 255)
    @hover_color = SF.color(164, 164, 222, 255)

    @label_normal_color = SF.color(216, 216, 230, 255)
    @label_pressed_color = SF.color(153, 153, 163, 255)
    @label_hover_color = SF.color(87, 87, 92, 255)

    @outline_color = SF.color(127, 127, 133, 255)
    @outline_thickness = -1_f32
  end
end

class Button < SF::RectangleShape
  enum State
    Normal
    Pressed
    Hover
  end

  def initialize(size : SF::Vector2 | Tuple, @style : ButtonStyle = ButtonStyle.new)
    super(size)
    @state = State::Normal
    @need_update = false
    self.fill_color = @style.normal_color
    self.outline_color = @style.outline_color
    self.outline_thickness = @style.outline_thickness
  end

  def draw(target, states)
    if @need_update
      case @state
        when .normal?
          self.fill_color = @style.normal_color
          if label = @label
            label.color = @style.label_normal_color
          end
        when .pressed?
          self.fill_color = @style.pressed_color
          if label = @label
            label.color = @style.label_pressed_color
          end
        when .hover?
          self.fill_color = @style.hover_color
          if label = @label
            label.color = @style.label_hover_color
          end
      end
      @need_update = false
    end
    super
    if label = @label
      target.draw(label, states)
    end
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

  def add_label(string : String)
    @label = Label.new(string, 20, global_bounds.width * 0.9)
    if label = @label
      label.color = @style.label_normal_color
      label.position = {self.position.x + self.global_bounds.width / 2, self.position.y + self.global_bounds.height / 2}
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