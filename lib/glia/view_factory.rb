module Glia
  class ViewFactory

    def build(code, view_namespace = Object, definition = {}, actions = [], *args)
      object = instantiate(find_class(code, view_namespace), definition, *args)
      apply_actions(object, actions)
      object
    end

    def instantiate(klass, definition, *args)
      klass.new(*(args|[definition]))
    end

    def apply_actions(object, actions)
      actions.each do |action|
        object.send(action[:name], *action[:args])
      end unless actions.nil?
    end

    def find_class(code, view_namespace = Object)
      if code.is_a? Symbol
        parts = code.to_s.split('/').map{ |str| str.split('_').map {|w| w.capitalize}.join }
        parts.inject(view_namespace){|namespace, part| namespace.const_get(part)}
      elsif code.is_a? String
        view_namespace.const_get(code)
      else
        code
      end
    end

  end
end