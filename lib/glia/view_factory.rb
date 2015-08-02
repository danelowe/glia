module Glia
  class ViewFactory
    def initialize(namespace)
      @namespace = namespace  || Object
    end

    def build(code, definition = {}, actions = [])
      object = find_class(code).new(definition)
      actions.each do |action|
        object.send(action[:name], *action[:args])
      end unless actions.nil?
      object
    end

    def find_class(code)
      if code.is_a? Symbol
        parts = code.to_s.split('/').map{ |str| str.split('_').map {|w| w.capitalize}.join }
        parts.inject(@namespace){|namespace, part| namespace.const_get(part)}
      elsif code.is_a? String
        @namespace.const_get(code)
      else
        code
      end
    end
  end
end