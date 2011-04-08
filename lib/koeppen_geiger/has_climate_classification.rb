module KoeppenGeiger
  
  # Can be mixed into a ActiveRecord class that has lat/lng columns
  # 
  # Example:
  #   class Location < ActiveRecord::Base
  #     has_climate_classification
  #     has_climate_classification :lat_column_name => "latitude", :lng_column_name => "longitude"
  #   end
  #
  # location = Location.find(1)
  # location.climate_classification("observed",1901)
  # => "Cfa"
  # location.climate_classification("a2",2025).to_words
  # => "Equatorial climate, fully humid, hot summer"
  #
  # Declares a 1:1 association to the model when embedding has_climate_classification
  
  module HasClimateClassification
    
    def has_climate_classification(options = {})
      
      @@options = options
      
      class_eval do
        has_one :climate_classification, :class_name => "KoeppenGeiger::ClimateClassification", :foreign_key => "classified_id", :dependent => :destroy
        
        #
        # Adds available climate classifications to a location
        #
        def classify
          unless @@options[:lat_column_name].nil? || @@options[:lng_column_name].nil?
            self[:lat] = self[@@options[:lat_column_name].to_sym] || self[:lat]
            self[:lng] = self[@@options[:lng_column_name].to_sym] || self[:lng]
          end
          
          if self.has_coordinates?
            self.climate_classification = KoeppenGeiger::ClimateClassification.new if self.climate_classification.nil?
            pg_cc = KoeppenGeiger::PgClimateClassification.new
            gridcodes = pg_cc.get_climate_zones(self[:lat],self[:lng])
            
            # Delete instance to reconnect to former rails db
            pg_cc.delete
            
            self.climate_classification.attributes = gridcodes
            self.climate_classification.save
          else
            puts "Object cannot be classified. Please specify correct column names and make sure your location has correct coordinates."
          end
        end
        
        # Returns a classification code for a certain scenario and year
        # 
        # Example:
        # location.classified("observed",1905)
        #
        def classified(scenario,year)
          timerange = KoeppenGeiger::ClimateClassification.determine_time_range(scenario,year)
          
          unless timerange.nil?
            column_name = KoeppenGeiger::ClimateClassification.create_column_name(scenario,timerange.first.to_s,timerange.last.to_s).to_sym
            return self.climate_classification[column_name] || "No value found"
          else
            return "No data found within the year #{year} in the scenario #{scenario}"
          end
        end
        
        def has_coordinates?
          !self[:lat].nil? && self[:lat].present? && !self[:lng].nil? && self[:lng].present?
        end
        
      end
      
      # Extend String class
      String.class_eval do
        
        def to_words
          KoeppenGeiger::ClimateClassification.climate_zone_to_words(self)
        end
        
      end
    
    end
    
  end
  
end