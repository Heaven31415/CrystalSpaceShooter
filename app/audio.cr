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

  def play_sound(sound_id : Sounds, volume : Float32 = 100f32, pitch : Float32 = 1f32) : Int32
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

    sound = @sounds[i]
    sound.buffer = App.resources[sound_id]
    sound.volume = volume
    sound.pitch = pitch
    sound.play
    
    id = (@counter << 8) + i
    @counter += 1
    id
  end

  def playing?(id : Int32) : Bool
    (@sounds.has_key? id) && @sounds[id].status == SF::SoundSource::Playing
  end

  private def remove_stopped_sounds
    @sounds.reject! { |id, sound| sound.status != SF::SoundSource::Playing }
  end

  def play_music(music : Music, volume : Float32 = 100f32, pitch : Float32 = 1f32, loop : Bool = true)
    @music.open_from_memory(App.resources[music])
    @music.volume = volume
    @music.pitch = pitch
    @music.play
    @music.loop = loop
  end

  def music_volume=(v : Float32)
    @music.volume = v
  end

  def music_volume : Float3 
    @music.volume
  end

  def stop_music
    @music.stop
  end
end