class RemoveMvpFromPlayers < ActiveRecord::Migration[8.0]
  def change
    remove_column :players, :mvp, :integer
  end
end
