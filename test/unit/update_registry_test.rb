require 'test_helper'
class Glia::UpdateRegistry::Test < UnitTest

  def test_theme
    assert_equal({}, Glia::UpdateRegistry.area(:test_area).to_h) #describe messes with inheritance

    Glia::UpdateRegistry.area(:test_area, :nz) do
      handle :test do
        cell name: :root, class: :html, template_name: 'root' do
          cell name: :header, class: :template, template_name: 'header_nz'
        end
      end
    end

    Glia::UpdateRegistry.area(:test_area, :au) do
      handle :test do
        cell name: :root, class: :html, template_name: 'root' do
          cell name: :header, class: :template, template_name: 'header_au'
        end
      end
    end

    assert_equal 'header_nz', Glia::UpdateRegistry.area(:test_area, :nz).to_h[:test][:header][:template_name]
    assert_equal 'header_au', Glia::UpdateRegistry.area(:test_area, :au).to_h[:test][:header][:template_name]

  end

  def test_merge_themes
    assert_equal({}, Glia::UpdateRegistry.area(:test_area).to_h)

    Glia::UpdateRegistry.area(:test_area, :default) do
      handle :test do
        cell name: :root, class: :html, template_name: 'root' do
          cell name: :header, class: :template, template_name: 'header'
          cell name: :footer, class: :template, template_name: 'footer'
        end
      end
    end

    Glia::UpdateRegistry.area(:test_area, :au) do
      handle :test do
        cell name: :root, class: :html, template_name: 'root' do
          cell name: :header, class: :template, template_name: 'header_au'
          remove name: :footer
        end
      end
    end

    # We can't clean up the deleted/orphaned children until the handles are merged
    expected_output = {
      test: {
          root: {
              children: {header: :header, footer: :footer},
              class: :html,
              template_name: 'root'
          },
          header: {
              children: {},
              class: :template,
              template_name: 'header_au'
          },
          footer: {
              children: {},
              class: :template,
              template_name: 'footer',
              _removed: true
          }
      }
    }

    assert_equal expected_output, Glia::UpdateRegistry.merge_themes(:test_area, [:default, :au]).to_h

  end

end