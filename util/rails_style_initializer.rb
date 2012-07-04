module RailsStyleInitializer

  def initialize(atts = {})
    self.attributes = atts
  end

  def attributes=(atts)
    atts.each do |attribute, value|
      send(:"#{attribute}=", value)
    end
  end

end
