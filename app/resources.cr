require "../tools/resource_packer.cr"
require "../data/fonts.cr"
require "../data/sounds.cr"
require "../data/textures.cr"
require "crsfml/audio"
require "crsfml/graphics"

class Resources
  @@instance : Resources?

  def self.create : Resources
    resources = Resources.new
    resources
  end

  def self.instance : Resources
    @@instance ||= create
  end

  def initialize
    @fonts = {} of Fonts => SF::Font
    @sounds = {} of Sounds => SF::SoundBuffer
    @textures = {} of Textures => SF::Texture
  end

  def load_all
    load_fonts
    load_sounds
    load_textures
  end

  def load_fonts
    path = App.config["FontsPath", String]
    @fonts = PackedResources(SF::Font).new(path).unpack(Fonts)
  end

  def load_sounds
    path = App.config["SoundsPath", String]
    @sounds = PackedResources(SF::SoundBuffer).new(path).unpack(Sounds)
  end

  def load_textures
    path = App.config["TexturesPath", String]
    @textures = PackedResources(SF::Texture).new(path).unpack(Textures)
  end

  def [](font : Fonts) : SF::Font
    @fonts[font]
  end

  def [](sound : Sounds) : SF::SoundBuffer
    @sounds[sound]
  end

  def [](texture : Textures) : SF::Texture
    @textures[texture]
  end
end