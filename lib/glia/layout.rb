module Glia

  class Layout
    attr_writer :view_factory
    attr_reader :handles, :data, :update, :cells, :themes

    singleton_class.class_eval do
      attr_accessor :layout_dir, :view_namespace
    end

    def initialize(area, handles, options = {})
      @area = area
      @themes = options[:theme_inheritance] || [:default]
      @update = UpdateRegistry.merge_themes(area, )
      @cells = {}
      @handles = handles
      @data = @update.merge(@handles)
      @view_factory = options[:view_factory] unless options[:view_factory].nil?
      if options[:eager_load]
        @data.keys.each { |name| cell(name) }
      end
    end

    def cell(name, *args)
      if @cells[name].nil?
        definition = @data[name]
        raise Errors::MissingCellError, "Cell #{name} is missing from layout #{@area}" if definition.nil?
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
        @cells[name].load if @cells[name].respond_to?(:load)
      end
      @cells[name]
    end

    def view_factory
      @view_factory ||= ViewFactory.new
    end

  end

end
