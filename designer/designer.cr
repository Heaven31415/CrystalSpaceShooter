require "../gui/cursor.cr"
require "../gui/hot_button.cr"
require "../gui/hot_label.cr"
require "../common/utilities.cr"
require "../common/resources.cr"

alias Widget = Button | Label

class Designer
  @@TimePerFrame = SF.seconds(1.0 / Config.fps)
  @@WidgetDirectory = "resources/styles"
  @@window = SF::RenderWindow.new(SF::VideoMode.new(Config.window_size.x, 4 * Config.window_size.y / 5), Config.window_name)

  @clock = SF::Clock.new
  @cursor = Cursor.new
  @dt = SF::Time.new
  @watcher = DirectoryWatcher.new(@@WidgetDirectory)
  @gui : Hash(String, Widget)

  class_getter window

  def initialize
    desktop = SF::VideoMode.desktop_mode
    @@window.position = {(desktop.width - @@window.size.x), (desktop.height - @@window.size.y) / 2}
    @@window.vertical_sync_enabled = true
    @@window.key_repeat_enabled = false
    @@window.mouse_cursor_visible = false

    @gui = Hash(String, Widget).new
    setup_gui
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
      @gui.each_value { |widget| widget.handle_input(event) }
    end
  end

  def update(dt : SF::Time)
    @watcher.update
  end

  def render
    @@window.clear

    sorted_widgets = Array(Widget).new(@gui.size)
    @gui.each_value { |widget| sorted_widgets << widget }
    sorted_widgets.sort! { |a, b| a.layer <=> b.layer }

    sorted_widgets.each { |widget| @@window.draw(widget) }

    @@window.draw(@cursor)
    @@window.display
  end

  private def load_widget(t : T.class, filename : String) forall T
    begin
      properties = Properties(T).from_file(filename)
      widget = T.new(properties)
      @gui[filename] = widget
      # watch for changes in filename and when they happen
      # reload properties for this widget
      @watcher.on_file_changed(filename) do |file|
        if file == filename
          begin 
            properties = Properties(T).from_file(filename)
            widget.properties = properties
          rescue ex : Exception
            puts "Exception: #{ex.message}"
          end
        end
      end

    rescue ex : Exception
      puts "Exception: #{ex.message}"
      # watch for changes in properties and when they happen
      # try again to build properties and widget
      @watcher.on_file_changed(filename) do |file|
        if file == filename
          begin
            properties = Properties(T).from_file(filename)
            widget = T.new(properties)
            @gui[filename] = widget
            # on success, change callback for this filename, so
            # you won't build this widget again and you will watch
            # for changes in properties
            @watcher.on_file_changed(filename) do |file|
              if file == filename
                begin 
                  properties = Properties(T).from_file(filename)
                  widget.properties = properties
                rescue ex : Exception
                  puts "Exception: #{ex.message}"
                end
              end
            end
          rescue ex : Exception
            puts "Exception: #{ex.message}"
          end
        end
      end
    end
  end

  private def load_widget(filename : String)
    case File.extname(filename)
    when ".button"
      load_widget(Button, filename)
    when ".label"
      load_widget(Label, filename)
    else
      puts "Unknown widget extension: `#{File.extname(filename)}`"
    end
  end

  private def unload_widget(filename : String)
    # filenames serve as keys
    @gui.delete(filename)
  end

  private def setup_gui
    # load widgets from already existing files
    Dir.each_child(@@WidgetDirectory) do |filename|
      filename = File.join(@@WidgetDirectory, filename)
      puts "Loading widget: `#{File.basename(filename)}`"
      load_widget(filename)
    end

    @watcher.on_file_created("load") do |filename|
      puts "Loading widget: `#{File.basename(filename)}`"
      load_widget(filename)
    end

    @watcher.on_file_deleted("unload") do |filename|
      puts "Unloading widget: `#{File.basename(filename)}`"
      unload_widget(filename)
    end
  end
end
