require "../tools/resource_packer.cr"
require "../data/fonts.cr"
require "../data/sounds.cr"
require "../data/textures.cr"
require "crsfml/audio"
require "crsfml/graphics"

class Resources
  @@fonts : Hash(Fonts, SF::Font)? = nil
  @@sounds : Hash(Sounds, SF::SoundBuffer)? = nil
  @@textures : Hash(Textures, SF::Texture)? = nil

  def self.load_all
    self.load_fonts
    self.load_sounds
    self.load_textures
  end

  def self.load_fonts
    path = App.config["FontsPath", String]
    @@fonts = PackedResources(SF::Font).new(path).unpack(Fonts)
  end

  def self.load_sounds
    path = App.config["SoundsPath", String]
    @@sounds = PackedResources(SF::SoundBuffer).new(path).unpack(Sounds)
  end

  def self.load_textures
    path = App.config["TexturesPath", String]
    @@textures = PackedResources(SF::Texture).new(path).unpack(Textures)
  end

  def self.get(font : Fonts) : SF::Font
    if fonts = @@fonts
      fonts[font]
    else
      raise "Unable to load font: `#{font}`, fonts aren't loaded"
    end
  end

  def self.get(sound : Sounds) : SF::SoundBuffer
    if sounds = @@sounds
      sounds[sound]
    else
      raise "Unable to load sound: `#{sound}`, sounds aren't loaded"
    end
  end

  def self.get(texture : Textures) : SF::Texture
    if textures = @@textures
      textures[texture]
    else
      raise "Unable to load texture: `#{texture}`, textures aren't loaded"
    end
  end
end