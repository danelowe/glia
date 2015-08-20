Glia.area(:frontend) do
  view_namespace Fixtures::View

  handle :default do
    cell name: :root, class: :'core/html', template_name: 'root', missing_accessor: 'ignore_me' do
      cell name: :header, class: :template, template_name: 'header'
    end
  end

  handle :cake_view do
    reference name: :root do
      cell name: :details, class: Fixtures::View::Template, template_name: 'cake_details', position: :content do
        cell name: :specifications, class: :list do
          cell name: :cake_specs, class: 'Fixtures::View::Template', template_name: 'cake/specs'
          cell name: :cake_ingredients, class: 'Template', template_name: 'cake/ingredients'
        end
      end
    end
    reference name: :non_existent, template: 'missing' do
      cell name: :non_existent_child, class: :template
    end
  end

  handle :pavlova_view do
    reference name: :specifications do
      remove name: :cake_specs
    end
    reference name: :cake_ingredients, template_name: 'cake/pavlova_ingredients' do
      action name: :add_ingredient, args: ['Eggs', '6 Large']
    end
  end

end

Glia.area(:test_area) do
  handle :test do
    cell name: :test, class: :template, comment: 'This area should be cleared between each test, so not in tests'
  end
end
