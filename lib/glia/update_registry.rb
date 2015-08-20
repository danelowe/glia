module Glia
  class UpdateRegistry
    class << self
      def area(area_code, theme = :default, &blk)
        #@todo UpdateRegistry can load update_data from cache and instantiate new UpdateBuilder directly with cached data.
        @updates ||= {}
        @updates[area_code] ||= {}
        update = @updates[area_code][theme] ||= UpdateBuilder.new
        if block_given?
          update.instance_eval(&blk)
        end

        update
      end

      def merge_themes(area_code, theme_inheritance = nil)
        theme_inheritance ||= [:default]
        merger = proc { |key, v1, v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : v2 }
        data = theme_inheritance.each_with_object({}) do |theme, data|
          data.merge!(area(area_code, theme).to_h, &merger)
        end
        UpdateBuilder.new(data)
      end

      def clear(area_code = nil)
        if area_code.nil?
          @updates = {}
        else
          @updates.delete(area_code)
        end
        self
      end
    end
  end
end