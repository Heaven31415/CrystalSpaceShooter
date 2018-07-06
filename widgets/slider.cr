require "crsfml/graphics"

class Slider < SF::RectangleShape
  # base settings
  @@base_fill_color = SF.color(200, 200, 200, 255)
  @@base_outline_color = SF.color(100, 100, 100, 255)
  @@base_outline_thickness = -1
  # fill settings
  @@fill_fill_color = SF.color(120, 120, 120, 255)
  @@fill_outline_color = SF.color(100, 100, 100, 255)
  @@fill_outline_thickness = -1
  # bar settings
  @@bar_fill_color = SF.color(80, 80, 80, 255)
  @@bar_width = 3

  enum State
    Normal
    Moving
  end

  def initialize(size : SF::Vector2 | Tuple)
    @fill = SF::RectangleShape.new(size)
    @fill.fill_color = @@fill_fill_color
    @fill.outline_color = @@fill_outline_color
    @fill.outline_thickness = @@fill_outline_thickness

    @bar = SF::RectangleShape.new(SF.vector2(@@bar_width, size[1]))
    @bar.fill_color = @@bar_fill_color

    @state = State::Normal
    @value = 0

    super
    self.fill_color = @@base_fill_color
    self.outline_color = @@base_outline_color
    self.outline_thickness = @@base_outline_thickness
  end

  def draw(target, states)
    super
    target.draw(@fill, states)
    target.draw(@bar, states)
  end

  def position=(position : SF::Vector2 | Tuple)
    super
    @fill.position = position
    @bar.position = position
  end

  def handle_input(event : SF::Event)
    case event
      when SF::Event::MouseButtonPressed
        if event.button.left? && inside?(event.x, event.y)
          resize_fill(event.x)
          @state = State::Moving
        end
      when SF::Event::MouseButtonReleased
        if event.button.left?
          @state = State::Normal
        end
      when SF::Event::MouseMoved
        if @state == State::Moving
          resize_fill(event.x)
        end
    end
  end

  def on_value_changed(&block : Int32 ->)
    @on_value_changed_callback = block
  end

  def value_changed(@value : Int32)
    if callback = @on_value_changed_callback
      callback.call(@value)
    end
  end

  # todo: remove it and make a progress bar widget
  def resize_fill_2(value : Int32)
    value_changed(value)

    width = self.global_bounds.width
    if value == 0
      @bar.position = {self.position.x, @bar.position.y}
      @fill.size = {0, self.size.y}
    elsif value == 100
      @bar.position = {self.position.x + width - 1, @bar.position.y}
      @fill.size = self.size
    else
      dx = value / 100.0 * width
      @bar.position = {self.position.x + dx, @bar.position.y}
      @fill.size = {dx, self.size.y}
    end
  end

  private def resize_fill(x : Number)
    left = self.global_bounds.left
    width = self.global_bounds.width
    if x < left
      @bar.position = {self.position.x, @bar.position.y}
      @fill.size = {0, self.size.y}
      value_changed(0)
    elsif x >= left + width
      @bar.position = {self.position.x + width - 1, @bar.position.y}
      @fill.size = self.size
      value_changed(100)
    else
      dx = x - left + 1
      @bar.position = {self.position.x + dx, @bar.position.y}
      @fill.size = {dx, self.size.y}
      value_changed((100.0 * dx / self.size.x).to_i32)
    end
  end

  private def inside?(x : Number, y : Number)
    bounds = self.global_bounds
    x >= bounds.left && x < bounds.left + bounds.width &&
    y >= bounds.top && y < bounds.top + bounds.height
  end
end