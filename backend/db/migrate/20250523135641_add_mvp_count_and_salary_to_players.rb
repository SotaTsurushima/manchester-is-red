class AddMvpCountAndSalaryToPlayers < ActiveRecord::Migration[8.0]
  def change
    add_column :players, :mvp, :integer
    add_column :players, :salary, :integer
  end
end
