module Glia
  module Cell
    attr_accessor :child_definitions, :layout, :blocks

    # To be overloaded, but here to prevent errors if we don't define initialize
    # def initialize(config)
    # end

    def children
      @children ||= {}
      child_definitions.keys.each{|p| @children[p] ||= cell(p)} unless child_definitions.nil?
      @children
    end

    def cell(code, *args)
      @children ||= {}
      name = child_definitions[code]
      raise Errors::MissingCellError, "No child cell in position #{code}" if name.nil?
      @children[code] ||= layout.cell(name, *args)
    end

    def child_definitions
      @child_definitions ||= {}
    end

    def blocks
      @blocks ||= []
    end

    def themes
      layout.themes
    end
  end
end