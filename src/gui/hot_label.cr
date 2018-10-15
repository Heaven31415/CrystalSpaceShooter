require "./properties"

class Label < SF::Text
  @properties : Properties(Label)
  @layer = 0

  def properties=(@properties)
    self.font = App.resources[@properties["Font", String], SF::Font]
    self.string = @properties["String", String]
    self.character_size = @properties["CharacterSize", Int32]
    self.fill_color = @properties["FillColor", SF::Color]
    self.outline_color = @properties["OutlineColor", SF::Color]
    self.outline_thickness = @properties["OutlineThickness", Float32]

    apply_style

    # transformation
    apply_origin
    self.scale = @properties["Scale", SF::Vector2f]
    self.position = @properties["Position", SF::Vector2f]
    self.rotation = @properties["Rotation", Float32]

    apply_layer
  end

  def properties
    @properties
  end

  def layer
    @layer
  end

  def initialize(@properties)
    super()
    self.properties = @properties
  end

  def handle_input(event : SF::Event)

  end

  private def apply_style
    unless @properties.has_key? "Style"
      self.style = SF::Text::Style::Regular
      return
    end

    value = 0
    styles = @properties["Style", String].split('|').uniq!
    styles.each do |style|
      member = SF::Text::Style.parse?(style)
      if member
        value += member.value
      end
    end
    
    self.style = SF::Text::Style.new(value) 
  end

  private def apply_origin
    unless @properties.has_key? "Origin" 
      self.center_origin
    end

    value = @properties["Origin"]

    case value
    when String
      case value
      when "Center"
        center_origin
      else
        center_origin
      end
    when SF::Vector2f
      self.origin = value
    end
  end

  private def center_origin
    bounds = local_bounds
    self.origin = {bounds.left + bounds.width / 2.0, bounds.top + bounds.height / 2.0}
  end

  private def apply_layer
    unless @properties.has_key? "Layer" 
      @layer = 0
    end

    @layer = @properties["Layer", Int32]    
  end
end