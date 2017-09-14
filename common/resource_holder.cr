class ResourceHolder(T)
  def initialize(path_to_dir : String, extensions : Array(String))
    @resources = {} of String => T
    find_resources(path_to_dir, extensions)
  end

  def find_resources(path_to_dir : String, extensions : Array(String))
    if !Dir.exists?(Dir.current + '/' + path_to_dir)
      raise "Unable to find directory at location: #{Dir.current + '/' + path_to_dir}"
    else
      Dir.cd(path_to_dir) do
        Dir.foreach(Dir.current) do |filename|
          if File.directory?(Dir.current + '/' + filename)
            if !(filename == "." || filename == "..")
              find_resources(filename, extensions)
            end
          else
            extensions.each do |ext|
              if matches = filename.match(/([a-zA-z\d]+)\.(#{ext})/)
                if @resources.has_key?(filename)
                  raise "You were trying to add file with name \"#{filename}\" twice"
                else
                  @resources[filename] = T.from_file(filename)
                  # puts "#{T} loaded from: #{Dir.current + '/' + filename}" #debug
                end
              end
            end
          end
        end
      end
    end
  end

  def get(key : String) : T
    if @resources.has_key?(key)
      @resources[key]
    else
      raise "Unable to find a #{T} resource associated with key: #{key}"
    end
  end
end
