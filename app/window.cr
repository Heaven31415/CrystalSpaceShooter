require "crsfml/graphics"

class Window
  @@instance : SF::RenderWindow?

  def self.create : SF::RenderWindow
    name = App.config["WindowName", String]
    width = App.config["WindowWidth", Int32]
    height = App.config["WindowHeight", Int32]
    vertical_sync_enabled = App.config["VerticalSyncEnabled", Bool]
    key_repeat_enabled = App.config["KeyRepeatEnabled", Bool]
    mouse_cursor_visible = App.config["MouseCursorVisible", Bool]
    desktop = SF::VideoMode.desktop_mode

    if App.fullscreen
      video_mode = desktop
      style = SF::Style::Fullscreen
    else
      video_mode = SF::VideoMode.new(width, height)
      style = SF::Style::Close
    end

    window = SF::RenderWindow.new(video_mode, name, style)

    window.position = {(desktop.width - width) / 2, (desktop.height - height) / 2}
    window.vertical_sync_enabled = vertical_sync_enabled
    window.key_repeat_enabled = key_repeat_enabled
    window.mouse_cursor_visible = mouse_cursor_visible
    window
  end

  def self.recreate
    if window = @@instance
      name = App.config["WindowName", String]
      width = App.config["WindowWidth", Int32]
      height = App.config["WindowHeight", Int32]
      vertical_sync_enabled = App.config["VerticalSyncEnabled", Bool]
      key_repeat_enabled = App.config["KeyRepeatEnabled", Bool]
      mouse_cursor_visible = App.config["MouseCursorVisible", Bool]
      desktop = SF::VideoMode.desktop_mode

      if App.fullscreen
        video_mode = desktop
        style = SF::Style::Fullscreen
      else
        video_mode = SF::VideoMode.new(width, height)
        style = SF::Style::Close
      end

      window.create(video_mode, name, style)

      window.position = {(desktop.width - width) / 2, (desktop.height - height) / 2}
      window.vertical_sync_enabled = vertical_sync_enabled
      window.key_repeat_enabled = key_repeat_enabled
      window.mouse_cursor_visible = mouse_cursor_visible
    end
  end

  def self.instance : SF::RenderWindow
    @@instance ||= create
  end
end