require "crsfml/audio"
require "crsfml/graphics"
require "./resource_packer.cr"

fonts_path = "resources/fonts"
sounds_path = "resources/sounds"
textures_path = "resources/textures"

packed_fonts = PackedResources(SF::Font).new(fonts_path)
packed_fonts.save("data/fonts.data")
packed_fonts.build_enum("common/fonts.cr", "Fonts")

packed_sounds = PackedResources(SF::SoundBuffer).new(sounds_path)
packed_sounds.save("data/sounds.data")
packed_sounds.build_enum("common/sounds.cr", "Sounds")

packed_textures = PackedResources(SF::Texture).new(textures_path)
packed_textures.save("data/textures.data")
packed_textures.build_enum("common/textures.cr", "Textures")



