class Singleton
  @@instance : String?
  @@created = false

  def self.create : String
    if created = @@created
      raise "Unable to create second instance of Singleton"
    else
      @@created = true
      "Hello World"
    end
  end

  def self.instance : String
    @@instance ||= create
  end
end

p Singleton.instance
p Singleton.instance
p Singleton.create