module Geocodeable
  extend ActiveSupport::Concern
  included do

    def self.hello_world
      puts 'Hello World!'
    end

    def self.get_address_component(results, types)
      address_component = results.collect{ |r|
        r.address_components.find{ |c|
          types.all?{ |t| c["types"].include?(t) }
        }.try(:[], "short_name")
      }.compact.first
      address_component ||= ""
    end

    def self.get_location_name(results)
      location_name = get_address_component(results, ["neighborhood"])
      if location_name.blank?
        location_name = get_address_component(results, ["locality"])
        if location_name.blank? || location_name == "London"
          location_name = get_address_component(results, ["route"])
        end
      end
      location_name
    end

    def self.get_admin_area(results)
      admin_area = get_address_component(results, ["administrative_area_level_3"])
      if admin_area.blank?
        admin_area = get_address_component(results, ["administrative_area_level_2"])
      end
      admin_area
    end
  end


  def get_address_component(results, types)
    self.class.get_address_component(results, types)
  end



  def get_location_name(results)
    self.class.get_location_name(results)
  end



  def get_admin_area(results)
    self.class.get_admin_area(results)
  end

  def hello_world
    self.class.hello_world
  end

end
