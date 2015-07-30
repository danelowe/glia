require 'test_helper'
class Glia::UpdateBuilder::Test < UnitTest
  describe Glia::UpdateBuilder do
    let(:builder) { Glia::UpdateBuilder.new }

    def test_cell
      builder.handle :test do
        cell name: :root, class: :html, template_name: 'root' do
          action name: :compile, args: ['javascript', 'css']
          cell name: :header, class: :template, template_name: 'header'
        end
      end
      expected_output = {
          test: {
              root: {class: :html, template_name: 'root',
                     children: {header: :header}, actions: [{name: :compile, args: ['javascript', 'css']}]},
              header: {class: :template, template_name: 'header', children: {}}
          }
      }
      assert_equal expected_output, builder.to_h
      assert_raises Glia::Errors::SyntaxError do
        builder.cell name: :header, class: :template, template_name: 'header'
      end
    end

    def test_merge
      builder.handle :default do
        cell name: :root, class: :html, template_name: 'root' do
          action name: :compile, args: ['javascript', 'css']
          cell name: :header, class: :template, template_name: 'header'
          cell name: :footer, class: :template, template_name: 'footer'
        end
      end
      builder.handle :test do
        remove name: :header
        reference name: :footer, template_name: 'new_footer' do
          cell name: :copyright, class: :template, template_name: 'copyright', position: :footer_bottom
        end
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
      assert_equal expected_output, builder.merge([:default, :test])
    end
  end
end