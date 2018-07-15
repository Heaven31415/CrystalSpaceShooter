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

# todo: move those methods inside DirectoryWatcher

alias FileHash = StaticArray(UInt8, 20)

def compute_filehash(filename : String) : FileHash
  unless File.exists? filename
    raise "Unable to find file at: `#{filename}`"
  end

  unless File.readable? filename
    raise "Unable to read file at: `#{filename}`"
  end

  OpenSSL::SHA1.hash(File.read(filename))
end

alias DirectoryHash = Array({name: String, hash: FileHash})

def compute_directory_hash(directory_path : String) : DirectoryHash
  unless Dir.exists? directory_path
    raise "Unable to find directory at: `#{directory_path}`"
  end

  hash = DirectoryHash.new
  Dir.each_child(directory_path) do |filename|
    hash << {name: filename, hash: compute_filehash(File.join(directory_path, filename))}
  end

  hash
end

def get_created_files(old_hash : DirectoryHash, new_hash : DirectoryHash) : Array(String)
  created_files = Array(String).new

  new_hash.each do |n|
    unless old_hash.find { |o| o[:name] == n[:name]}
      created_files << n[:name]
    end 
  end

  created_files
end

def get_deleted_files(old_hash : DirectoryHash, new_hash : DirectoryHash) : Array(String)
  deleted_files = Array(String).new
  
  old_hash.each do |o|
    unless new_hash.find { |n| o[:name] == n[:name]}
      deleted_files << o[:name]
    end 
  end

  deleted_files
end

def get_changed_files(old_hash : DirectoryHash, new_hash : DirectoryHash, directory_path : String) : Array(String)
  hash = DirectoryHash.new

  old_hash.each do |o|
    new_hash.each do |n|
      if o[:name] == n[:name]
        hash << o
      end
    end
  end

  changed_files = Array(String).new

  hash.each do |o|
    if o[:hash] != compute_filehash(File.join(directory_path, o[:name]))
      changed_files << o[:name]
    end
  end

  changed_files
end

class DirectoryWatcher
  @hash : DirectoryHash

  property directory_path

  def initialize(@directory_path : String)
    unless Dir.exists? @directory_path
      raise "Unable to find directory at: `#{@directory_path}`"
    end

    @hash = compute_directory_hash(@directory_path)
    @on_file_created = Hash(String, Proc(String, Nil)).new
    @on_file_deleted = Hash(String, Proc(String, Nil)).new
    @on_file_changed = Hash(String, Proc(String, Nil)).new
  end

  def update
    new_hash = compute_directory_hash(@directory_path)
    created_files = get_created_files(@hash, new_hash)
    deleted_files = get_deleted_files(@hash, new_hash)
    changed_files = get_changed_files(@hash, new_hash, @directory_path)

    created_files.each do |filename|
      file_created(File.join(@directory_path, filename))
    end

    deleted_files.each do |filename|
      file_deleted(File.join(@directory_path, filename))
    end

    changed_files.each do |filename|
      file_changed(File.join(@directory_path, filename))
    end

    @hash = new_hash
  end

  def on_file_created(callback_id : String, &block : String ->)
    @on_file_created[callback_id] = block
  end

  private def file_created(filename : String)
    @on_file_created.each_value do |callback|
      callback.call(filename)
    end
  end

  def on_file_deleted(callback_id : String, &block : String ->)
    @on_file_deleted[callback_id] = block
  end

  private def file_deleted(filename : String)
    @on_file_deleted.each_value do |callback|
      callback.call(filename)
    end
  end

  def on_file_changed(callback_id : String, &block : String ->)
    @on_file_changed[callback_id] = block
  end

  private def file_changed(filename : String)
    @on_file_changed.each_value do |callback|
      callback.call(filename)
    end
  end
end

module Tools
  extend self

  def find_filenames(directory_path : String, &block : String -> Bool) : Array(String)
    unless Dir.exists? directory_path
      raise "Unable to find directory at: `#{directory_path}`"
    end

    filenames = [] of String

    Dir.each_child(directory_path) do |name|
      path = File.join(directory_path, name)
      if Dir.exists? path
        filenames += find_filenames(path, &block)
      else
        filenames << path if block.call(path)
      end
    end

    filenames
  end
end

# filenames = Tools.find_filenames("resources/styles") do |filename|
#   File.extname(filename) == ".button"
# end

# puts filenames