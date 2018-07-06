require "crsfml/audio"
require "./resource_holder.cr"

class SoundSystem
	def initialize(@sound_buffers : ResourceHolder(SF::SoundBuffer))
		@sounds = [] of SF::Sound
	end

	def play(sound_name : String, volume = 100.0_f32, pitch = 1.0_f32)
		sound = SF::Sound.new(@sound_buffers.get(sound_name))
		sound.volume = volume
		sound.pitch = pitch
		sound.play
		@sounds << sound
		clean
	end

	def clean
		@sounds.select! { |sound| sound.status != SF::SoundSource::Stopped }
	end
end