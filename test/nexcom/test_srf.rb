gem "minitest"
require "minitest/autorun"
require "nexcom-srf"

class TestSrf < Minitest::Test
  def test_initialize
    srf = ::Nexcom::Srf.new
    srf.clear_form
    srf.save_as('test.xls')
    srf.close
  end
  
end
