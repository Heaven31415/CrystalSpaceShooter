require "crsfml/graphics"

require "openssl/sha1.cr"

class Button
  enum Properties
    NormalColor 
    PressedColor 
    HoverColor 
    LabelNormalColor
    LabelPressedColor
    LabelHoverColor
    OutlineColor
    OutlineThickness
    TextureName
    Size
  end

  def initialize(style : ButtonStyle)
  end
end

alias Property = Float32 | SF::Color | SF::Vector2f | String

class ButtonStyle
  def initialize
    @properties = {} of Button::Properties => Property
  end

  def []=(key : Button::Properties, value : Property)
    @properties[key] = value
  end

  def [](key : Button::Properties) : Property
    @properties[key]
  end

  def to_s(io)
    @properties.each do |key, value|
      io << key << " => " << value << '\n'
    end
  end

  def self.from_file(filename : String) : ButtonStyle
    unless File.file? filename
      raise "Unable to find file at: `#{filename}`"
    end

    unless File.extname(filename) == ".style"
      raise "Invalid file format, expecting `.style` extension"
    end

    if File.empty? filename 
      raise "Unable to read from an empty file at: `#{filename}`"
    end

    lines = File.read_lines(filename)
    numbered_lines = Array({Int32, String}).new(lines.size)

    i = 1
    lines.each do |line|
      numbered_lines << {i, line}
      i += 1
    end

    numbered_lines.reject! do |numbered_line|
      numbered_line[1].empty?
    end

    if numbered_lines.size == 0
      raise "File was composed entirely of empty lines: `#{filename}`"
    end

    header = numbered_lines[0][1]
    unless header.match(/###\s?+Button/)
      raise "Unable to find correct header in file: `#{filename}`"
    end

    style = ButtonStyle.new

    numbered_lines.shift # remove header line
    numbered_lines.each do |numbered_line|
      matches = numbered_line[1].match(/^([a-zA-Z0-9]+)\s?=\s?(.+)$/)
      unless matches
        raise "Invalid line format in file `#{filename}` at line #{numbered_line[0]}"
      end

      property_name = Button::Properties.parse? matches[1]
      unless property_name
        raise "Invalid property name in file `#{filename}` at line #{numbered_line[0]}"
      end

      property_value = matches[2]
      if matches = property_value.match(/^rgba\((.{1,3})\,\s(.{1,3})\,\s(.{1,3})\,\s(.{1,3})\)$/)
        # rgba(number, number, number, number)
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
          msg += "in file `#{filename}` at line #{numbered_line[0]}"
          raise msg
        end
      elsif matches = property_value.match(/^xy\((.+)\,\s(.+)\)$/)
        # xy(float, float)
        x = matches[1].to_f32?
        y = matches[2].to_f32?
        if x && y
          style[property_name] = SF::Vector2f.new(x, y)
        elsif !x && !y
          raise "Invalid vector2f `x` and `y` value in file `#{filename}` at line #{numbered_line[0]}"
        elsif !x
          raise "Invalid vector2f `x` value in file `#{filename}` at line #{numbered_line[0]}"
        elsif !y
          raise "Invalid vector2f `y` value in file `#{filename}` at line #{numbered_line[0]}"
        end
      elsif matches = property_value.match(/^\"([a-zA-z0-9_\.]+)\"$/)
        # "string"
        str = matches[1]
        style[property_name] = str
      elsif value = property_value.to_f32?
        # float32
        style[property_name] = value
      else
        raise "Invalid property value: `#{property_value}` in file `#{filename}` at line #{numbered_line[0]}"
      end
    end

    style
  end
end

def compute_file_hash(filename : String) : StaticArray(UInt8, 20)
  unless File.exists? filename
    raise "Unable to find file at location: `#{filename}`"
  end

  OpenSSL::SHA1.hash(File.read(filename))
end

# puts compute_file_hash("resources/styles/button.style")
# puts button_style = ButtonStyle.from_file("resources/styles/button.style")

filepath = "resources/styles/button.style"

button_style = ButtonStyle.from_file(filepath)
file_hash = compute_file_hash(filepath)
puts button_style

while true
  new_file_hash = compute_file_hash(filepath)
  if new_file_hash != file_hash
    begin
      new_button_style = ButtonStyle.from_file(filepath)
      button_style = new_button_style
    rescue
      
    ensure
      file_hash = new_file_hash
    end

    # puts "I'm going to hotload this file!
    system("clear")
    puts button_style
  else
    # puts "I'm going to do nothing with this file!"
  end
  sleep 1
end

