require "concurrent/map"


module Nexcom
  class Tables
    attr_reader :tables

    def initialize(tables = EMPTY_ARRAY)
      initialize_elements(tables)
    end

    def [](name)
      table = tables[name]
      return table if table
      matcher = Regexp.new(Regexp.escape(name), "i")
      @tables.each do |k, v|
        return v if k&.match?(matcher)
      end
    end

    def keys
      tables.keys
    end

    def names
      keys
    end

    def key?(name)
      keys.include?(name)
    end

    def each(&)
      @tables.values.each(&)
    end

    private

    def initialize_elements(elements)
      @tables = elements.each_with_object(Concurrent::Map.new) { |s, m|
        m[s.name] = s
      }
    end
  end
end
