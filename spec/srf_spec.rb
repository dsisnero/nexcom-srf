# frozen_string_literal: true

require "spec_helper"

class Nexcom::TestSrf < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Nexcom::Srf::VERSION
  end
end
