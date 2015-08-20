module Glia

  class UpdateBuilder

    def initialize(data = nil)
      @data = data||{}
    end

    def view_namespace(namespace)
      @view_namespace = namespace
      self
    end

    def handle(*keys, &blk)
      keys.each do |key|
        begin
          @current_scope = @data[key] ||= {}
          @current_cell = nil
          instance_eval &blk
        ensure
          @current_scope = nil
          @current_cell = nil
        end
      end
      self
    end

    def cell(definition, &blk)
      raise Glia::Errors::SyntaxError, 'cell must have a class' if definition[:class].nil?
      # Store the namespace here, for use when building layout.
      # We delay resolving the class, in case a block is not used, or is defined later.
      definition[:view_namespace] = @view_namespace unless @view_namespace.nil?
      _cell(definition, &blk)
    end

    def remove(definition)
      _cell(definition.merge({_removed: true}))
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
      _data = {}

      # Merge all of the handles together
      merger = proc { |key, v1, v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : v2 }
      handles.each{|h| _data = _data.merge(@data[h].clone, &merger) unless @data[h].nil?}

      #returned cleaned merged data
      _clean_handle(_data)
    end

    private

    def _clean_handle(data)
      _data = data.nil? ? {} : data.clone
      # Remove orphan references, or deleted cells
      _data = _data.delete_if{|k, v|  v.nil? || v[:class].nil? || v[:_removed]}

      # Tidy up child references for deleted children, empty child lists
      _data.each_with_object({}) do |(name, definition), hash|
        d = definition.clone
        unless d[:children].nil?
          d[:children].delete_if{|position, n| _data[n].nil?}
          d.delete(:children) if d[:children].empty?
        end
        hash[name] = d
      end
    end

    def _cell(definition, &blk)
      raise Glia::Errors::SyntaxError, 'cell cannot be used outside of handle' if @current_scope.nil?
      begin
        name = definition.delete(:name)
        position = definition.delete(:position) || name
        old_cell = @current_cell
        @current_cell = (@current_scope[name] ||= {children: {}}).merge!(definition)
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
