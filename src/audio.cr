require "./resources"

class Audio
  @@instance : Audio?

  def self.create : Audio
    audio = Audio.new
    audio
  end

  def self.instance : Audio
    @@instance ||= create
  end

  def initialize
    @counter = 0
    @sounds = Array(SF::Sound).new(128) do
      SF::Sound.new
    end
    @music = SF::Music.new
  end

  def play_sound(sound : Resource::Sound, volume : Float32 = 100f32, pitch : Float32 = 1f32) : Int32
    i = 0
    while true
      if i == 128 || @sounds[i].status == SF::SoundSource::Stopped
        break
      end
      i += 1
    end

    if i == 128
      raise "Unable to find any free sound, you are playing too many sounds."
    end

    _sound = @sounds[i]
    _sound.buffer = Game.resources[sound]
    _sound.volume = volume
    _sound.pitch = pitch
    _sound.play
    
    id = (@counter << 8) + i
    @counter += 1
    id
  end

  def playing?(id : Int32) : Bool
    (@sounds.has_key? id) && @sounds[id].status == SF::SoundSource::Playing
  end

  def play_music(music : Resource::Music, volume : Float32 = 100f32, pitch : Float32 = 1f32, loop : Bool = true) : Nil
    @music.open_from_memory(Game.resources[music])
    @music.volume = volume
    @music.pitch = pitch
    @music.play
    @music.loop = loop
  end

  def music_volume=(volume : Float32) : Nil
    @music.volume = volume
  end

  def music_volume : Float32
    @music.volume
  end

  def stop_music : Nil
    @music.stop
  end
end