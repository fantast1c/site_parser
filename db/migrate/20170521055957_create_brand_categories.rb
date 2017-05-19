class CreateBrandCategories < ActiveRecord::Migration[5.0]
  def change
    create_table :brands_categories do |t|
      t.references :category, foreign_key: true
      t.references :brand, foreign_key: true

      t.timestamps
    end

    add_index :brands_categories, [:category_id, :brand_id]
  end
end
