require "./properties.cr"

class Label < SF::Text
  @properties : Properties(Label)

  def properties=(@properties)
    self.font = Resources.fonts.get(@properties["Font", String])
    self.string = @properties["String", String]
    self.character_size = @properties["CharacterSize", Int32]
    self.fill_color = @properties["FillColor", SF::Color]
    self.outline_color = @properties["OutlineColor", SF::Color]
    self.outline_thickness = @properties["OutlineThickness", Float32]

    # transformation
    self.origin = @properties["Origin", SF::Vector2f]
    self.scale = @properties["Scale", SF::Vector2f]
    self.position = @properties["Position", SF::Vector2f]
    self.rotation = @properties["Rotation", Float32]

    if @properties.has_key? "Style"
      apply_style
    end
  end

  def properties
    @properties
  end

  def initialize(@properties)
    super()
    self.properties = @properties
  end

  def handle_input(event : SF::Event)

  end

  private def apply_style
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

  private def center_origin
    bounds = global_bounds
    set_origin(bounds.left + bounds.width / 2.0, bounds.top + bounds.height / 2.0)
  end
end