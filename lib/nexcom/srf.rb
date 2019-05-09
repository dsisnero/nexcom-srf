require 'robust_excel_ole'

module Nexcom


  class Srf

    EXCEL_FILE = Nexcom::ROOT + 'data/srf.v1.xls'

    VERSION = '0.5'

    attr_reader :att_locations, :sheet

    def self.new_form(atts, save_as: nil)
      srf = new()
      srf.update_attributes(atts)
      name = save_as || srf_name(atts, 1)
      srf.save_as(name)
    end

    def self.get_workbook(form = nil)
      form ||= EXCEL_FILE.to_s
      RobustExcelOle::Workbook.open(form, visible: true)
    end


    def self.update_form(form, atts)
      srf = new(form)
      locid, factype, version = srf.split_file_name(form)
      srf.update_attributes(atts)
      name = srf_name({locid: locid, factype: factype}, version + 1)
      srf.save_as(name)
    end

   def initialize(form = nil)
      form ||= EXCEL_FILE.to_s
      @wb = RobustExcelOle::Workbook.open(form, visible: true)
      @sheet = @wb.sheet(1)
      @att_locations = atts_to_location
    end

    def srf_name(atts)
      [atts[:locid], atts[:factype], version, 'xls'].join('.')
    end

    def atts_to_location
      {
        project_engineer: 'I3',
        project_engineer_phone: 'AA3',
        dpn: 'AQ3',
        jcn: 'AQ5',
        locid: 'F8',
        factype: 'S8',
        city: 'E10',
        state: 'U10',
        cost_center: 'AQ8',
        ssc_gsa_address: 'AG10',
        install_date: 'AG12',
        plant_install_date: 'P12',
        jai_date: 'AQ12',
        shipping_street: 'C15',
        shipping_city_state_zip: 'C16',
        shipping_poc: 'AB15',
        shipping_poc_phone: 'AB16',
        shipping_special_instructions: 'N19',
        # labor
        labor_site_prep_govt: 'Q23',
        labor_site_prep_funded_tssc: 'AB23',
        labor_site_prep_core_tssc: 'AI23',
        labor_site_prep_floating_crew: 'AR23',
        labor_re_govt: 'Q25',
        labor_re_funded_tssc: 'AB25',
        labor_re_core_tssc: 'AI25',
        labor_re_floating_crew: 'AR25',
        labor_install_govt: 'Q27',
        labor_install_funded_tssc: 'AB27',
        labor_install_core_tssc: 'AI27',
        labor_install_floating_crew: 'AR27',
        labor_contractors: 'I29',
        # funds
        funds_siteprep_labor: 'AQ32',
        funds_re_drafting:  'AQ33',
        funds_installation:   'AQ34',
       
        # RADIOS
        receiver_vhf_qty:  'U41',
        transmitter_vhf_qty: 'U42',
        receiver_uhf_qty: 'U44',
        transmitter_uhf_qty: 'U45',
        # ANTENNAS
        antenna_vhf_qty: 'U48',
        antenna_vhf_vhf_qty: 'U49',
        antenna_uhf_qty: 'U50',
        antenna_uhf_uhf_qty: 'U51',
        antenna_uhf_vhf_qty: 'U52',
        antenna_vhf_4db_qty: 'U53',
        antenna_vhf_4db_qty: 'U54',
        # CABLES
        cable_rg214: 'U56',
        cable_lmr400uf_ft: 'U59',
        cable_7_eigth:  'U57',
        cable_1_half: 'U58',
        # Racks
        rack_rco_v2_8d_qty: 'AU41',
        rack_8rx_mc_v2_83_qty: 'AU43',
        rack_8rx_no_mc_v2_8d_qty: 'AU44',
        rack_4rtr_4_rce_v2_8d_qty: 'AU49',
        rack_4rtr_v2_8d_qty: 'AU50',
        rack_6rtr_v2_8d_qty:  'AU51',
        rack_buec_v2_8d_qty: 'AU52',
        # RCE Infor
        rce_remote_qty: 'AU67',
        rce_control_cable_qty: 'AU68',
        rce_remote_cable_qty: 'AU69',
        # Site kit
        v2_site_kit: 'AU56',
        #srf comments
        comments: 'AA82',
      }
    end

    def update_attribute(att, value)
      loc = att_locations[att]
      sheet.range(loc).Value = value
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

    def update_attributes(atts)
      atts_to_update = atts.select { |k, _v| att_locations.keys.include? k }
      atts_to_update.each do |k, v|
        update_attribute(k, v) unless v == ""
      end
    end

    def clear_form
      att_locations.each do |_k, v|
        sheet.range(v).Value = ''
      end
    end

    def save_as(file)
      @wb.save_as("#{file}")
    end

    def close
      @wb.close
    end
  end
end
