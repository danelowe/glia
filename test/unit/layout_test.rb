require 'test_helper'
class Glia::Layout::Test < UnitTest
  describe Glia::Layout do

    Glia::Layout.layout_dir = File.join(Dir.pwd, 'test', 'fixtures', 'layout')
    Glia::Layout.view_namespace = Fixtures::View
    let(:layout){ Glia::Layout.new(:frontend, [:default, :cake_view, :pavlova_view]) }

    def test_update
      assert_equal :'core/html', layout.update.to_h[:default][:root][:class]
    end

    def test_data
      assert_equal :'core/html', layout.data[:root][:class]
    end

    def test_cell
      root = layout.cell(:root)
      assert_instance_of Fixtures::View::Core::Html, root
      assert_equal 'root', root.template_name
      assert_operator root.children.count, :>=, 1
      child = root.cell(:content)
      assert_equal layout.cell(:details), child
      assert_instance_of Fixtures::View::Template, child
      assert_equal 'cake_details', child.template_name
      ingredients = layout.cell(:cake_ingredients)
      assert_instance_of Fixtures::View::Template, ingredients
      assert_equal 'cake/pavlova_ingredients', ingredients.template_name
    end
  end
end