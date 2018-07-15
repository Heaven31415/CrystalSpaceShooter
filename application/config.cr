require "../gui/properties.cr"

class Config
  @@properties : Properties(Config)? = nil

  def self.load(path : String)
    @@properties = Properties(Config).from_file(path)
  end

  def self.get(key : String, t : T.class) : T forall T
    if properties = @@properties
      properties[key, T]
    else
      raise "Unable to call #{self}.get on uninitialized #{self}"
    end
  end
end