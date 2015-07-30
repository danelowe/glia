module Glia

  class Layout
    attr_reader :handles, :data, :update, :cells
    singleton_class.class_eval do
      attr_accessor :layout_dir, :view_namespace
    end

    def initialize(area, handles)
      #@todo: keep a registry of updates by area in a separate singleton (UpdateRegistry) that can be stored in memory
      #@todo UpdateRegistry can load update_data from cache and instantiate new UpdateBuilder directly with cached data.
      @update = UpdateBuilder.new
      @cells = {}
      files = Dir[File.join(self.class.layout_dir, '/**/*.rb')]
      files.each{|f| @update.instance_eval(File.open(f).read, f)}
      @handles = handles
      @data = @update.merge(@handles)
    end

    def cell(name)
      if @cells[name].nil?
        definition = @data[name]
        code = definition.delete(:class)
        actions = definition.delete(:actions)
        children = definition.delete(:children)
        @cells[name] = view_factory.build(code, definition, actions)
        children.each{|p, n| @cells[name].children[p] = cell(n)} unless children.nil?
      end
      @cells[name]
    end

    def view_factory
      @view_factory ||= ViewFactory.new(self.class.view_namespace)
    end

  end

end
