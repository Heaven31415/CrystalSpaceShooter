require "crsfml/audio"
require "crsfml/graphics"
require "../app/packed_resources.cr"

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

packed_fonts = PackedResources(SF::Font).from_directory(fonts_path, true)
packed_fonts.save("data/fonts.data")
packed_fonts.build_enum("data/fonts.cr", fonts_enum)

packed_music = PackedResources(SF::Music).from_directory(music_path, true)
packed_music.save("data/music.data")
packed_music.build_enum("data/music.cr", music_enum)

packed_shaders = PackedResources(SF::Shader).from_directory(shaders_path, false)
packed_shaders.save("data/shaders.data")
packed_shaders.build_enum("data/shaders.cr", shaders_enum)

packed_sounds = PackedResources(SF::SoundBuffer).from_directory(sounds_path, true)
packed_sounds.save("data/sounds.data")
packed_sounds.build_enum("data/sounds.cr", sounds_enum)

packed_textures = PackedResources(SF::Texture).from_directory(textures_path, true)
packed_textures.save("data/textures.data")
packed_textures.build_enum("data/textures.cr", textures_enum)



