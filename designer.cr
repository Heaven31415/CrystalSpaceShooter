require "./gui/cursor.cr"
require "./gui/hot_button.cr"
require "./common/utilities.cr"
require "./resources"

class Designer
  @@TimePerFrame = SF.seconds(1.0 / Config.fps)
  @@window = SF::RenderWindow.new(SF::VideoMode.new(Config.window_size.x, 4 * Config.window_size.y / 5), Config.window_name)

  @clock = SF::Clock.new
  @cursor = Cursor.new
  @dt = SF::Time.new
  @watcher = DirectoryWatcher.new("resources/styles")
  @gui : Hash(String, Button)

  class_getter window

  def initialize
    desktop = SF::VideoMode.desktop_mode
    @@window.position = {(desktop.width - @@window.size.x), (desktop.height - @@window.size.y) / 2}
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
    @watcher.hotload
  end

  def render
    @@window.clear
    @gui.each { |name, widget| @@window.draw(widget) }
    @@window.draw(@cursor)
    @@window.display
  end

  private def build_gui : Hash(String, Button)
    gui = Hash(String, Button).new

    style_path = "resources/styles/test.button"
    name = "Test"

    button = Button.new(Style(Button).from_file(style_path))
    button.position = {15f32, 15f32}
    button.on_click do
      puts "`#{name}` button on_click event"
    end

    @watcher.on_file_changed do |file|
      if file == style_path
        begin
          style = Style(Button).from_file(style_path)
          button.style = style
        rescue ex
          puts "Exception: #{ex.message}"
        end
      end
    end
    
    gui[name] = button

    gui
  end
end
