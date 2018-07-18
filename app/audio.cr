require "./resources.cr"

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
    @sounds = Array(SF::Sound).new
    @music = SF::Music.new
  end

  def play_sound(sound : Sounds, volume : Float32 = 100f32, pitch : Float32 = 1f32)
    sound_buffer = App.resources[sound]
    sound = SF::Sound.new(sound_buffer)
    sound.volume = volume
    sound.pitch = pitch
    sound.play

    @sounds.push(sound)
    remove_stopped_sounds
  end

  private def remove_stopped_sounds
    @sounds.select! { |sound| sound.status != SF::SoundSource::Stopped }
  end

  def play_music(music : Music, volume : Float32 = 100f32, pitch : Float32 = 1f32, loop : Bool = true)
    name = music.to_s
    App.resources.packed_music.resources.each do |resource|
      if resource[:name] == name
        @music.open_from_memory(resource[:bytes])
        @music.volume = volume
        @music.pitch = pitch
        @music.play
        @music.loop = loop
      end
    end
  end

  def stop_music
    @music.stop
  end
end