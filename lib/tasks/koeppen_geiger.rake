namespace :koeppen_geiger do
  desc "Add new database settings to database.yml"
  task :configure => :environment do
    KoeppenGeiger::Utils.configure_db
  end
  
  desc "Import gis data into table"
  task :import_gis_data => :environment do
    KoeppenGeiger::Utils.import_gis_data
  end
  
  desc "Extract gis data"
  task :extract_gis_data => :environment do
    KoeppenGeiger::Utils.extract_gis_data
  end
end