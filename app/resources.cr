require "../data/fonts"
require "../data/music"
require "../data/shaders"
require "../data/sounds"
require "../data/textures"
require "./packed_resources"
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
  @packed_shaders : PackedResources(SF::Shader)? = nil
  @packed_sounds : PackedResources(SF::SoundBuffer)? = nil 
  @packed_textures : PackedResources(SF::Texture)? = nil

  def initialize
    @fonts = {} of Fonts => SF::Font
    @music = {} of Music => Bytes
    @shaders = {} of Shaders => String
    @sounds = {} of Sounds => SF::SoundBuffer
    @textures = {} of Textures => SF::Texture
  end

  def load_all
    load_fonts
    load_music
    load_shaders
    load_sounds
    load_textures
  end

  def load_fonts
    path = App.config["FontsPath", String]
    @packed_fonts = PackedResources(SF::Font).new(path)
    if packed_fonts = @packed_fonts
      packed_fonts.resources.each do |font|
        key = Fonts.parse(font[:name])
        @fonts[key] = SF::Font.from_memory(font[:bytes])
      end
    end
  end

  def load_music
    path = App.config["MusicPath", String]
    @packed_music = PackedResources(SF::Music).new(path)
    if packed_music = @packed_music
      packed_music.resources.each do |music|
        key = Music.parse(music[:name])
        @music[key] = music[:bytes]
      end
    end
  end

  def load_shaders
    path = App.config["ShadersPath", String]
    @packed_shaders = PackedResources(SF::Shader).new(path)
    if packed_shaders = @packed_shaders
      packed_shaders.resources.each do |shader|
        key = Shaders.parse(shader[:name])
        @shaders[key] = String.new(shader[:bytes])
      end
    end
  end

  def load_sounds
    path = App.config["SoundsPath", String]
    @packed_sounds = PackedResources(SF::SoundBuffer).new(path)
    if packed_sounds = @packed_sounds
      packed_sounds.resources.each do |sound|
        key = Sounds.parse(sound[:name])
        @sounds[key] = SF::SoundBuffer.from_memory(sound[:bytes])
      end
    end
  end

  def load_textures
    path = App.config["TexturesPath", String]
    @packed_textures = PackedResources(SF::Texture).new(path)
    if packed_textures = @packed_textures
      packed_textures.resources.each do |texture|
        key = Textures.parse(texture[:name])
        @textures[key] = SF::Texture.from_memory(texture[:bytes])
      end
    end
  end

  def [](font : Fonts) : SF::Font
    @fonts[font]
  end

  def [](music : Music) : Bytes
    @music[music]
  end

  def [](shader : Shaders) : String
    @shaders[shader]
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

  def [](key : String, t : SF::Music.class) : Bytes
    @music[Music.parse(key)]
  end

  def [](key : String, t : SF::Shader.class) : String
    @shaders[Shaders.parse(key)]
  end

  def [](key : String, t : SF::SoundBuffer.class) : SF::SoundBuffer
    @sounds[Sounds.parse(key)]
  end

  def [](key : String, t : SF::Texture.class) : SF::Texture
    @textures[Textures.parse(key)]
  end
end