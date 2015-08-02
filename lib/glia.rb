require "glia/version"
require "glia/cell"
require "glia/errors"
require "glia/layout"
require "glia/update_builder"
require "glia/update_registry"
require "glia/view_factory"

module Glia
  # Your code goes here...
  def self.area(code, &blk)
    UpdateRegistry.area(code, &blk)
  end

  def self.layout(area, handles)
    Layout.new(area, handles)
  end
end
