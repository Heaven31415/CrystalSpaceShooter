require "./gui/properties.cr"

class Config
  @@instance : Properties(Config)?

  def self.create(path : String) : Properties(Config)
    properties = Properties(Config).from_file(path)
  end

  def self.instance : Properties(Config)
    @@instance ||= create("app.config")
  end
end