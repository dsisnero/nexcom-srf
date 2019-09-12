require 'json'
module Nexcom

  class JsonSerializer

    def serialize(atts)
      atts.to_json
    end
  end
end
