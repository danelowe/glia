module Glia
  class UpdateRegistry
    class << self
      def area(code, &blk)
        #@todo UpdateRegistry can load update_data from cache and instantiate new UpdateBuilder directly with cached data.
        @updates ||= {}
        update = @updates[code] ||= UpdateBuilder.new

        if block_given?
          update.instance_eval(&blk)
        end

        update
      end
    end
  end
end