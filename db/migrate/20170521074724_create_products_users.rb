class CreateProductsUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :products_users do |t|
      t.references :product, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end

    add_index :products_users, [:product_id, :user_id]
  end
end
