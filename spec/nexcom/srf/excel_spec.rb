require_relative "../../spec_helper"

describe Nexcom::ExcelSrf do
  before do
    @srf = Nexcom::ExcelSrf.new
  end

  after do
    @srf.close(if_unsaved: :forget)
  end

  it "has a valid EXCEL_FILE" do
    assert(File.exist?(Nexcom::ExcelSrf::EXCEL_FILE))
  end

  it "can be created with no arg" do
    _(@srf).must_be_instance_of Nexcom::ExcelSrf
  end

  it "can be created with a form arg" do
    excel = Nexcom::ExcelSrf.new(Nexcom::ExcelSrf::EXCEL_FILE)
    _(excel).must_be_instance_of Nexcom::ExcelSrf
  end

  it "It can update atts" do
    atts = {
      locid: "CDC",
      factype: "RTR",
      project_engineer: "Dominic Sisneros",
      jcn: "110887",
      location: "Cedar City, UT"
    }
    @srf.update_attributes(atts)
    result = JSON.parse(@srf.to_json)
    _(result["locid"]).must_equal "CDC"
    _(result["factype"]).must_equal "RTR"
    _(result["project_engineer"]).must_equal "Dominic Sisneros"
  end
end
