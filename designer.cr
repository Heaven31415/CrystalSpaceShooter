require "./gui/button.cr"
require "./gui/cursor.cr"

class Designer
  @@TimePerFrame = SF.seconds(1.0 / Config.fps)
  @@window = SF::RenderWindow.new(SF::VideoMode.new(Config.window_size.x, Config.window_size.y), Config.window_name)

  @clock = SF::Clock.new
  @cursor = Cursor.new
  @dt = SF::Time.new
  @gui : Hash(String, Button)

  class_getter window

  def initialize
    desktop = SF::VideoMode.desktop_mode
    @@window.position = {(desktop.width - @@window.size.x) / 2, (desktop.height - @@window.size.y) / 2}
    @@window.vertical_sync_enabled = true
    @@window.key_repeat_enabled = false
    @@window.mouse_cursor_visible = false

    @gui = build_gui
  end

  def run
    while @@window.open?
    @dt += @clock.restart
    while @dt >= @@TimePerFrame
        handle_input
        update(@@TimePerFrame)
        @dt -= @@TimePerFrame
    end
    render
    end
  end

  def handle_input
    while event = @@window.poll_event
      case event
      when SF::Event::Closed
        @@window.close
      when SF::Event::KeyPressed
        case event.code
        when SF::Keyboard::Escape
          @@window.close
        end
      end
      @cursor.handle_input(event)
      @gui.each { |name, widget| widget.handle_input(event) }
    end
  end

  def update(dt : SF::Time)
  end

  def render
    @@window.clear
    @gui.each { |name, widget| @@window.draw(widget) }
    @@window.draw(@cursor)
    @@window.display
  end

  private def build_gui : Hash(String, Button)
    gui = Hash(String, Button).new

    button = Button.new({150, 60})
    button.position = {5f32, 5f32}
    button.add_label("Test")
    button.on_click do
      puts "Test"
    end
    gui["Test"] = button

    gui
  end
end
