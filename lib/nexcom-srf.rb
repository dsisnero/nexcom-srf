require "dry/core/constants"
require "pathname"
require "nexcom/srf/version"

module Nexcom
  ROOT = Pathname(__dir__).parent
  include Dry::Core::Constants
end
require "nexcom/srf/excel"
