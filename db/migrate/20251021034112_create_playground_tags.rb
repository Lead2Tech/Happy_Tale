class CreatePlaygroundTags < ActiveRecord::Migration[7.1]
  def change
    create_table :playground_tags do |t|
      t.references :playground, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true

      t.timestamps
    end
  end
end
