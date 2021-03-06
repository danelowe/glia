require 'test_helper'
class Glia::UpdateBuilder::Test < UnitTest

  def setup
    super
    @builder = Glia::UpdateBuilder.new
  end

  def test_cell
    @builder.handle :update_me do
      cell name: :update_me, class: :template, template_name: 'update_me'
    end
    @builder.handle :test do
      update handle: :update_me
      reference name: :update_me, template_name: 'updated'
      reference name: :defined_later do
        cell name: :defined_later_sub_cell, class: :template, position: :here
      end
      cell name: :root, class: :html, template_name: 'root' do
        action name: :compile, args: ['javascript', 'css']
        cell name: :header, class: :template, template_name: 'header'
      end
    end
    @builder.handle :test, :other_handle do
      cell name: :defined_later, class: :list
    end
    expected_output = {
        update_me: {
            update_me: {children: {}, class: :template, template_name: 'update_me'}
        },
        test: {
            update_me: {children: {}, class: :template, template_name: 'updated'},
            root: {class: :html, template_name: 'root',
                   children: {header: :header}, actions: [{name: :compile, args: ['javascript', 'css']}]},
            header: {class: :template, template_name: 'header', children: {}},
            defined_later: {children: {here: :defined_later_sub_cell}, class: :list},
            defined_later_sub_cell: {children: {}, class: :template}
        },
        other_handle: {
            defined_later: {children: {}, class: :list},
        }
    }
    assert_equal expected_output, @builder.to_h
    assert_raises Glia::Errors::SyntaxError do
      @builder.cell name: :header, class: :template, template_name: 'header'
    end
  end

  def test_merge
    @builder.handle :default do
      remove name: :defined_later
      cell name: :root, class: :html, template_name: 'root' do
        action name: :compile, args: ['javascript', 'css']
        cell name: :header, class: :template, template_name: 'header'
        cell name: :footer, class: :template, template_name: 'footer'
      end
    end
    @builder.handle :test do
      remove name: :header
      reference name: :footer, template_name: 'new_footer' do
        cell name: :copyright, class: :template, template_name: 'copyright', position: :footer_bottom
      end
      cell name: :defined_later, class: :list
    end
    expected_output = {
        root: {
            class: :html,
            template_name: 'root',
            children: {footer: :footer},
            actions: [{name: :compile, args: ['javascript', 'css']}]
        },
        footer: {class: :template, template_name: 'new_footer', children: {footer_bottom: :copyright}},
        copyright: {class: :template, template_name: 'copyright'}
    }
    assert_equal expected_output, @builder.merge([:default, :test])
  end

end