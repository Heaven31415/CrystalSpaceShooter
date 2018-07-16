require "crsfml/graphics"

class Window
  @@instance : SF::RenderWindow?

  def self.create : SF::RenderWindow
    width = App.config["WindowWidth", Int32]
    height = App.config["WindowHeight", Int32]
    name = App.config["WindowName", String]
    vertical_sync_enabled = App.config["VerticalSyncEnabled", Bool]
    key_repeat_enabled = App.config["KeyRepeatEnabled", Bool]
    mouse_cursor_visible = App.config["MouseCursorVisible", Bool]
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