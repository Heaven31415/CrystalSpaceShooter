require "../data/font"
require "../data/music"
require "../data/shader"
require "../data/sound"
require "../data/texture"
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
    @fonts = {} of Resource::Font => SF::Font
    @music = {} of Resource::Music => Bytes
    @shaders = {} of Resource::Shader => String
    @sounds = {} of Resource::Sound => SF::SoundBuffer
    @textures = {} of Resource::Texture => SF::Texture
  end

  def load_all : Nil
    load_fonts
    load_music
    load_shaders
    load_sounds
    load_textures
  end

  def load_fonts : Nil
    path = Game.config["FontsPath", String]
    @packed_fonts = PackedResources(SF::Font).new(path)
    if packed_fonts = @packed_fonts
      packed_fonts.resources.each do |font|
        key = Resource::Font.parse(font[:name])
        @fonts[key] = SF::Font.from_memory(font[:bytes])
      end
    end
  end

  def load_music : Nil
    path = Game.config["MusicPath", String]
    @packed_music = PackedResources(SF::Music).new(path)
    if packed_music = @packed_music
      packed_music.resources.each do |music|
        key = Resource::Music.parse(music[:name])
        @music[key] = music[:bytes]
      end
    end
  end

  def load_shaders : Nil
    path = Game.config["ShadersPath", String]
    @packed_shaders = PackedResources(SF::Shader).new(path)
    if packed_shaders = @packed_shaders
      packed_shaders.resources.each do |shader|
        key = Resource::Shader.parse(shader[:name])
        @shaders[key] = String.new(shader[:bytes])
      end
    end
  end

  def load_sounds : Nil
    path = Game.config["SoundsPath", String]
    @packed_sounds = PackedResources(SF::SoundBuffer).new(path)
    if packed_sounds = @packed_sounds
      packed_sounds.resources.each do |sound|
        key = Resource::Sound.parse(sound[:name])
        @sounds[key] = SF::SoundBuffer.from_memory(sound[:bytes])
      end
    end
  end

  def load_textures : Nil
    path = Game.config["TexturesPath", String]
    @packed_textures = PackedResources(SF::Texture).new(path)
    if packed_textures = @packed_textures
      packed_textures.resources.each do |texture|
        key = Resource::Texture.parse(texture[:name])
        @textures[key] = SF::Texture.from_memory(texture[:bytes])
      end
    end
  end

  def [](font : Resource::Font) : SF::Font
    @fonts[font]
  end

  def [](music : Resource::Music) : Bytes
    @music[music]
  end

  def [](shader : Resource::Shader) : String
    @shaders[shader]
  end

  def [](sound : Resource::Sound) : SF::SoundBuffer
    @sounds[sound]
  end

  def [](texture : Resource::Texture) : SF::Texture
    @textures[texture]
  end

  def [](key : String, t : SF::Font.class) : SF::Font
    @fonts[Resource::Font.parse(key)]
  end

  def [](key : String, t : SF::Music.class) : Bytes
    @music[Resource::Music.parse(key)]
  end

  def [](key : String, t : SF::Shader.class) : String
    @shaders[Resource::Shader.parse(key)]
  end

  def [](key : String, t : SF::SoundBuffer.class) : SF::SoundBuffer
    @sounds[Resource::Sound.parse(key)]
  end

  def [](key : String, t : SF::Texture.class) : SF::Texture
    @textures[Resource::Texture.parse(key)]
  end
end