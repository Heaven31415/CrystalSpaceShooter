require "./config.cr"
require "./resource_holder.cr"
require "crsfml/audio"
require "crsfml/graphics"

class Resources
  @@fonts = ResourceHolder(SF::Font).new(Config.fonts_path, Config.fonts_ext)
  @@sounds = ResourceHolder(SF::SoundBuffer).new(Config.sounds_path, Config.sounds_ext)
  @@textures = ResourceHolder(SF::Texture).new(Config.textures_path, Config.textures_ext)

  class_getter fonts, sounds, textures
end