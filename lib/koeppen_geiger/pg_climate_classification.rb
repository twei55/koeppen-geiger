module KoeppenGeiger
  
  # This is a tableless model that establishes a connection to PostgreSQL and requests
  # observed or predicted climate_classifications for a pair of lat/lng coordinates
  #
  # See this snippet for more information
  # http://snipplr.com/view/1849/tableless-model/
  
  class PgClimateClassification < ActiveRecord::Base
          
    def self.columns 
      @columns ||= []
    end
    
    attr_accessor :scenarios
    
    ##########################
    # Instance methods
    ##########################
    
    def initialize
      begin
        ActiveRecord::Base.establish_connection "koeppen_geiger"
      rescue ActiveRecord::ConnectionNotEstablished
        puts "Connection could not be established"
      rescue ActiveRecord::AdapterNotSpecified
        puts "Oops! Adapter not specified. This is okay when running rake:test"
      end
      
      get_scenario_tables
    end
    
    #
    # Get all tables from database to see how many different scenarios and timeperiods
    # have been imported
    #
    # Each shapefile imported into the database creates a new table
    #
    def get_scenario_tables
      res = self.connection.execute(  "SELECT table_name FROM information_schema.tables 
                                      WHERE table_schema = 'public' 
                                      AND table_name != 'geometry_columns'
                                      AND table_name != 'spatial_ref_sys'")
      @scenarios = []
      if res.num_tuples >= 1
        res.each do |tuple|
          # The unless statement is only needed for testing purposes
          @scenarios << tuple["table_name"] unless tuple["table_name"].eql?("locations")
        end
      else
        puts "No data imported yet. Please run rake koeppen_geiger:db:import_data"
      end
    end
        
    def get_climate_zones(lat,lon)
      gridcodes = {}
      @scenarios.each do |scenario|
        res = self.connection.execute("SELECT gridcode FROM #{scenario} WHERE ST_CONTAINS(the_geom,'POINT(#{lon} #{lat})') LIMIT 1;")
        if res.num_tuples == 1
          gridcodes[scenario] = KoeppenGeiger::ClimateClassification::CLIMATE_ZONES[res.getvalue(0,0).to_s]
        end
      end
      
      return gridcodes
    end
    
    #
    # Reconnect to former database when instance is deleted
    # otherwise the rails app starts operating on the wrong db
    #
    def delete
      ActiveRecord::Base.establish_connection RAILS_ENV
    end
    
  end
  
end