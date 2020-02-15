module Nexcom

  class ExcelTable

    attr_reader :table

    def initialize(table)
      @table = table
    end

    def name
      @table.Name
    end

    def header
      table.HeaderRowRange.Value[0]
    end

    def header_interned
      header.map{ |h| h.downcase.gsub(' ','_').intern }
    end

    def data_raw
      table.DataBodyRange.Value
    end

    def [](name)
      get_column(name)
    end

    def get_column(name)
      table.ListColumns(name).DataBodyRange.value
    end

    def data
      local_header = header_interned
      result = []
      data_raw.each do |row|
        row_hash = Hash[local_header.zip(row)]

        if block_given?
          yield row_hash
        else
          result << row_hash
        end
      end
      result unless block_given?
    end

    def to_s
      name
    end


    def inspect
      "ExcelTable-#{name}"
    end


  end

end

