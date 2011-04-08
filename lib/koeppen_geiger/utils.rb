module KoeppenGeiger
  
  require 'find'
  require 'zip/zip'
  require 'fileutils'
  
  class Utils
    
    @@rails_root = defined?(RAILS_ROOT) ? RAILS_ROOT : ""
    
    DEFAULT_CONFIG = {"koeppen_geiger" => {
                          "adapter" => "postgresql",
                          "database" => "koeppen_geiger",
                          "username" => 'PLEASE CHANGE ME',
                          "password" => 'PLEASE CHANGE ME',
                          "host" => "localhost",
                          "encoding" => "UTF8",
                          "port" => 5432
                        }
                      }
                      
    # Location of database configuration
    DB_CONFIG = "#{@@rails_root}/config/database.yml"

    # GIS data
    ARCHIVE = File.dirname(__FILE__) + "/../../data/koeppen-geiger.zip"
    EXTRACT_DIR = File.dirname(__FILE__) + "/../../data"
    GIS_DATA_DIR = EXTRACT_DIR + "/koeppen-geiger"
    
    class << self
      
      # Open database.yml and add config lines
      def configure_db
        begin
          yaml = Utils.get_db_config
          yaml = Hash.new unless yaml

          unless yaml.has_key?("koeppen_geiger")
            yaml.update(KoeppenGeiger::Utils::DEFAULT_CONFIG)
            File.open(KoeppenGeiger::Utils::DB_CONFIG, 'w') do |out|
              YAML::dump(yaml,out)
            end
            puts ">> Updated database.yml. Please enter correct username/password combination."
          else
            puts ">> Your database.yml has already been updated"
          end
        rescue Errno::ENOENT
          raise StandardError, "Could not find database configuration file"
        end
      end

      def get_db_config
        YAML::load_file(KoeppenGeiger::Utils::DB_CONFIG)         
      end

      ########

      # Import data
      def import_gis_data
        yaml = Utils.get_db_config
        database = yaml["koeppen_geiger"]["database"]
        username = yaml["koeppen_geiger"]["username"]
        password = yaml["koeppen_geiger"]["password"]
        
        get_shape_files.each {|key,value|
          Thread.new do
            Kernel.system("shp2pgsql #{value} public.#{key} | psql -d #{database} -U #{username}")
          end
        }
      end
      
      # Run through subdirectories of data dir
      # and add shape files and dirname to hash
      def get_shape_files
        filehash = {}
                      
        Find.find(KoeppenGeiger::Utils::GIS_DATA_DIR) do |path|
          if (File.extname(path).eql?(".shp"))
            dirname = File.dirname(path).split("/")[-1]
            filehash[dirname] = File.expand_path(path)
          end
        end
        
        filehash
      end
      
      # Extract compressed ziop data
      def extract_gis_data
        if File.exists?(KoeppenGeiger::Utils::ARCHIVE)  
          begin
            #Open the existing zip file
            Zip::ZipFile::open(KoeppenGeiger::Utils::ARCHIVE) do |zipfile|
              zipfile.each do |f|
                #start extracting each file
                path = File.join(KoeppenGeiger::Utils::EXTRACT_DIR, f.name)
                FileUtils.mkdir_p(File.dirname(path))
                zipfile.extract(f, path) 
              end
            end
          rescue Exception => e
            #If the script blows up, then we should probably be somewhere in this region
            puts "An error occurred during decompression: \n #{e}."
          end
        else
          puts "\n\nArchive could not be found."
        end
      end
      
    end
  
  end
end