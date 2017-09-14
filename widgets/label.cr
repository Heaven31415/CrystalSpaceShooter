class Label < SF::Text
  @@font : SF::Font = Game.fonts.get("calibri.ttf")
  @@minimal_size = 10

  def initialize(string : String, character_size : Int, @width : Float32)
    super(string, @@font, character_size)
    while self.character_size > @@minimal_size && global_bounds.width > @width
      self.character_size -= 1
    end
    center_origin
  end

  private def center_origin
    bounds = global_bounds
    set_origin(bounds.left + bounds.width / 2.0, bounds.top + bounds.height / 2.0)
  end
end