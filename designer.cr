require "./gui/cursor.cr"
require "./gui/hot_button.cr"
require "./gui/hot_label.cr"
require "./common/utilities.cr"
require "./resources"

alias Widget = Button | Label

class Designer
  @@TimePerFrame = SF.seconds(1.0 / Config.fps)
  @@window = SF::RenderWindow.new(SF::VideoMode.new(Config.window_size.x, 4 * Config.window_size.y / 5), Config.window_name)

  @clock = SF::Clock.new
  @cursor = Cursor.new
  @dt = SF::Time.new
  @watcher = DirectoryWatcher.new("resources/styles")
  @gui : Hash(String, Widget)

  class_getter window

  def initialize
    desktop = SF::VideoMode.desktop_mode
    @@window.position = {(desktop.width - @@window.size.x), (desktop.height - @@window.size.y) / 2}
    @@window.vertical_sync_enabled = true
    @@window.key_repeat_enabled = false
    @@window.mouse_cursor_visible = false

    @gui = Hash(String, Widget).new
    build_gui
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
    @watcher.update
  end

  def render
    @@window.clear
    @gui.each { |name, widget| @@window.draw(widget) }
    @@window.draw(@cursor)
    @@window.display
  end

  private def build_gui
    # build widgets from already created files
    directory_path = @watcher.directory_path
    Dir.each_child(directory_path) do |filename|
      ext = File.extname(filename)
      name = filename
      properties_path = File.join(directory_path, filename)

      # todo: fix me, if it's possible to obtain type information some other way
      begin 
        case ext
        when .match(/button/)
          build_widget(Button, name, properties_path)
        when .match(/label/)
          build_widget(Label, name, properties_path)
        end
      rescue ex 
        puts "Exception: #{ex.message}"
      end
    end

    @watcher.on_file_created do |filename|
      ext = File.extname(filename)
      name = File.basename(filename)
      properties_path = filename

      # todo: fix me, if it's possible to obtain type information some other way
      begin
        case ext
        when .match(/button/)
          build_widget(Button, name, properties_path)
        when .match(/label/)
          build_widget(Label, name, properties_path)
        end
      rescue ex
        puts "Exception: #{ex.message}"
      end
    end
  end

  private def build_widget(t : T.class, name : String, properties_path : String) forall T
    widget = T.new(Properties(T).from_file(properties_path))

    @watcher.on_file_changed do |filename|
      if filename == properties_path
        begin
          properties = Properties(T).from_file(properties_path)
          widget.properties = properties
        rescue ex
          puts "Exception: #{ex.message}"
        end
      end
    end

    @gui[name] = widget
  end
end

def string_to_class(string : String) : Class
  case string.downcase
  when .match(/button/)
    return Button
  when .match(/label/)
    return Label
  else
    return Nil
  end
end
