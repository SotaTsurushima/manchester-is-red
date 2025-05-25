class CreateMatches < ActiveRecord::Migration[8.0]
  def change
    create_table :matches do |t|
      t.datetime :utc_date
      t.string :home_team
      t.string :away_team
      t.string :competition
      t.string :score
      t.string :venue
      t.string :status
      t.string :referees

      t.timestamps
    end
  end
end
