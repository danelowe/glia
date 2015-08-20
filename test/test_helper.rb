require 'glia'
require 'rubygems'
require 'bundler/setup'
require 'minitest/autorun'
require 'fixtures/view'
require 'fixtures/layout'

class UnitTest < Minitest::Test

  def setup
    Glia::UpdateRegistry.clear(:test_area)
  end

end

