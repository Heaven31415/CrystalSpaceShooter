require "crsfml/graphics"

class Window
  @@instance : SF::RenderWindow?

  def self.create(fullscreen : Bool) : SF::RenderWindow
    if fullscreen
      window = SF::RenderWindow.new(
        SF::VideoMode.desktop_mode, 
        "Crystal Space Shooter!", 
        SF::Style::Fullscreen
      )

      window.vertical_sync_enabled = Game.config["VerticalSyncEnabled", Bool]
      window.key_repeat_enabled = Game.config["KeyRepeatEnabled", Bool]
      window.mouse_cursor_visible = Game.config["MouseCursorVisible", Bool]
      window
    else
      window = SF::RenderWindow.new(
        SF::VideoMode.new(1024, 576), 
        "Crystal Space Shooter!", 
        SF::Style::Close
      )

      desktop = SF::VideoMode.desktop_mode
      window.position = {(desktop.width - 1024) / 2, (desktop.height - 576) / 4}
      window.vertical_sync_enabled = Game.config["VerticalSyncEnabled", Bool]
      window.key_repeat_enabled = Game.config["KeyRepeatEnabled", Bool]
      window.mouse_cursor_visible = Game.config["MouseCursorVisible", Bool]
      window
    end
  end

  def self.recreate(fullscreen : Bool) : Nil
    if window = @@instance
      if fullscreen
        window.create(
          SF::VideoMode.desktop_mode, 
          "Crystal Space Shooter!", 
          SF::Style::Fullscreen
        )

        window.vertical_sync_enabled = Game.config["VerticalSyncEnabled", Bool]
        window.key_repeat_enabled = Game.config["KeyRepeatEnabled", Bool]
        window.mouse_cursor_visible = Game.config["MouseCursorVisible", Bool]
      else
        window.create(
          SF::VideoMode.new(1024, 576), 
          "Crystal Space Shooter!", 
          SF::Style::Close
        )

        desktop = SF::VideoMode.desktop_mode
        window.position = {(desktop.width - 1024) / 2, (desktop.height - 576) / 4}
        window.vertical_sync_enabled = Game.config["VerticalSyncEnabled", Bool]
        window.key_repeat_enabled = Game.config["KeyRepeatEnabled", Bool]
        window.mouse_cursor_visible = Game.config["MouseCursorVisible", Bool]
      end
    end
  end

  def self.instance : SF::RenderWindow
    @@instance ||= create(Game.config["Fullscreen", Bool])
  end
end