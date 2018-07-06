require "./common/utilities.cr"

class Config
  # frames per seconds
  @@fps = 60.0
  # resources paths
  @@fonts_path = "resources/fonts"
  @@sounds_path = "resources/sounds"
  @@textures_path = "resources/textures"
  # resources extensions
  @@fonts_ext = ["ttf"]
  @@sounds_ext = ["wav"]
  @@textures_ext = ["png"]
  # window settings
  @@window_size = SF.vector2i(800, 900)
  @@window_rect = SF.int_rect(0, 0, @@window_size.x, @@window_size.y)
{% if flag?(:release) %}
  @@window_name = "Crystal Space Shooter! (Release)"
{% else %}
  @@window_name = "Crystal Space Shooter! (Debug)"
{% end %}
  # background settings
  @@background_velocity = SF.vector2f(0.0, 75.0)

  class_getter(
    fps,
    fonts_path,
    sounds_path,
    textures_path,
    fonts_ext,
    sounds_ext,
    textures_ext,
    window_size,
    window_rect,
    window_name,
    background_velocity,
  )

  {% if flag?(:debug) %}
  # debug window settings
  @@debug_window_size = SF.vector2i(800, 600)
  @@debug_window_rect = SF.int_rect(0, 0, @@debug_window_size.x, @@debug_window_size.y)
  @@debug_window_name = "Debug Window"

  class_getter(
    debug_window_size,
    debug_window_rect,
    debug_window_name
  )
{% end %}
end
