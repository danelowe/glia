module Glia
  module Cell
    # To be overloaded, but here to prevent errors if we don't define initialize
    def initialize(config)
    end

    def children
      @children ||= {}
    end

    def cell(code)
      @children[code]
    end
  end
end