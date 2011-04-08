class CreateClimateClassifications < ActiveRecord::Migration
  
  def self.up
    create_table :climate_classifications, :force => true do |t|
      t.integer :classified_id
      t.string :observed_1901_1925
      t.string :observed_1926_1950
      t.string :observed_1951_1975
      t.string :observed_1976_2000
      t.string :a1f1_2001_2025
      t.string :a1f1_2026_2050
      t.string :a1f1_2051_2075
      t.string :a1f1_2076_2100
      t.string :a2_2001_2025
      t.string :a2_2026_2050
      t.string :a2_2051_2075
      t.string :a2_2076_2100
      t.string :b1_2001_2025
      t.string :b1_2026_2050
      t.string :b1_2051_2075
      t.string :b1_2076_2100
      t.string :b2_2001_2025
      t.string :b2_2026_2050
      t.string :b2_2051_2075
      t.string :b2_2076_2100
      t.timestamps
    end
  end
  
  def self.down
    drop_table :climate_classifications
  end
  
end