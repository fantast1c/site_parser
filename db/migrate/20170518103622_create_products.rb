class CreateProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :products do |t|
      t.string :manufacturer
      t.string :model
      t.float  :price, precision: 3
      t.string :source
      t.string :status

      t.timestamps
    end
  end
end
