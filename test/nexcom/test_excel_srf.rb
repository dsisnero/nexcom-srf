require_relative '../test_helper'
require_relative '../test_helper'
require 'nexcom/excel_srf'

describe Nexcom::ExcelSrf do

  it 'has a valid EXCEL_FILE' do
     assert(File.exist? Nexcom::ExcelSrf::EXCEL_FILE)
  end

  it 'can be created with no arg' do
    _(Nexcom::ExcelSrf.new).must_be_instance_of Nexcom::ExcelSrf
  end

  it 'can be created with a form arg' do
    excel = Nexcom::ExcelSrf.new(Nexcom::ExcelSrf::EXCEL_FILE)
    _(excel).must_be_instance_of Nexcom::ExcelSrf
  end
end


