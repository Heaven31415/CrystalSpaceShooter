require "openssl/sha1.cr"

class Pair(T1, T2)
  property first, second

  def initialize(@first : T1, @second : T2)
  end
end

module Math
  def self.cartesian_to_polar(x : Number, y : Number)
    {radius: Math.hypot(x, y), angle: Math.atan2(y, x)}
  end

  def self.polar_to_cartesian(radius : Number, angle : Number)
    {x: radius * Math.cos(angle), y: radius * Math.sin(angle)}
  end
end

def compute_file_hash(filename : String) : StaticArray(UInt8, 20)
  unless File.exists? filename
    raise "Unable to find file at location: `#{filename}`"
  end

  OpenSSL::SHA1.hash(File.read(filename))
end

alias DirectoryHashes = Array({String, StaticArray(UInt8, 20)})

def compute_directory_hashes(dir_path : String) : DirectoryHashes
  hashes = DirectoryHashes.new
  Dir.each_child(dir_path) do |filename|
    hashes << {filename, compute_file_hash(File.join(dir_path, filename))}
  end
  hashes
end

def compare_directory_hashes(dir_path : String, old_hashes : DirectoryHashes, new_hashes : DirectoryHashes) : {Array(String), Array(String), Array(String)}
  created_files = Array(String).new
  deleted_files = Array(String).new

  old_hashes.each do |old_element|
    unless new_hashes.find { |new_element| new_element[0] == old_element[0]}
      deleted_files << old_element[0]
    end
  end

  new_hashes.each do |new_element|
    unless old_hashes.find { |old_element| old_element[0] == new_element[0]}
      created_files << new_element[0]
    end
  end

  old_files = Array(String).new(old_hashes.size)
  old_hashes.each do |old_element|
    old_files << old_element[0]
  end

  changed_files = (old_files - deleted_files).select! do |file|
    old_hash = old_hashes.find { |old_element| old_element[0] == file}.as({String, StaticArray(UInt8, 20)})[1]
    new_hash = compute_file_hash(File.join(dir_path, file))
    old_hash != new_hash
  end

  {created_files, deleted_files, changed_files}
end

class DirectoryWatcher
  @hashes : Array({String, StaticArray(UInt8, 20)})

  def initialize(@dir_path : String)
    unless Dir.exists? @dir_path
      raise "Unable to find directory at location: `#{@dir_path}`"
    end

    @hashes = compute_directory_hashes(@dir_path)
  end

  def hotload
    new_hashes = compute_directory_hashes(@dir_path)
    files = compare_directory_hashes(@dir_path, @hashes, new_hashes)
    created_files = files[0]
    deleted_files = files[1]
    changed_files = files[2]

    created_files.each do |file|
      file_created(File.join(@dir_path, file))
    end

    deleted_files.each do |file|
      file_deleted(File.join(@dir_path, file))
    end

    changed_files.each do |file|
      file_changed(File.join(@dir_path, file))
    end

    @hashes = new_hashes
  end

  def on_file_created(&block : String ->)
    @on_file_created_callback = block
  end

  private def file_created(filename : String)
    if callback = @on_file_created_callback
      callback.call(filename)
    end
  end

  def on_file_deleted(&block : String ->)
    @on_file_deleted_callback = block
  end

  private def file_deleted(filename : String)
    if callback = @on_file_deleted_callback
      callback.call(filename)
    end
  end

  def on_file_changed(&block : String ->)
    @on_file_changed_callback = block
  end

  private def file_changed(filename : String)
    if callback = @on_file_changed_callback
      callback.call(filename)
    end
  end
end

# # watcher test
# watcher = DirectoryWatcher.new("tmp")
# watcher.on_file_created { |file| puts "New file has been created: `#{file}`" }
# watcher.on_file_deleted { |file| puts "File has been deleted: `#{file}`" }
# watcher.on_file_changed { |file| puts "File has been changed: `#{file}`"}

# while true
#   watcher.hotload
#   sleep 1
# end
