module Glia

  class UpdateBuilder

    def initialize
      @data = {}
    end

    def handle(key, &blk)
      begin
        @current_scope = @data[key] ||= {}
        @current_cell = nil
        instance_eval &blk
      ensure
        @current_scope = nil
        @current_cell = nil
      end
    end

    def cell(definition, &blk)
      raise Glia::Errors::SyntaxError, 'cell must have a class' if definition[:class].nil?
      _cell(definition, &blk)
    end

    def remove(definition)
      @current_scope[definition.delete(:name)] = nil
    end

    def reference(definition, &blk)
      raise Glia::Errors::SyntaxError, 'Reference cannot have a class' unless definition[:class].nil?
      _cell(definition, &blk)
    end

    def action(definition)
      raise Glia::Errors::SyntaxError, 'Action cannot be used outside of cell' if @current_cell.nil?
      @current_cell[:actions] ||= []
      @current_cell[:actions] << definition
    end

    def to_h
      @data
    end

    def merge(handles)
      data = {}
      merger = proc { |key, v1, v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : v2 }
      handles.each{|h| data.merge!(@data[h], &merger)}
      data.delete_if{|k, v|  v.nil?}.each_with_object({}) do |(name, definition), hash|
        definition[:children] = definition[:children].delete_if{|position, n| data[n].nil?}
        definition.delete(:children) if definition[:children].empty?
        hash[name] = definition
      end
    end

    private

    def _cell(definition, &blk)
      raise Glia::Errors::SyntaxError, 'cell cannot be used outside of handle' if @current_scope.nil?
      begin
        name = definition.delete(:name)
        position = definition.delete(:position) || name
        old_cell = @current_cell
        @current_cell = @current_scope[name] = {children: {}}.merge(definition)
        unless old_cell.nil?
          old_cell[:children][position] = name
        end
        instance_eval &blk unless blk.nil?
      ensure
        @current_cell = old_cell
      end
    end

  end

end
