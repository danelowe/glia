module Glia

  class Layout
    attr_writer :view_factory
    attr_reader :handles, :data, :update, :cells
    singleton_class.class_eval do
      attr_accessor :layout_dir, :view_namespace
    end

    def initialize(area, handles)
      @update = UpdateRegistry.area(area)
      @cells = {}
      @handles = handles
      @data = @update.merge(@handles)
    end

    def cell(name, *args)
      if @cells[name].nil?
        definition = @data[name]
        raise Errors::MissingCellError, "Cell #{name} is missing from layout" if definition.nil?
        code = definition.delete(:class)
        actions = definition.delete(:actions)
        children = definition.delete(:children)
        namespace = definition.delete(:view_namespace) || Object
        @cells[name] = view_factory.build(code, namespace, definition, actions, *args)
        unless @cells[name].respond_to?(:child_definitions=)
          raise Errors::InvalidCellError, @cells[name].class.name+' is not a valid cell. Include Glia::Cell.'
        end
        @cells[name].child_definitions = children
        @cells[name].layout = self
      end
      @cells[name]
    end

    def view_factory
      @view_factory ||= ViewFactory.new
    end

  end

end
