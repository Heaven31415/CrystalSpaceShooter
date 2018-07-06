def sort_require(filename : String)
  unless File.exists? filename
    raise "Invalid filename: '#{filename}'" 
  end

  lines_without_require = File.read_lines(filename).reject! { |line| line.includes? "require" }

  # erase empty lines from beginning
  count = 0
  while true
    if lines_without_require[count].empty?
      count += 1
    else
      break
    end
  end
  lines_without_require.shift(count)

  lines_with_require = File.read_lines(filename).select! { |line| line.includes? "require" }.sort!
    
  File.open(filename, "w") do |file|
    lines_with_require.each do |line|
      file << line << '\n'
    end

    file << '\n'

    lines_without_require.each do |line|
      file << line << '\n'
    end
  end
end

def find_crystal_files_in_dir(directory_path : String) : Array(String)
  unless Dir.exists? directory_path
    raise "Invalid directory_path: '#{directory_path}'"
  end

  Dir.children(directory_path)
  .select! { |child| child.ends_with? ".cr" }
  .map! { |child| directory_path + child }
end

begin
  if ARGV.size == 0
    puts "Usage: xxx"
  end

  ARGV.each do |directory|
    files = find_crystal_files_in_dir(directory)
    files.each do |file|
      sort_require(file)
    end
  end
rescue ex
  puts "Exception: #{ex.message}"
end