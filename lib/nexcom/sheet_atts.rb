module Nexcom

  
  class SheetAtts

    attr_reader :sheet, :sheet_atts, :tables

    def initialize(name_or_number, atts = {}, tables = [])
      @sheet = name_or_number
      @sheet_atts = atts
      @tables = tables
    end

    def has_key?(key)
      sheet_atts.key
    end

    def get(key)
      val = @sheet_atts.fetch(key)
      @sheet.range(val).Value
    end

    def [](key)
      get(key)
    end


    def set(key,value)
      val = sheet_atts.fetch(key)
      @sheet.range(val).Value = value
    end

    def []=(key,value)
      set(key,value)
    end

    def inspect
      "Sheet:#{sheet}}"
    end 


    def update_attributes(atts)
      atts.each do |k,v|
        set(k,v)
      end
    end

    def get_table(name)
      @sheet.ListObjects(name).Range.Value

    end

  end

end

