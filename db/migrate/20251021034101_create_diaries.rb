class CreateDiaries < ActiveRecord::Migration[7.1]
  def change
    create_table :diaries do |t|
      t.references :user, null: false, foreign_key: true
      t.references :playground, null: false, foreign_key: true
      t.string :title
      t.text :content
      t.datetime :visited_at

      t.timestamps
    end
  end
end
