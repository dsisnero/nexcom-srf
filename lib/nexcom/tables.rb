require 'concurrent/map'


module Nexcom
  class Tables

    attr_reader :tables

    def initialize(tables=EMPTY_ARRAY)
      initialize_elements(tables)
    end

    def [](name)
      table = tables[name]
      return table if table
      matcher = Regexp.new(Regexp.escape(name), 'i')
      table = @tables.each do |k,v|
        return v if k =~ matcher
        nil
      end
      
      return table if table
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

    def each(&block)
      @tables.values.each(&block)
    end

    private

    def initialize_elements(elements)
      @tables = elements.each_with_object(Concurrent::Map.new){ |s,m|
        m[s.name] = s
      }
    end


  end
end
