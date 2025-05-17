class AddGoalsAndAssistsToPlayers < ActiveRecord::Migration[8.0]
  def change
    add_column :players, :goals, :integer
    add_column :players, :assists, :integer
  end
end
