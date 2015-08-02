require 'test_helper'
class Glia::ViewFactory::Test < UnitTest
  describe Glia::ViewFactory do
    let(:factory) { Glia::ViewFactory.new }

    def test_find_class
      assert_equal Fixtures::View::Template, factory.find_class(:template, Fixtures::View)
      assert_equal Fixtures::View::Core::Html, factory.find_class(:'core/html', Fixtures::View)
    end

    def test_build
      cell = factory.build(
          :template,
          Fixtures::View,
          {template_name: 'my_template'},
          [{name: :add_ingredient, args: ['Eggs', '6 Large']}]
      )
      assert_instance_of Fixtures::View::Template, cell
      assert_equal 'my_template', cell.template_name
      assert_equal 'Eggs : 6 Large', cell.ingredients.first
    end

  end
end