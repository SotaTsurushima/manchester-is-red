class AddStatsToPlayers < ActiveRecord::Migration[8.0]
  def change
    add_column :players, :yellow_card, :integer
    add_column :players, :red_card, :integer
    add_column :players, :appearances, :integer
    add_column :players, :market_value, :decimal
  end
end
