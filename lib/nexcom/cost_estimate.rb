require 'robust_excel_ole'
require 'date'
require_relative 'json_serializer'

require_relative 'sheet_atts'
require_relative 'excel_table'
require_relative 'tables'

module ExcelAccessor


  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods

    attr_reader :attributes
    def excel_att(name, loc, sheet: 1)
      instance_variable_set("@sheet_#{sheet}_attributes", []) unless instance_variable_defined? "@sheet_#{sheet}_attributes"

      attr_reader :"sheet_#{sheet}_attributes"

      sheet_atts = instance_variable_get("@sheet_#{sheet}_attributes")
      sheet_atts << name

      
      @attributes ||= []
      @attributes << name

      define_method name do 
        wb.sheet(sheet).range(loc).Value
      end

      define_method("#{name}=") do |val|
        wb.sheet(sheet).range(loc).Value = val
      end

    end

    def excel_atts(sheet: 1, atts: {})
      instance_variable_set("@sheet_1")
      atts.each do |k,v|
        excel_att(k,v, sheet: sheet)
      end
    end

  end

end

module Nexcom


 
  ROOT = File.join(__dir__ ,'../../')


  class CostEstimate

    #  include ExcelAccessor
    
    EXCEL_FILE = Nexcom::ROOT + 'data/Cost.Estimate.xlsm'

    VERSION = '0.5'

    SHEET1 =  {
      title: 'B10',
      jcn: 'B11',
      location: 'B12',
      associated_facilities: 'B13',
      project_engineer: 'B14',
      estimate_date: 'B15' ,
      estimate_type: 'B16',
      locid: 'B17',
      factype: 'B18',
      baseline_budget: 'B22',
      labor_total: 'B28',
      travel_total: 'B32',
      pa_request_total: 'B38',
      po_material_total: 'B42',
    }

    SHEET2 =  {
      elect_eng1: 'D6',
      civ_eng1: 'D4',
    }

    
    SHEET5 = {
      # RADIOS
      transmitter_vhf_qty: 'B4',
      transmitter_uhf_qty: 'B5',
      transmitter_uhf_high_power: 'B6',
      receiver_vhf_qty:  'B7',
      receiver_uhf_qty: 'B8',
      # Racks
      rack_rcag_v2_8d_qty: 'B15',
      rack_rco_v2_8d_qty: 'B16',
      rack_8rx_mc_v2_83_qty: 'B17',
      rack_8rx_no_mc_v2_8d_qty: 'B18',
      rack_16rx_mc_v2_8d_qty: 'B19',
      rack_16rx_no_mc_v2_8d_qty: 'B20',
      rack_rt_shared_ant_v2_8d_qty: 'B21',
      rack_rt_single_ant_v2_8d_qty: 'B22',
      rack_4rtr_4_rce_v2_8d_qty: 'B23',
      rack_4rtr_v2_8d_qty: 'B24',
      rack_6rtr_v2_8d_qty:  'B25',
      rack_buec_v2_8d_qty: 'B26',
      rack_bare_83x25: 'B27',
      rack_bare_83x22: 'B28',
      # ANTENNAS
      antenna_vhf_qty: 'B29',
      antenna_uhf_qty: 'B30',
      antenna_vhf_vhf_qty: 'B31',
      antenna_uhf_vhf_qty: 'B32',
      antenna_uhf_uhf_qty: 'B33',
      antenna_vhf_4db_qty: 'B34',
      antenna_uhf_4db_qty: 'B35',
      # CABLES
      cable_rg214: 'B36',
      cable_lmr400uf_ft: 'B37',
      cable_7_eigth:  'B38',
      cable_1_half: 'B39',
      # Connectors
      conn_7_8_male_straight: 'B40',
      conn_7_8_female_straight: 'B41',
      conn_7_8_female_n_type: 'B42',
      conn_7_8_male_andrews: 'B43',
      conn_1_2_male_straight: 'B44',
      conn_1_2_female_right_angle: 'B45',
      conn_1_2_female_straight: 'B46',
      conn_lmr_400uf_straight: 'B47',
      conn_lmr_400uf_right_angle: 'B48',
      conn_lmr_400uf_female_straight: 'B49',
      # RCEa aInfor
      rce_remote_qty: 'B50',
      rce_control_qty: 'B51',
      rce_control_cable_qty: 'B52',
      rce_remote_cable_qty: 'B53',
      # Site kit
      v2_site_kit: 'B54',
      v2_allignment_test_fixture: 'B55',
    }
    
    def self.with_form(form=nil, serializer: nil)
      form = new(form, serializer: serializer)
      begin
        yield form
      rescue StandardError => e
        raise e
      ensure
        form.close
      end
    end

    def self.estimate_name(atts, version: 1)
      locid = atts.fetch(:locid){'LOCID'}
      factype = atts.fetch(:factype){'FACTYPE'}
      [locid, factype, 'cost', 'estimate', "v#{version}", 'xlsm'].join('.')
    end

    
    def self.new_from_srf_data(srf_json, save_as: nil)
      file = File.read(srf_json)
      atts = JSON.parse(file).transform_keys{ |k| k.to_sym }
      new_from_atts(atts, save_as: save_as)
    end

    def self.new_from_atts(atts, save_as: nil)
      save_as ||= estimate_name(atts)
      with_form() do |estimate| 
        estimate.update_attributes(atts)
        estimate.save_as(save_as)
      end
    end

    def self.get_workbook(form = nil)
      form ||= EXCEL_FILE.to_s
      RobustExcelOle::Workbook.open(form, visible: true)
    end

    def self.update_form(form, atts)
      estimate = new(form)
      locid, factype, version = estimate.split_file_name(form)
      estimate.update_attributes(atts)
      name = estimate_name({locid: locid, factype: factype}, version + 1)
      estimate.save_as(name)
    end

    attr_reader :wb, :serializer, :version, :attributes, :sheets

    def initialize(form = nil, serializer: default_serializer)
      form ||= CostEstimate::EXCEL_FILE.to_s
      @wb = RobustExcelOle::Workbook.open(form, visible: false,if_obstructed: :forget,if_unsaved: :forget)
      @wb.excel.ScreenUpdating = false
      @sheets = {}
      @attributes = {}

      @wb.CheckCompatibility = false
      
      @fill_date = Date.today
      @version = 1
      @serializer = serializer
      add_sheet(1, SHEET1)
      add_sheet(2, SHEET2)
      add_sheet(5, SHEET5)
    end

    def add_sheet(name_or_number, atts)
      sheet = wb.sheet(name_or_number)
      @sheets[name_or_number] = SheetAtts.new(sheet, atts)
      atts.keys.each{ |k| attributes[k] = name_or_number } 
      sheet
    end

    def default_serializer
      JsonSerializer.new
    end


    def to_h
      self.class.attributes.each_with_object({}) do |att,h|

        h[att] = send(att)
      end
    end

    def split_file_name(name)
      name_re = /(\w{3,4})\.(\w{3,})\.v(\d{1,2})\.xls/
      md = name_re.match(name)
      if md 
        [md[1], md[2], md[3]]
      else
        nil
      end
    end

    def [](att, val)
      update_attribute(att, val)
    end

    def update_from_project(project)
      locid = project.locid
      factype = project.factype
      dpn = project.dpn
      project_engineer = project.project_engineer.name
      title = "NEXCOM RADIO REPLACEMENT #{{}}"

    end

    def update_attributes(atts)
      locid = atts[:locid]
      factype = atts[:factype]
      lid_fac = [locid, factype].compact.join(" ")
      atts[:title] ||= "NEXCOM RADIO REPLACEMENT #{locid} #{factype}"
      atts[:location] = location_from_atts(atts)
      atts_to_update = Hash.new{ |h,k| h[k] = {}}
      atts.each_with_object(atts_to_update) do | (k,v), h|
        val = attributes[k]
        h[val][k] = v if val
      end
      atts_to_update.each do |sheet, atts2|
        sheets[sheet].update_attributes(atts2)
      end
    end

    def location_from_atts(atts)
      atts.fetch(:location){ [atts[:city], atts[:state]].join(" ,")}
    end

    def update_header(lid,factype)
      left_footer = "Preliminary Cost Estimate\nProgram - #{lid.upcase} #{factype.upcase}"
      wb.each do |sheet|
        sheet.PageSetup.LeftFooter = left_footer
      end
    end

    def tables
      @tables = Tables.new(get_tables)
    end

    
    def serialize(name= nil)
      atts = to_h
      name ||= form_data_name(atts)
      File.open(name,'w') do |f|
        f.write serializer.serialize(atts)
      end
    end

    def each_sheet
      wb.each{ |s| yield s }
    end

   

    def save_as(file)
      wb.save_as("#{file}")
    end

    def close
      @wb.close(if_unsaved: :forget)
    end

    private

    def get_tables
      tables = []
      each_sheet do |ws|
        get_tables_for_sheet(ws) do |t|
          if block_given?
            yield t
          else
            tables << t
          end
        end
      end
      tables
    end

    def get_tables_for_sheet(sheet)
      tables = []
      tbls = sheet.ListObjects
      tbls.each do|otable|
        t = ExcelTable.new(otable)
        if block_given?
          yield t
        else
          tables << t
        end
      end
      tables unless block_given?
    end

  end
end

  if $0 == __FILE__
    estimate = Nexcom::CostEstimate.new 
    atts = { locid: 'CDC',
             factype: 'RTR',
             project_engineer: 'Dominic Sisneros',
             jcn: '110887',
             location: 'Cedar City, UT'
           }
    #estimate = Nexcom::CostEstimate.new_from_atts(atts)
    estimate = Nexcom::CostEstimate.new
  #  estimate.update_attributes(atts)
    tables = estimate.tables
    material = tables['electronic']
    puts material.data
    estimate.close
  end
