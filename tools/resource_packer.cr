require "crsfml/audio"
require "crsfml/graphics"
require "../app/packed_resources"

# Fonts
fonts_path    = "resources/fonts"
fonts_enum    = "Fonts"

# Music
music_path    = "resources/music"
music_enum    = "Music"

# Shaders
shaders_path  = "resources/shaders"
shaders_enum  = "Shaders"

# Sounds
sounds_path   = "resources/sounds"
sounds_enum   = "Sounds"

# Textures
textures_path = "resources/textures"
textures_enum = "Textures"

begin
  fonts = PackedResources(SF::Font).from_directory(fonts_path, erase_extensions: true)
  fonts.save("data/fonts.data")
  fonts.build_enum("data/fonts.cr", fonts_enum)
rescue ex : Exception
  puts ex.message
end

begin
  music = PackedResources(SF::Music).from_directory(music_path, erase_extensions: true)
  music.save("data/music.data")
  music.build_enum("data/music.cr", music_enum)
rescue ex : Exception
  puts ex.message
end

begin
  shaders = PackedResources(SF::Shader).from_directory(shaders_path, erase_extensions: false)
  shaders.save("data/shaders.data")
  shaders.build_enum("data/shaders.cr", shaders_enum)
rescue ex : Exception
  puts ex.message
end

begin
  sounds = PackedResources(SF::SoundBuffer).from_directory(sounds_path, erase_extensions: true)
  sounds.save("data/sounds.data")
  sounds.build_enum("data/sounds.cr", sounds_enum)
rescue ex : Exception
  puts ex.message
end

begin
  textures = PackedResources(SF::Texture).from_directory(textures_path, erase_extensions: true)
  textures.save("data/textures.data")
  textures.build_enum("data/textures.cr", textures_enum)
rescue ex : Exception
  puts ex.message
end



