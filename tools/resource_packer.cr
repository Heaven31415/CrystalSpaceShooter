require "crsfml/audio"
require "crsfml/graphics"
require "../src/packed_resources"

# Fonts
fonts_path    = "resources/fonts"
fonts_enum    = "Resource::Font"

# Music
music_path    = "resources/music"
music_enum    = "Resource::Music"

# Shaders
shaders_path  = "resources/shaders"
shaders_enum  = "Resource::Shader"

# Sounds
sounds_path   = "resources/sounds"
sounds_enum   = "Resource::Sound"

# Textures
textures_path = "resources/textures"
textures_enum = "Resource::Texture"

begin
  fonts = PackedResources(SF::Font).from_directory(fonts_path, erase_extensions: true)
  fonts.save("data/font.data")
  fonts.build_enum("data/font.cr", fonts_enum)
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
  shaders.save("data/shader.data")
  shaders.build_enum("data/shader.cr", shaders_enum)
rescue ex : Exception
  puts ex.message
end

begin
  sounds = PackedResources(SF::SoundBuffer).from_directory(sounds_path, erase_extensions: true)
  sounds.save("data/sound.data")
  sounds.build_enum("data/sound.cr", sounds_enum)
rescue ex : Exception
  puts ex.message
end

begin
  textures = PackedResources(SF::Texture).from_directory(textures_path, erase_extensions: true)
  textures.save("data/texture.data")
  textures.build_enum("data/texture.cr", textures_enum)
rescue ex : Exception
  puts ex.message
end



