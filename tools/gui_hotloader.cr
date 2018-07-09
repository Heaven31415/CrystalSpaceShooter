# GUI Hotloader Test
# 
# This file implements reader and writer for special style files, which
# describe visual properties of widgets like buttons and sliders. It also
# implements a very simple hotloading system, allowing the program to notice
# when you change something in your style file and load those changes immediately.
#

require "crsfml/graphics"
require "openssl/sha1.cr"

class Button
  property style
  def initialize(@style : Style(Button))
  end
end

class Slider
  property style
  def initialize(@style : Style(Slider))
  end
end

alias Property = Float32 | SF::Color | SF::Vector2f | String

class Style(T)
  LINE_FORMAT_REGEX = /^([a-zA-Z0-9]+)\s?=\s?(.+)$/
  COLOR_REGEX = /^rgba\((.{1,3})\,\s(.{1,3})\,\s(.{1,3})\,\s(.{1,3})\)$/
  VECTOR_REGEX = /^xy\((.+)\,\s(.+)\)$/
  STRING_REGEX = /^\"([a-zA-z0-9_\.]+)\"$/

  def initialize
    @properties = {} of String => Property
  end

  def []=(key : String, value : Property)
    @properties[key] = value
  end

  def [](key : String, t : T.class) forall T
    @properties[key].as(T)
  end

  def [](key : String) : Property
    @properties[key]
  end

  def to_s(io)
    @properties.each do |key, value|
      io << key << " => " << value << '\n'
    end
  end

  def self.from_file(filename : String) : self
    if file = File.info? filename
      unless file.file?
        raise "Unable to find file at: `#{filename}`"
      end
    else
      raise "Unable to find anything at: `#{filename}`"
    end

    unless File.extname(filename) == ".#{T.name.downcase}"
      raise "Invalid file format, expecting `.#{T.name.downcase}` extension"
    end

    if File.empty? filename 
      raise "Unable to read from an empty file at: `#{filename}`"
    end

    i = 1
    lines = Array({number: Int32, content: String}).new

    File.each_line(filename) do |line|
      lines << {number: i, content: line}
      i += 1
    end

    lines.reject! do |line|
      line[:content].empty?
    end

    if lines.size == 0
      raise "File was composed entirely of empty lines: `#{filename}`"
    end

    header = lines[0][:content]
    unless header.match(/###\s?+#{T.name}/)
      raise "Unable to find `#{T.name}` header in file: `#{filename}`"
    end
    
    lines.shift # remove header line
    style = Style(T).new

    lines.each do |line|
      matches = line[:content].match(LINE_FORMAT_REGEX)
      unless matches
        raise "Invalid line format in file `#{filename}` at line #{line[:number]}"
      end

      property_name = matches[1]
      property_value = matches[2]

      if matches = property_value.match(COLOR_REGEX) # rgba(number, number, number, number)
        r = matches[1].to_u8?
        g = matches[2].to_u8?
        b = matches[3].to_u8?
        a = matches[4].to_u8?
        if r && g && b && a
          style[property_name] = SF::Color.new(r, g, b, a)
        else
          msg = "Invalid color value "
          msg += "`r` " if !r
          msg += "`g` " if !g
          msg += "`b` " if !b
          msg += "`a` " if !a
          msg += "in file `#{filename}` at line #{line[:number]}"
          raise msg
        end
      elsif matches = property_value.match(VECTOR_REGEX) # xy(float, float)
        x = matches[1].to_f32?
        y = matches[2].to_f32?
        if x && y
          style[property_name] = SF::Vector2f.new(x, y)
        elsif !x && !y
          raise "Invalid vector2f `x` and `y` value in file `#{filename}` at line #{line[:number]}"
        elsif !x
          raise "Invalid vector2f `x` value in file `#{filename}` at line #{line[:number]}"
        elsif !y
          raise "Invalid vector2f `y` value in file `#{filename}` at line #{line[:number]}"
        end
      elsif matches = property_value.match(STRING_REGEX) # "string"
        str = matches[1]
        style[property_name] = str
      elsif value = property_value.to_f32? # float32
        style[property_name] = value
      else
        raise "Invalid property value: `#{property_value}` in file `#{filename}` at line #{line[:number]}"
      end
    end
    style
  end

  def to_file(filename : String, force_overwrite : Bool = false)
    if File.exists? filename
      if !force_overwrite
        if File.writable? filename
          raise "Unable to overwrite file at: `#{filename}`"
        else
          raise "Not enough permissions to overwrite file at: `#{filename}`"
        end
      end
    end

    File.open(filename, "w") do |file|
      file << "### " << T.name << '\n'
      file << '\n'

      @properties.each do |key, value|
        case value
        when Float32
          file << key << " = " << value << '\n'
        when SF::Color
          file << key << " = " << "rgba(" << value.r << ", " << value.g << ", " << 
          value.b << ", " << value.a << ")\n"
        when SF::Vector2f
          file << key << " = " << "xy(" << value.x << ", " << value.y << ")\n"
        when String
          file << key << " = " << '"' << value << '"' << '\n'
        else
          raise "Invalid value type: `#{typeof(value)}`"
        end
      end
    end
  end
end

def compute_file_hash(filename : String) : StaticArray(UInt8, 20)
  unless File.exists? filename
    raise "Unable to find file at: `#{filename}`"
  end

  OpenSSL::SHA1.hash(File.read(filename))
end

# button = Button.new(Style(Button).from_file("resources/styles/test.button"))
# button.style.to_file("resources/styles/save_test.button")
#
# slider = Slider.new(Style(Slider).from_file("resources/styles/test.slider"))
# slider.style.to_file("resources/styles/save_test.slider")

filepath = "resources/styles/test.button"
button_style = Style(Button).from_file(filepath)
file_hash = compute_file_hash(filepath)
puts button_style

while true
  new_file_hash = compute_file_hash(filepath)
  if new_file_hash != file_hash
    begin
      new_button_style = Style(Button).from_file(filepath)
      button_style = new_button_style
    rescue
      # if something bad happens, just keep old style information
    ensure
      file_hash = new_file_hash
    end

    system("clear")
    puts button_style
  end
  sleep 1
end

