require "../tools/resource_packer.cr"
require "../data/fonts.cr"
require "../data/music.cr"
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

  @packed_fonts : PackedResources(SF::Font)? = nil
  @packed_music : PackedResources(SF::Music)? = nil
  @packed_sounds : PackedResources(SF::SoundBuffer)? = nil 
  @packed_textures : PackedResources(SF::Texture)? = nil

  def packed_music : PackedResources(SF::Music)
    unless packed_music = @packed_music
      load_music
    end

    @packed_music.as(PackedResources(SF::Music))
  end

  def initialize
    @fonts = {} of Fonts => SF::Font
    @sounds = {} of Sounds => SF::SoundBuffer
    @textures = {} of Textures => SF::Texture
  end

  def load_all
    load_fonts
    load_music
    load_sounds
    load_textures
  end

  def load_fonts
    path = App.config["FontsPath", String]
    @packed_fonts = PackedResources(SF::Font).new(path)
    if packed_fonts = @packed_fonts
      @fonts = packed_fonts.unpack(Fonts)
    end
  end

  def load_music
    path = App.config["MusicPath", String]
    @packed_music = PackedResources(SF::Music).new(path)
  end

  def load_sounds
    path = App.config["SoundsPath", String]
    @packed_sounds = PackedResources(SF::SoundBuffer).new(path)
    if packed_sounds = @packed_sounds
      @sounds = packed_sounds.unpack(Sounds)
    end
  end

  def load_textures
    path = App.config["TexturesPath", String]
    @packed_textures = PackedResources(SF::Texture).new(path)
    if packed_textures = @packed_textures
      @textures = packed_textures.unpack(Textures)
    end
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

  def [](key : String, t : SF::Font.class) : SF::Font
    @fonts[Fonts.parse(key)]
  end

  def [](key : String, t : SF::SoundBuffer.class) : SF::SoundBuffer
    @sounds[Sounds.parse(key)]
  end

  def [](key : String, t : SF::Texture.class) : SF::Texture
    @textures[Textures.parse(key)]
  end
end