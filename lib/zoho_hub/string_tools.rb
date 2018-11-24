module ZohoHub
  class StringTools
    def self.demodulize(text)
      text.split('::').last
    end

    def self.pluralize(text)
      "#{text}s"
    end
  end
end
