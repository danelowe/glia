handle :default do
  cell name: :root, class: :'core/html', template_name: 'root', missing_accessor: 'ignore_me' do
    cell name: :header, class: :template, template_name: 'header'
  end
end
handle :cake_view do
  reference name: :root do
    cell name: :details, class: :template, template_name: 'cake_details', position: :content do
      cell name: :specifications, class: :list do
        cell name: :cake_specs, class: :template, template_name: 'cake/specs'
        cell name: :cake_ingredients, class: :template, template_name: 'cake/ingredients'
      end
    end
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

