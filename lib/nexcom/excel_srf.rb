require 'robust_excel_ole'
require 'date'
require_relative 'paths'
require_relative 'json_serializer'
require 'json'
module Nexcom

  class ExcelSrf
    
    EXCEL_FILE = Nexcom::ROOT + 'data/srf.v1.xlsx'

    VERSION = '0.7'

    attr_reader :att_locations, :att_locations_indifferent, :sheet, :serializer, :version, :wb

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


    def self.srf_name(atts, version: 1)
      locid = atts.fetch(:locid){'LOCID'}
      factype = atts.fetch(:factype){'FACTYPE'}
      [locid, factype, 'srf', "v#{version}", 'xlsm'].join('.')
    end
    
    def self.new_from_atts(atts, save_as: nil)
      with_form() do |srf|
        save_as ||= srf_name(atts)
        srf.update_attributes(atts)
        srf.save_as(save_as)
      end
    end

    def self.get_workbook(form = nil)
      form ||= EXCEL_FILE.to_s
      RobustExcelOle::Workbook.open(form, visible: true)
    end

    def self.print_data(form, output, serializer: nil)
      with_form(form, serializer: serializer) do |srf| 
        srf.serialize(output)
      end
    end

    def self.update_form(form, atts)
      srf = new(form)
      locid, factype, version = srf.split_file_name(form)
      srf.update_attributes(atts)
      name = srf_name({locid: locid, factype: factype}, version + 1)
      srf.save_as(name)
    end

    def initialize(form = nil, serializer: nil)
      form ||= EXCEL_FILE.to_s
      @wb = RobustExcelOle::Workbook.open(form, visible: true)
      @sheet = @wb.sheet(1)
      @fill_date = Date.today
      @version = 1
      @att_locations = atts_to_location
      @att_locations_indifferent = @att_locations.merge(@att_locations.transform_keys(&:to_s))
      @serializer = serializer || default_serializer
    end


    def default_attribute_values
      {labor_site_prep_govt: 'X',
       labor_re_govt: 'X',
       labor_install_floating_crew: 'X',
       comments: 'Please include V2 alignment Test Fixture',
      }
    end

    def default_serializer
      json_serializer
    end

    def json_serializer
      @json_serializer ||= JsonSerializer.new
    end


    def atts_to_location
      {
        fill_date:                      'AQ1' ,
        project_engineer:               'I3',
        project_engineer_phone:         'AA3',
        dpn:                            'AQ3',
        jcn:                            'AQ5',
        locid:                          'F8',
        factype:                        'S8',
        city:                           'E10',
        state:                          'U10',
        cost_center:                    'AQ8',
        ssc_gsa_address:                'AG10',
        start_date:                     'AG12',
        site_prep_date:                 'P12',
        jai_date:                       'AQ12',
        shipping_street:                'C15',
        shipping_city_state_zip:        'C16',
        shipping_poc:                   'AB15',
        shipping_poc_phone:             'AB16',
        shipping_special_instructions:  'N19',
        # labor
        labor_site_prep_govt:           'Q23',
        labor_site_prep_funded_tssc:    'AB23',
        labor_site_prep_core_tssc:      'AI23',
        labor_site_prep_floating_crew:  'AR23',
        labor_re_govt:                  'Q25',
        labor_re_funded_tssc:           'AB25',
        labor_re_core_tssc:             'AI25',
        labor_re_floating_crew:         'AR25',
        labor_install_govt:             'Q27',
        labor_install_funded_tssc:      'AB27',
        labor_install_core_tssc:        'AI27',
        labor_install_floating_crew:    'AR27',
        labor_contractors:              'I29',
        # funds
        funds_siteprep_labor:           'AQ32',
        funds_re_drafting:              'AQ33',
        funds_installation_labor:       'AQ34',
        funds_total_required_by_region: 'AQ35',
        funds_net_pa_cwp_request:       'AQ36',
        # RADIOS
        receiver_vhf_qty:               'U42',
        transmitter_vhf_qty:            'U43',
        transmitter_vhf_high_qty:       'U44',
        receiver_uhf_qty:               'U45',
        transmitter_uhf_qty:            'U46',
        transmitter_uhf_high_qty:       'U47',
        # ANTENNAS
        antenna_vhf_qty:                'U49',
        antenna_vhf_vhf_qty:            'U50',
        antenna_uhf_qty:                'U51',
        antenna_uhf_uhf_qty:            'U52',
        antenna_uhf_vhf_qty:            'U53',
        antenna_vhf_4db_qty:            'U54',
        antenna_uhf_4db_qty:            'U55',
        # CABLES
        cable_rg214:                    'U57',
        cable_7_eighth:                 'U58',
        cable_1_half:                   'U59',
        cable_lmr400uf_ft:              'U60',
        cable_other_type:               'I61',
        cable_other_type_ft:            'U61',
        # Connectors
        conn_7_8_male_straight:         'U74',
        conn_7_8_female_straight:       'U75',
        conn_7_8_female_n_type:         'U76',
        conn_7_8_male_andrews:          'U77',
        conn_1_2_male_straight:         'U78',
        conn_1_2_female_right_angle:    'U79',
        conn_1_2_female_straight:       'U80',
        conn_lmr_400uf_straight:        'U81',
        conn_lmr_400uf_right_angle:     'U82',
        conn_lmr_400uf_female_straight: 'U83',
        # Racks
        rack_rcag_v2_8d_qty:            'AU42',
        rack_rco_v2_8d_qty:             'AU43',
        rack_8rx_mc_v2_83_qty:          'AU44',
        rack_8rx_no_mc_v2_8d_qty:       'AU45',
        rack_16rx_mc_v2_8d_qty:         'AU46',
        rack_16rx_no_mc_v2_8d_qty:      'AU47',
        rack_rt_shared_ant_v2_8d_qty:   'AU48',
        rack_rt_single_ant_v2_8d_qty:   'AU49',
        rack_4rtr_4_rce_v2_8d_qty:      'AU50',
        rack_4rtr_v2_8d_qty:            'AU51',
        rack_6rtr_v2_8d_qty:            'AU52',
        rack_buec_v2_8d_qty:            'AU53',
        rack_bare_83x25:                'U63',
        rack_bare_83x22:                'U64',
        # RCE Infor
        rce_control_qty:                'AU67',
        rce_remote_qty:                 'AU68',
        rce_control_cable_qty:          'AU69',
        rce_remote_cable_qty:           'AU70',
        # Site kit
        v2_site_kit:                    'AU57',
        #srf comments
        comments:                       'AA83',
      }
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

    def get_attributes
      atts = {}
      att_locations.each  do |k,v|
        atts[k] = sheet.range(v).Value
      end
      atts
    end

    def get_attribute(att)
      loc = att_locations_indifferent[att]
      sheet.range(loc).Value if loc
    end

    def [](att)
      get_attribute(att)
    end

    def update_attribute(att, value)
      loc = att_locations_indifferent[att]
      sheet.range(loc).Value = value if loc
    end

    def _update_attribute(att, value)
      loc = att_locations_indifferent[att]
      sheet.range(loc).Value = value
    end
    
    def []=(key,value)
      update_attribute(key,value)
    end

    def update_attributes(atts)
      atts = atts.transform_keys(&:to_sym)
      atts = default_attribute_values.merge(atts)
      atts[:site_prep_date] = atts[:plant_install_date]
      if atts[:site_prep_date] == ""
        atts[:site_prep_date] = atts[:electronic_install_date]
      end
      atts[:fill_date] ||= Date.today.strftime('%m/%d/%Y')
      keys = att_locations.keys
      atts_to_update = atts.select { |k, _v| keys.include? k }.transform_values{ |v| v.nil? ? "" : v }
      atts_to_update.each do |k, v|
        _update_attribute(k, v)
      end
    end

    def serialize(name= nil, l_serializer: nil)
      l_serializer = l_serializer || self.serializer
      atts = get_attributes
      name ||= form_data_name(atts)
      File.open(name,'w') do |f|
        f.write l_serializer.serialize(atts)
      end
    end

    def to_json
      atts = json_serializer.serialize(get_attributes)
    end

    def form_data_name(atts)
      [atts[locid], atts[factype], 'srf.data.json'].join('.')
    end

    def clear_form
      att_locations.each do |_k, v|
        sheet.range(v).Value = ''
      end
    end

    def save
      @wb.save
    end

    def save_as(file)
      @wb.save_as("#{file}")
    end

    def close
      @wb.close(if_unsaved: :forget)
    end
  end
end

if $0 == __FILE__
  atts = { locid: 'GJT',
           factype: 'ARTCC',
           jcn: '13333',
           jon: '06349',

         }
  atts_as_string = atts.transform_keys(&:to_s)
  srf = Nexcom::ExcelSrf.new
  
 # srf = Nexcom::ExcelSrf.new_from_atts(atts)
  
  require 'pry'; binding.pry
  srf.update_attributes(atts)
  json = srf.to_json

  srf.close
  srf = Nexcom::ExcelSrf.new
  srf.update_attributes(atts_as_string)
  json2 = srf.to_json
  if json == json2
    puts 'equal'
  else
    puts 'not equal'
  end
  srf.close
  puts 'hello'
end
