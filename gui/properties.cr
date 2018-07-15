require "crsfml/graphics"
require "openssl/sha1.cr"

alias Property = Bool | Float32 | SF::Color | SF::Vector2f | SF::Vector2i | String | Int32

class Properties(T)
  LINE_FORMAT_REGEX = /^([a-zA-Z0-9]+)\s?=\s?(.+)$/
  COLOR_REGEX = /^rgba\((.{1,3})\,\s(.{1,3})\,\s(.{1,3})\,\s(.{1,3})\)$/
  VECTOR_REGEX = /^xy\((.+)\,\s(.+)\)$/
  STRING_REGEX = /^\"(.*)\"$/
  BOOL_REGEX = /^(false|true)$/

  def initialize
    @properties = {} of String => Property
  end

  def []=(key : String, value : Property)
    @properties[key] = value
  end

  def [](key : String, t : T.class) : T forall T
    unless @properties.has_key? key
      raise "Unable to find property: `#{key}`"
    end
    @properties[key].as(T)
  end

  def [](key : String) : Property
    unless @properties.has_key? key
      raise "Unable to find property: `#{key}`"
    end
    @properties[key]
  end

  def has_key?(key : String) : Bool
    @properties.has_key? key
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
    unless header.match(/^###\s?+#{T.name}$/)
      raise "Unable to find `#{T.name}` header in file: `#{filename}`"
    end
    
    lines.shift # remove header line
    style = Properties(T).new

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
      elsif matches = property_value.match(VECTOR_REGEX) # xy(float32 | int32, float32 | int32)
        x_i32 = matches[1].to_i32?
        y_i32 = matches[2].to_i32?

        x_f32 = matches[1].to_f32?
        y_f32 = matches[2].to_f32?

        if x_i32 && y_i32
          style[property_name] = SF::Vector2i.new(x_i32, y_i32)
        elsif x_f32 && y_f32
          style[property_name] = SF::Vector2f.new(x_f32, y_f32)
        elsif (!x_i32 && !x_f32) && (!y_i32 && !y_f32)
          raise "Invalid vector2 `x` and `y` value in file `#{filename}` at line #{line[:number]}"
        elsif !x_i32 && !x_f32
          raise "Invalid vector2 `x` value in file `#{filename}` at line #{line[:number]}"
        elsif !y_i32 && !y_f32
          raise "Invalid vector2 `y` value in file `#{filename}` at line #{line[:number]}"
        end
      elsif matches = property_value.match(STRING_REGEX) # "string"
        str = matches[1]
        style[property_name] = str
      elsif matches = property_value.match(BOOL_REGEX) # bool
        if matches[1] == "false"
          style[property_name] = false
        else
          style[property_name] = true
        end
      elsif value = property_value.to_i32? # int32
        style[property_name] = value
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
