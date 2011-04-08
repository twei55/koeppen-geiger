module KoeppenGeiger
  
  class ClimateClassification < ActiveRecord::Base
    
    CLIMATE_ZONES = {"11" => "Af","12" => "Am","13" => "As","14" => "Aw",
                     "21" => "BWk","22" => "BWh","26" => "BSk","27" => "BSh",
                     "31" => "Cfa","32" => "Cfb","33" => "Cfc","34" => "Csa",
                     "35" => "Csb","36" => "Csc","37" => "Cwa","38" => "Cwb",
                     "39" => "Cwc","41" => "Dfa","42" => "Dfb","43" => "Dfc",
                     "44" => "Dfd","45" => "Dsa","46" => "Dsb","47" => "Dsc",
                     "48" => "Dsd","49" => "Dwa","50" => "Dwb","51" => "Dwc",
                     "52" => "Dwd","61" => "EF","62" => "ET" }
                     
    TIME_RANGES = { "observed" => [1901..1925,1926..1950,1951..1975,1976..2000],
                    "a1f1" => [2001..2025,2026..2050,2051..2075,2076..2100],
                    "a2" => [2001..2025,2026..2050,2051..2075,2076..2100], 
                    "b1" => [2001..2025,2026..2050,2051..2075,2076..2100],
                    "b2" => [2001..2025,2026..2050,2051..2075,2076..2100]}
    
    SCENARIOS = ["observed","a1f1","a2","b1","b2"]
    
    
    def self.create_column_name(*args)
      args.join("_")
    end
    
    def self.climate_zone_to_words(str)
      I18n.t(str.downcase.to_sym, :scope => [:climate_zones])
    end
    
    def self.determine_time_range(scenario,year)
      return nil unless KoeppenGeiger::ClimateClassification.valid_scenario?(scenario)
      
      TIME_RANGES[scenario].each do |timerange|
        return timerange if timerange.member?(year.to_i)
      end
      
      nil
    end
    
    def self.valid_scenario?(scenario)
      SCENARIOS.include?(scenario)
    end
  
  end

end