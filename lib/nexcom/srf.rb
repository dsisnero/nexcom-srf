require 'dry-types'
require 'dry-struct'
require 'pry'
require 'rdf'

module Nexcom

  module Types
    include Dry::Types.module
  end

  class Address < Dry::Struct


    CITY_STATE_LINE =   /^(.+),\s+(.+)(\d{5})$/

    attribute :name, Types::Params::String.meta(omittable: true)
    attribute :street1, Types::Params::String
    attribute :street2, Types::Params::String.meta(omittable: true)
    attribute :city, Types::Params::String
    attribute :state, Types::Params::String
    attribute :zipcode, Types::Params::String

    def self.from_project_atts(atts)
      address_info = parse_address(atts[:shipping_address])
      address_atts = { name: atts[:shipping_title],
                       street1: address_info[:street1],
                       city: address_info[:city],
                       state: address_info[:state],
                       zipcode: address_info[:zipcode],
                     }
      address_atts[:street2] =  address_info[:street2] if street2
      new(address_atts)
    end

    def city_state_zip_line
      "#{{city}, #{state} #{{zip}"
    end

    def self.parse_address(address)
      street, city_line = address.split("\n")
      if CITY_STATE_LINE.match city_line
        city = md[1]
        state = md[2]
        zipcode = md[3]
      end
      { street: street, city: city, state: state, zipcode: zipcode}
    end

    def to_project_atts(prefix)
      atts = {}
      atts["#{prefix}_street".to_sym] = [street1, street2].compact.join(" ")

    end

  end

  class Facility < Dry::Struct
    attribute :locid, Types::Strict::String
    attribute :factype, Types::Strict::String
    attribute :city, Types::Strict::String
    attribute :state, Types::Strict::String
    attribute :latitude , Types::Strict::String.meta(omittable: true)
    attribute :longitude, Types::Strict::String.meta(omittable: true)
    attribute :msl, Types::Params::String.meta(omittable: true)
    attribute :ssc_locid, Types::Strict::String.meta(omitable: true)
    attribute :gsa_address, Types::Strict::String.meta(omittable: true)
    attribute :cost_center_code, Types::Strict::String.meta(omittable: true)

    def from_project_atts(atts)
      {
        locid: atts[:locid],
        factype: atts[:factype],
        city: atts[:city],
        state: atts[:state],
        latitude: atts[:latitude],
        longitude: atts[:longitude],
        msl: atts[:msl],
      }
    end

    def to_project_atts
      { factype: factype,
        locid: locid,
        city: city,
        state: state,
        latitude: latitude
        longitude: longitude
        msl: msl
        cost_center: cost_center
        fac_ident: fac_ident
        gsa_address: gsa_address
      }
    end
      
  end

  class Weight < Dry::Struct::Value

    WeightUnit = Types::Strict::String.enum('pounds','kilograms','gram')

    attribute :value, Types::Strict::Float
    attribute :unit, WeightUnit
  end

  class Dimension < Dry::Struct::Value

    DimensionUnit = Types::Strict::String.enum('inches','centimeters','meters')

    attribute :length, Types::Strict::Float
    attribute :height, Types::Strict::Float
    attribute :depth, Types::Strict::Float
    attribute :unit,  DimensionUnit

  end

  class Labor < Dry::Struct

    LaborSource = Types::Strict::String.enum('govt', 'program_tssc', 'core_tssc', 'floating_crew')
    attribute :site_prep, LaborSource
    attribute :resident_engineering, LaborSource
    attribute :installation, LaborSource

    def self.default
      labor = new( site_prep: 'govt', resident_engineering: 'govt', installation: 'floating_crew')
    end

  end

  class Product < Dry::Struct
    attribute :srf_code, Types::Strict::String
    attribute :nsn, Types::Strict::String.meta(omittable: true)
    attribute :title, Types::Strict::String
    attribute :description, Types::Strict::String
    attribute :shipping_weight, Weight
    attribute :dimension, Dimension

  end

  class Person < Dry::Struct
    attribute :first_name, Types::Params::String(omittable: true)
    attribute :last_name, Types::Params::String(omittable: true)
    attribute :name, Types::Params::String(omittable: true)
    attribute :honorific, Types::Params::String(omittable: true)
    attribute :phone, Types::Params::String.meta(omittable: true)
    attribute :cellphone, Types::Params::String.meta(omittable: true)
    attribute :email, Types::Params::String.meta(omittable: true)

    def self.from_project_atts(atts)
      first, last = atts[:project_enginner]
      Person.new( first_name: first, last_name: last,
                  phone: atts[:project_engineer_phone],
                  cellphone: atts[:project_engineer_cell])

    end

    def name
      name ||= [honorific, first_name, last_name].compact.join(" ")
    end
    
  end

  class Shipping < Dry::Struct

    attribute :poc, Person
    attribute :address , Address
    attribute :instructions, Types::Strict::String.meta(omittable: true)

    def self.from_project_atts(atts)
      first, last = atts[:shipping_poc]
      poc = Person.new( first_name: first,
                        last_name: last
                      )
      address = Address.from_project_atts(atts)
      new( poc: poc,
           address: address,
           instructions: atts[:shipping_special_instructions],
         )
    end

    def to_project_atts
      atts = {}
      atts[shipping_poc: poc.name]
      atts[shipping_street:] = address.street
      atts[shipping_city_state_zip:] = address.city_state_zip_line 
      atts[shipping_special_instructions:] = instructions
    end

  end



  class Project

    attribute :jcn, Types::Strict::String
    attribute :dpn, Types::Strict::String
    attribute :start_date, Types::Params::Date
    attribute :site_prep_date, Types::Params::Date
    attribute :project_engineer, Person
    attribute :shipping, Shipping
    attribute :facility, Facility
    attribute :labor, Labor

    def self.from_project_atts(atts)
      srf_atts = {
        jcn: atts[:jcn],
        dpn: atts[:dpn],
        project_engineer: Person.from_project_atts(atts),
        facility: Facility.from_project_atts(atts),
        labor: Labor.default,
        delivery: Shipping.from_project_atts(atts),
      }
      new(srf_atts)
    end


    def to_project_atts
      atts = {} 
      atts[:project_engineer] = project_engineer.name
      atts[:jcn] = jcn
      atts[:dpn] =  dpn
      atts[:form_fill_date] = fill_date
      atts[:locid] = facility.locid
      atts[:factype] = facility.factype
      atts[:city] = facility.city
      atts[:state] = facility.state
      atts[:cost_center] = facility.cost_center
      atts[:ssc_gsa_address] = facility.gsa_address
      atts[:start_date] = start_date
      atts[:site_prep_date] = site_prep_date
      atts[:jai_date] = jai_date
      atts.merge delivery.to_project_atts



    end
    
    class LineItem < Dry::Struct

      attribute :nsn, Types::Strict::String
      attribute :srf_code, Types::Strict::String
      attribute :qty, Types::Coercible::Integer

    end

    class Srf < Dry::Struct

      attribute :fill_date, Types::Params::Date.default(Date.today)
      attribute :project_engineer, Person do
        attribute :name, Types::Params::String
        attribute :phone, Types::Params::String
      end
      attribute :jcn, Types::Params::String
      attribute :dpn, Types::Params::String.optional
      attribute :locid, Type::Params::String
      attribute :factype, Types::Params::String
      attribute :city, Types::Params::String
      attribute :state, Types::Params::String
      attribute :cost_center, Types::Params::String
      attribute :ssc_gsa_address, Types::Params::String
      attribute :start_date, Types::Params::Date
      attribute :site_prep_date, Types::Params::Date
      attribute :jai_date, Types::Params::Date
      attribute :line_items, Types.Array(LineItem)
      attribute :shipping, Address
      attribute :poc_phone, Types::Params::String
      attribute :address, Address
      attribute :instructions, Types::Params::String.meta(omittable: true)
    end

    def self.from_project(project)
      atts = project
    end

  end
end

end


if $0 == __FILE__
  product = Nexcom::Product.new(srf_code: '01', title: 'NEXCOM V1 Receiver', description: 'this is the description',
                                shipping_weight: {value: 5.0, unit: 'pounds'} , dimension: {length: 5.0, height: 10.0, depth: 3.0, unit: 'inches'})

  labor = Nexcom::Labor.new(site_prep: 'govt', resident_engineering: 'govt', installation: 'floating_crew')
  cdcz = Nexcom::Facility.new(locid: 'CDCZ', factype: 'RCO', city: 'Cedar City', state: 'UT',
                              ssc_locid: 'Boise', gsa_address: '0235', cost_center_code: '082GB')
  delivery = Nexcom::Shipping.new(poc: {first_name: 'Merle', last_name: 'Hancock', phone: '435-586-8750'},
                                  address: {
                                    name: 'Cedar City RCO',
                                    street1: '2248 West Kittyhawk Dr',
                                    city: 'Cedar City',
                                    state: 'UT',
                                    zipcode: '84721',
                                  },
                                  instructions: 'Call 24 hours in advance',
                                 )
  vhf = Nexcom::LineItem.new(nsn: '12344053333', srf_code: '3035-1', qty: 5)
  vhf_transmitter = Nexcom::LineItem.new(nsn: '234343', srf_code: '3058-1', qty: 2)

  srf = Nexcom::Project.new(project_engineer: { first_name: 'Dominic', last_name: 'Sisneros'},
                        jcn: '1806331',
                        dpn: 'UPDATE',
                        delivery: delivery,
                        facility: cdcz,
                        labor: labor,
                        line_items: [vhf, vhf_transmitter]
                       )

  binding.pry

  puts srf
end
