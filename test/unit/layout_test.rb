require 'test_helper'
class Glia::Layout::Test < UnitTest

  def setup
    super
    @layout = Glia.layout(:frontend, [:default, :cake_view, :pavlova_view], theme_inheritance: [:default, :au])
  end


  def test_update
    assert_equal :'core/html', @layout.update.to_h[:default][:root][:class]
  end

  def test_data
    assert_equal :'core/html', @layout.data[:root][:class]
    assert_nil @layout.data[:non_existent]
    assert_equal [:default, :au], @layout.themes
  end

  def test_cell
    root = @layout.cell(:root)
    assert_instance_of Fixtures::View::Core::Html, root
    assert_equal 'root', root.template_name
    assert_operator root.children.count, :>=, 1
    assert_equal [:default, :au], root.themes
    child = root.cell(:content)
    assert_equal @layout.cell(:details), child
    assert_instance_of Fixtures::View::Template, child
    assert_equal 'cake_details', child.template_name
    assert_equal [:default, :au], child.themes
    ingredients = @layout.cell(:cake_ingredients)
    assert_instance_of Fixtures::View::Template, ingredients
    assert_equal 'cake/pavlova_ingredients', ingredients.template_name
    assert_equal [:default, :au], ingredients.themes
  end

end