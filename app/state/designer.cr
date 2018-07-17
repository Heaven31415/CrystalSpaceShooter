require "./state.cr"
require "./manager.cr"
require "../gui/cursor.cr"
require "../gui/hot_button.cr"
require "../gui/hot_label.cr"
require "../../common/utilities.cr"

# todo: move me somewhere inside gui folder
alias Widget = Button | Label

class Designer < State
  def initialize
    @cursor = Cursor.new
    @gui = {} of String => Widget
    @widget_directory = "resources/widgets"
    @watcher = DirectoryWatcher.new(@widget_directory)
    setup_gui
  end

  def draw(target : SF::RenderTarget)
    # sort widgets by layer value
    sorted_widgets = Array(Widget).new(@gui.size)
    @gui.each_value { |widget| sorted_widgets << widget }
    sorted_widgets.sort! { |a, b| a.layer <=> b.layer }

    sorted_widgets.each { |widget| target.draw(widget) }
    target.draw(@cursor)
  end

  def handle_input(event : SF::Event)
    case event
    when SF::Event::Closed
      App.window.close
    when SF::Event::KeyPressed
      case event.code
      when SF::Keyboard::Escape
        App.window.close
      end
    end

    @cursor.handle_input(event)
    @gui.each_value { |widget| widget.handle_input(event) }
  end

  def update(dt : SF::Time)
    @watcher.update
  end

  def isolate_drawing : Bool
    true
  end

  def isolate_input : Bool
    true
  end

  def isolate_update : Bool
    true
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
    Dir.each_child(@widget_directory) do |filename|
      filename = File.join(@widget_directory, filename)
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