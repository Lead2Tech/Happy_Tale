class CreatePlaygrounds < ActiveRecord::Migration[7.1]
  def change
    create_table :playgrounds do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.string :address
      t.float :latitude
      t.float :longitude
      t.text :description
      t.string :source

      t.timestamps
    end
  end
end
