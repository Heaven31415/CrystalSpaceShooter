require "crsfml/audio"

SOUNDS_DIRECTORY = "../resources/sounds"

dirname = File.join("#{__DIR__}", SOUNDS_DIRECTORY)

buffers = [] of {String, SF::SoundBuffer}

Dir.open(dirname) do |dir|
  dir.each_child do |child|
    filename = File.join(dir.path, child)

    buffers << {child, SF::SoundBuffer.from_file(filename)}
  end
end

SAMPLE_MEAN = 10000

buffers.each do |buffer|
  slice = Slice.new(buffer[1].samples, buffer[1].sample_count)

  sum = 0
  slice.size.times do |i|
    sum += slice[i].abs
  end

  mean = sum.to_f32 / slice.size
  puts "#{buffer[0]}: #{mean.round(2)}"
end

buffers.each do |buffer|
  slice = Slice.new(buffer[1].samples, buffer[1].sample_count)

  max = slice[0]
  slice.size.times do |i|
    max = slice[i] if slice[i] > max 
  end

  samples = Array(Int16).new(slice.size)
  slice.size.times do |i|
    value = (slice[i].to_f32 / max * SAMPLE_MEAN).to_i16
    samples << value
  end

  new_buffer = SF::SoundBuffer.from_samples(samples, buffer[1].channel_count, buffer[1].sample_rate)
  new_buffer.save_to_file("#{__DIR__}/normalized/#{buffer[0]}")
end