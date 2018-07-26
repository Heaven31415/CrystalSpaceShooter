require "crsfml/graphics"
require "./properties.cr"

# todo: rename class from XLabel to Label

#
# Label Mandatory Properties:
#
# Font              => String
# String            => String
# CharacterSize     => Int32
# FillColor         => SF::Color
# OutlineColor      => SF::Color
# OutlineThickness  => Float32
# Style             => String
#
# Layer             => Int32
#
# Origin            => SF::Vector2f | String
# Scale             => SF::Vector2f
# Position          => SF::Vector2f
# Rotation          => Float32
#

class XLabel < SF::Text
  getter layer : Int32
  @origin : Property

  def font=(font : SF::Font)
    super
    self.origin = update_origin(@origin)
  end

  def string=(string : String)
    super
    self.origin = update_origin(@origin)
  end

  def character_size=(size : Int32)
    super
    self.origin = update_origin(@origin)
  end

  def style=(style : SF::Text::Style)
    super
    self.origin = update_origin(@origin)
  end

  def initialize(properties : Properties(Label))
    @layer = properties["Layer", Int32]
    @origin = properties["Origin"]

    super()
    self.font = App.resources[properties["Font", String], SF::Font]
    self.string = properties["String", String]
    self.character_size = properties["CharacterSize", Int32]
    self.fill_color = properties["FillColor", SF::Color]
    self.outline_color = properties["OutlineColor", SF::Color]
    self.outline_thickness = properties["OutlineThickness", Float32]
    self.style = update_style(properties["Style", String])

    # Transformation
    self.origin = update_origin(@origin)
    self.scale = properties["Scale", SF::Vector2f]
    self.position = properties["Position", SF::Vector2f]
    self.rotation = properties["Rotation", Float32]
  end

  def reinitialize(properties : Properties(Label))
    self.initialize(properties)
  end

  def handle_input(event : SF::Event)
  end

  private def update_origin(origin) : SF::Vector2f
    case origin
    when String
      case origin
      when "Center"
        bounds = local_bounds()
        SF.vector2f(bounds.left + bounds.width / 2f32, bounds.top + bounds.height / 2f32)
      else
        raise "Invalid origin value: `#{origin}`"
      end
    when SF::Vector2f
      origin
    else
      raise "Invalid origin type: `#{origin.class}`"
    end
  end

  private def update_style(style : String) : SF::Text::Style
    value = 0

    style.split('|').uniq!.each do |s|
      if member = SF::Text::Style.parse?(s)
        value += member.value
      end
    end
    
    SF::Text::Style.new(value) 
  end
end