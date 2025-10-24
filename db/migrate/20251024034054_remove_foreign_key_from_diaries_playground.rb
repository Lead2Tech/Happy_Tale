class RemoveForeignKeyFromDiariesPlayground < ActiveRecord::Migration[7.1]
  def change
    remove_foreign_key :diaries, :playgrounds
  end
end
