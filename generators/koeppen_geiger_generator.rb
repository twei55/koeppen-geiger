class KoeppenGeigerGenerator < Rails::Generator::Base
  
  def manifest
    record do |m|
      # Create a directory if missing
      m.directory 'lib/tasks'
      
      # Copy rake files to Rails application
      m.file('../../lib/tasks/koeppen_geiger.rake', 'lib/tasks/koeppen_geiger.rake')
      
      # Copy migration file to Rails application
      m.migration_template('migration.rb', 'db/migrate', :migration_file_name => "create_climate_classifications.rb")
    end
  end
  
end