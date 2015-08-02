module Glia
  module Errors
    class SyntaxError < StandardError
    end
    class MissingCellError < StandardError
    end
    class InvalidCellError < StandardError
    end
  end
end