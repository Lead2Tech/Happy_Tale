class AddApiFieldsToPlaygrounds < ActiveRecord::Migration[7.1]
  def change
    # すでに存在しないカラムだけ追加
    add_column :playgrounds, :address, :string unless column_exists?(:playgrounds, :address)
    add_column :playgrounds, :rating, :float unless column_exists?(:playgrounds, :rating)
    add_column :playgrounds, :lat, :float unless column_exists?(:playgrounds, :lat)
    add_column :playgrounds, :lng, :float unless column_exists?(:playgrounds, :lng)
    add_column :playgrounds, :place_id, :string unless column_exists?(:playgrounds, :place_id)
    add_index :playgrounds, :place_id unless index_exists?(:playgrounds, :place_id)
  end
end
