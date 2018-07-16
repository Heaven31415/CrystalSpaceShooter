require "crsfml/graphics"

class Window
  @@instance : SF::RenderWindow?

  def self.create : SF::RenderWindow
    width = Config.get("WindowWidth", Int32)
    height = Config.get("WindowHeight", Int32)
    name = Config.get("WindowName", String)
    vertical_sync_enabled = Config.get("VerticalSyncEnabled", Bool)
    key_repeat_enabled = Config.get("KeyRepeatEnabled", Bool)
    mouse_cursor_visible = Config.get("MouseCursorVisible", Bool)
    desktop = SF::VideoMode.desktop_mode

    video_mode = SF::VideoMode.new(width, height)
    window = SF::RenderWindow.new(video_mode, name)
    
    window.position = {(desktop.width - width) / 2, (desktop.height - height) / 2}
    window.vertical_sync_enabled = vertical_sync_enabled
    window.key_repeat_enabled = key_repeat_enabled
    window.mouse_cursor_visible = mouse_cursor_visible
    window
  end

  def self.instance : SF::RenderWindow
    @@instance ||= create
  end
end