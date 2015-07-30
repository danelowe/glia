module Fixtures
  module View
    class Template
      include Glia::Cell
      attr_reader :template_name, :ingredients

      def initialize(config)
        @template_name = config[:template_name]
        @ingredients = []
      end

      def add_ingredient(name, qty)
        @ingredients << "#{name} : #{qty}"
      end
    end
  end
end