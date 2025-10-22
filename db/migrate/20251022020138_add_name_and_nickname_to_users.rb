class AddNameAndNicknameToUsers < ActiveRecord::Migration[7.1]
  def change
    # name はすでにあるので nickname だけ追加
    add_column :users, :nickname, :string
  end
end
