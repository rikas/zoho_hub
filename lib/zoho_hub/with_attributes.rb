module ZohoHub
  # Allows adding attributes to a class, as <tt>attr_accessors</tt> that can then be listed from the class
  # or an instance of that class.
  #
  # === Example
  #
  #   class User
  #     include ZohoHub::WithAttributes
  #
  #     attributes :first_name, :last_name, :email
  #   end
  #
  #   User.attributes # => [:first_name, :last_name, :email]
  #   User.new.attributes # => [:first_name, :last_name, :email]
  #
  #   user = User.new
  #   user.first_name = 'Ricardo'
  #   user.last_name = 'Otero'
  #   user.first_name # => "Ricardo"
  module WithAttributes
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def attributes(*attributes)
        @attributes ||= []

        return @attributes unless attributes

        attr_accessor(*attributes)

        @attributes += attributes
      end

      def attribute_translation(translation = nil)
        @attribute_translation ||= {}

        return @attribute_translation unless translation

        @attribute_translation = translation
      end

      def zoho_key_translation
        @attribute_translation.to_a.map(&:rotate).to_h
      end
    end

    # Returns the list of attributes defined for the instance class.
    def attributes
      self.class.attributes
    end

    private

    def attr_to_zoho_key(attr_name)
      translations = self.class.attribute_translation

      return translations[attr_name.to_sym] if translations.key?(attr_name.to_sym)

      attr_name.to_s.split('_').map(&:capitalize).join('_').to_sym
    end

    def zoho_key_to_attr(zoho_key)
      translations = self.class.zoho_key_translation

      return translations[zoho_key.to_sym] if translations.key?(zoho_key.to_sym)

      zoho_key.to_sym
    end
  end
end
