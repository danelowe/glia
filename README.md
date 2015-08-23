# Glia

As your app grows, you may find that a lot of logic is necessary in your views. 
Implementing a proper view layer, such as [Cells](https://github.com/apotonick/cells), 
will help to reduce complexity by encapsulating this logic into classes for specific parts of the page. 

But what happens when you need somewhere to manage the logic determining what cells go where and on what page?
This is where Glia comes in handy, it provides an additional `layout` layer to manage your views.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'glia'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install glia
   
## How do I?

Have a layout-related problem and want to know if/how Glia can help?

* Read through this README
* Check out the [Glia Cells Example App](https://github.com/danelowe/glia_cells_example)
* Leave any how-to questions as issues on [the example project](https://github.com/danelowe/glia_cells_example). 

If the whole concept doesn't make sense to you, maybe your app is simple enough not to need it, or maybe it would help
for you to know that Glia is heavily inspired by 
[Magento's layout system](http://devdocs.magento.com/guides/m1x/magefordev/mage-for-dev-4.html) 

## Usage

### Cells 

A Cell is a view object that renders a certain part of the page.

**Glia does not provide an implementation of cells, but expects that you have this concept as part of your project.** 

You can use a gem such as [Cells](https://github.com/apotonick/cells), to provide this interface. 

Glia provides a mixin, `Glia::Cell` that you should include in your cells to provide methods that help with things 
such as setting/getting child cells, and accessing the layout layer. 

### Layout files
Layout files are written with a DSL that is designed to help describe the layout of your pages. e.g. 

```ruby
# layout/frontend/default.rb
Glia.area(:frontend) do 
  view_namespace Fixtures::View
  handle :default do
    cell name: :root, class: :'core/html', template_name: 'root', missing_accessor: 'ignore_me' do
      cell name: :header, class: :template, template_name: 'header'
      cell name: :sidebar, class: :list do
        # ...
      end
      cell name: :footer, class: :template, template_name: 'footer'
    end
  end
  handle :cake_view do
    reference name: :root do
      cell name: :details, class: Fixtures::View::Template, template_name: 'cake_details', position: :content do
        cell name: :specifications, class: :list do
          cell name: :cake_specs, class: 'Template', template_name: 'cake/specs'
          cell name: :cake_ingredients, class: :template, template_name: 'cake/ingredients'
        end
      end
    end
  end
  handle :pavlova_view, :new_view do
    reference name: :specifications do
      remove name: :cake_specs
    end
    reference name: :cake_ingredients, template_name: 'cake/pavlova_ingredients' do
      action name: :add_ingredient, args: ['Eggs', '6 Large']
    end
  end
end
```

![Cake View](readme/layout_cake.png?raw=true)

![Pav View](readme/layout_pav.png?raw=true)

#### View Namespace (Optional)

Pass a class/module. Any cell created within this area definition using a string or symbol for `class` 
will use this namespace when getting the actual class. 

#### Handle

Handles are key tool for customising your layout per page. 
Each page in your app will have a set of handles, which consist of an array of symbols. e.g.
 
```ruby
[:default, :cake_view, :pavlova_view]
```

It is often a good idea to have the handles automatically generated from the controller, 
including a default handle, one for the controller name, and another for the controller#action name.
You can also have your controller add custom handles depending on the request, or the type of item being viewed. e.g.

```ruby
[:default, :quotes, :quotes_show, :quotes_show_AJAX, :quote_show_TYPE_PLUMBING]
```

If your project has a concept of modules (that encapsulates a feature and contains controllers), then it would also be 
a very good idea to include the module name in your handles. e.g.

```ruby
[:default, :sales_quotes, :sales_quotes_show]
```

**The order of the set of handles is important.** Glia will start at the first handle (e.g. `:default`) when building
the layout. 
Each successive handle will modify the layout generated from the previous handle. 
In the DSL example above, if our handles were `[:default, :cake_view, :pavlova_view]`, then the template_name for 
the `cake_ingredients` cell will be 'cake/pavlova_ingredients', and we won't have a `:cake_specs` cell on the page.

Using this system, we can have considerable flexibility in the layout based on the factors that we use to determine the 
handles. For example, we can add or remove menu items from a navigation cell if the customer is logged in, 
or if we are on the customer account page. We can add or remove certain cells on the page based on the type of product
that we are viewing.
 
Generating the handles for a request/action and passing them to the layout during rendering is decribed in further 
detail in the *Integration* section.

All layout methods are contained within a handle, and as such all other methods must appear inside a handle block.

#### Cell

The `cell` method places a cell inside the layout. 
The layout starts with a single cell, which by convention is named `:root`. 
All other cells on the page are descendants of the root cell, and most likely will be rendered as part of rendering the
root cell, being contained in its output.

* `name` is the name of the cell in the layout. Each cell must have its own unique name within the layout
* `class` is a code that the layout system uses to figure out what class to instantiate when building the cell.
  This can either be:
  * A String representing the class name, either fully qualified or from the view_namespace (see **Integration**) 
  * A Symbol Representing the class name from the view_namespace, separated by '/' for each sub-namespace. 
  * A Class
* `position` This is a code that should be unique within the parent cell. If omitted, will default to the same value as
  `name`. This code is used to control where the cell is rendered within the parent cell, using the `cell` 
  method. For example, the `'cake_details'` template file might have a call to `cell(:specifications).render` in a 
  specific place to render that specific child cell.
* Any other parameters passed to `cell` will be passed through to the cell's constructor.
* Anything in the block will operate on this cell. E.g. calling cell within the block will create a child cell.
  
#### Reference

The `reference` method refers to a cell that has been added in a previous (or subsequent) handle. 
Any parameter will overwrite the same parameter defined in a previous handle. 
Any contents of the block will operate on the previously defined cell.

The technical difference from the cell method is that instead of requiring the `class` parameter, it disallows it, 
and a reference without a matching cell would be ignored rather than creating a cell in the layout.

#### Action

This method will run the specified method (with the given arguments) on the cell immediately after it is initialized.
* `name` The name of the method
* `args` An array of arguments that will be passed to the method.


### Areas 

An 'area' is a distinct layout that is completely separate from another area. 
For example many apps would have a `:frontend` area, and an `:admin` area.

If you app code is organised into modules, you may wish to keep a layout file in each module. 
This way, the layout files can each place cells related to their own modules on any page of the app.

Just wrap the DSL with `Glia.area(:area_name) do .. end`, 
then make sure the layout files are required as part of your app's bootstrap process.  

```ruby
Glia.area(:frontend) do 
  handle :pavlova_view do
    reference name: :specifications do
      remove name: :cake_specs
    end
    reference name: :cake_ingredients, template_name: 'cake/pavlova_ingredients' do
      action name: :add_ingredient, args: ['Eggs', '6 Large']
    end
  end
end
```

### Integration

#### Generate the handles

The handles will be generated in the controller based on the request/loaded objects/controller. Examples to come.

#### Create a layout

Pick an 'area' to render, e.g. `:frontend` or `:admin`, and pass this into the layout method along with the handles.

````ruby
layout = Glia.layout(:frontend, [:default, :cake_view, :pavlova_view])
```

This returns an instance of Glia::Layout

### Render the layout.

Get the `:root` cell from the layout, and render it. The `render` method is provided by your view layer library/gem. 
Substitute the method name that you have. 

```ruby
layout.cell(:root).render
```

That is all. Your root cell's rendering process should be such that the child cells are picked out and rendered,
and those child cells pick out and render their child cells, and so on until the whole layout tree is rendered. 

## Suggestions

### Suggested Cell Types

* `Template` A generic cell that has a `template_name` and a data passed into its constructor in key/value pairs.
  It would render the template, using the data as locals. 
* `List` A generic cell that has no template, but instead renders all child cells 
  (DSL to control order of child cells to come soon). 
  These can be very handy for providing areas such as sidebars, where any number of cells can be added or removed 
  without having to have a `cell(:name).render` helper called for each specific child cell 
* `Html::Head` A cell with specific methods for including asset tags etc.
* Specific classes for cells that have their own logic. E.g. `Product::Price`, `Category::List` 

### Getting data to cells

Try one or more of these options:

* Pass the data as locals to each cell or child cell as you render it. 
* Create a registry (using e.g. [RequestStore](https://github.com/steveklabnik/request_store)), which the controller can
  pass data to, and the cells can read data from. 
* If more flexibility is required, the controller can pull a specific cell from the layout, and call a method on it. 

### Customise the ViewFactory

Example for Customised Lotus Views

```ruby
module Frontend
  class Application < Lotus::Application

    def renderer
      @custom_renderer ||= Client::RenderingPolicy.new(configuration)
    end

    configure do
      # ...
    end

  end
end
```

```ruby
require 'glia'
class Client::RenderingPolicy < Lotus::RenderingPolicy

  class ViewFactory < Glia::ViewFactory
    def instantiate(klass, definition, *args)
      #@todo: Allow blocks/cells to subscribe to registry values.
      locals = args[0].nil? ? definition : definition.merge(args[0])
      klass.new({format: :html}.merge(locals))
    end
  end

  def _render_action(action, response)
    @area ||= @namespace.name.downcase.to_sym
    if successful?(response)
      if response[BODY].empty?
        RequestStore.store[:action_exposures] = action.exposures
        layout = Glia.layout(@area, action.handles)
        layout.view_factory = ViewFactory.new
        layout.cell(:root, action.exposures).render
      else
        Lotus::Views::NullView.new(response[BODY]).render(action.exposures)
      end
    end
  end

end
```

## Theme Inheritance
In addition to areas, Glia provides a means to override the layouts with different 'themes'. 

For example. If your project serves multiple sites that each need a different header, you can achieve this with themes. 

```ruby
Glia::UpdateRegistry.area(:frontend, :default) do
  handle :default do
    cell name: :root, class: :html, template_name: 'root' do
      cell name: :header, class: :template, template_name: 'header'
      cell name: :footer, class: :template, template_name: 'footer'
    end
  end
end

Glia::UpdateRegistry.area(:frontend, :au) do
  handle :default do
    cell name: :root, class: :html, template_name: 'root' do
      cell name: :header, class: :template, template_name: 'header_au'
      remove name: :footer
    end
  end
end
```

When you get the layout, just specify which themes you want to merge. 

```ruby
layout = Glia.layout(:frontend, [:default, :product_view], theme_inheritance: [:default, :au])
```  

There is no limit to the number of themes you can use in the inheritance chain. 
It begins with the first theme, and applies updates from each successive theme.

## Notes
* When the DSL is parsed, the result is a simple hash of values that describes the layout. 

## Contributing

1. Fork it ( https://github.com/danelowe/glia/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
