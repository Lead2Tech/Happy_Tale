class ChangePlaygroundIdNullInDiaries < ActiveRecord::Migration[7.1]
  def change
    change_column_null :diaries, :playground_id, true
  end
end
