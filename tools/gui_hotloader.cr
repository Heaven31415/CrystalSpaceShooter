# GUI Hotloader Test
# 
# This file implements reader and writer for special .style files, which
# describe visual properties of widgets like buttons and sliders. It also
# implements a very simple hotloading system, allowing the program to notice
# when you change something in your .style file and load those changes immediately.
#

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

  def initialize(style : Style(Properties))
  end
end

class Slider
  enum Properties
    BaseFillColor
    BaseOutlineColor
    BaseOutlineThickness
    FillFillColor
    FillOutlineColor
    FillOutlineThickness
    BarFillColor
    BarWidth
    Size
  end
end

alias PropertyValue = Float32 | SF::Color | SF::Vector2f | String

class Style(T)
  def initialize
    @properties = {} of T => PropertyValue
  end

  def []=(key : T, value : PropertyValue)
    @properties[key] = value
  end

  def [](key : T) : PropertyValue
    @properties[key]
  end

  def to_s(io)
    @properties.each do |key, value|
      io << key << " => " << value << '\n'
    end
  end

  def self.from_file(filename : String) : self
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
    unless header.match(/###\s?+#{T}/)
      raise "Unable to find correct header in file: `#{filename}`"
    end

    style = self.new

    numbered_lines.shift # remove header line
    numbered_lines.each do |numbered_line|
      matches = numbered_line[1].match(/^([a-zA-Z0-9]+)\s?=\s?(.+)$/)
      unless matches
        raise "Invalid line format in file `#{filename}` at line #{numbered_line[0]}"
      end

      property_name = T.parse? matches[1]
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

  def to_file(filename : String, force_overwrite : Bool = false)
    if File.exists? filename
      if !force_overwrite
        if File.writable? filename
          raise "Unable to overwrite file at location: `#{filename}`"
        else
          raise "Not enough permissions to overwrite file at location: `#{filename}`"
        end
      end
    end

    file = File.open(filename, "w")
    file << "### " << T << '\n'
    file << '\n'

    T.each do |key|
      value = @properties[key]
      case value
      when Float32
        file << key << " = " << @properties[key] << '\n'
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

    file.close
  end
end

def compute_file_hash(filename : String) : StaticArray(UInt8, 20)
  unless File.exists? filename
    raise "Unable to find file at location: `#{filename}`"
  end

  OpenSSL::SHA1.hash(File.read(filename))
end

# 
# button_style = Style(Button::Properties).from_file("resources/styles/button.style")
# button_style.to_file("resources/styles/test.style", true)
#
# slider_style = Style(Slider::Properties).from_file("resources/styles/slider.style")
# slider_style.to_file("resources/styles/test.style", true)
#

filepath = "resources/styles/button.style"

button_style = Style(Button::Properties).from_file(filepath)
file_hash = compute_file_hash(filepath)
puts button_style

while true
  new_file_hash = compute_file_hash(filepath)
  if new_file_hash != file_hash
    begin
      new_button_style = Style(Button::Properties).from_file(filepath)
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

