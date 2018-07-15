require "crsfml/graphics"

class Window
  @@window : SF::RenderWindow? = nil

  def self.instance : SF::RenderWindow
    if window = @@window
      window
    else
      raise "Unable to call #{self}.instance on uninitialized #{self}"
    end
  end

  def self.load
    width = Config.get("WindowWidth", Int32)
    height = Config.get("WindowHeight", Int32)
    name = Config.get("WindowName", String)

    video_mode = SF::VideoMode.new(width, height)
    @@window = SF::RenderWindow.new(video_mode, name)
    
    desktop = SF::VideoMode.desktop_mode
    if window = @@window
      window.position = {(desktop.width - width) / 2, (desktop.height - height) / 2}
      window.vertical_sync_enabled = true
      window.key_repeat_enabled = false
      window.mouse_cursor_visible = false
    end
  end

  def self.clear(color : SF::Color = SF::Color.new(0, 0, 0, 255))
    if window = @@window
      window.clear(color)
    else
      raise "Unable to call #{self}.clear on uninitialized #{self}"
    end
  end

  def self.draw(drawable : SF::Drawable, states : SF::RenderStates = SF::RenderStates::Default)
    if window = @@window
      window.draw(drawable, states)
    else
      raise "Unable to call #{self}.draw on uninitialized #{self}"
    end
  end

  def self.display
    if window = @@window
      window.display
    else
      raise "Unable to call #{self}.display on uninitialized #{self}"
    end
  end

  def self.close
    if window = @@window
      window.close
    else
      raise "Unable to call #{self}.close on uninitialized #{self}"
    end
  end

  def self.open? : Bool
    if window = @@window
      window.open?
    else
      raise "Unable to call #{self}.open? on uninitialized #{self}"
    end
  end

  def self.poll_event : SF::Event?
    if window = @@window
      window.poll_event
    else
      raise "Unable to call #{self}.poll_event on uninitialized #{self}"
    end
  end
end