class RecreateTeamsAndMatches < ActiveRecord::Migration[6.0]
  def change
    drop_table :matches, if_exists: true do |t|
      t.references :home_team, null: false, foreign_key: { to_table: :teams }, type: :bigint
      t.references :away_team, null: false, foreign_key: { to_table: :teams }, type: :bigint
      t.datetime :utc_date, null: false
      t.string :competition
      t.string :score
      t.string :venue
      t.string :status
      t.string :referees
      t.timestamps
    end
    
    drop_table :teams, if_exists: true do |t|
      t.string :name, null: false
      t.string :crest_url
      t.timestamps
    end

    create_table :teams do |t|
      t.string :name, null: false
      t.string :crest_url
      t.timestamps
    end

    create_table :matches do |t|
      t.references :home_team, null: false, foreign_key: { to_table: :teams }, type: :bigint
      t.references :away_team, null: false, foreign_key: { to_table: :teams }, type: :bigint
      t.datetime :utc_date, null: false
      t.string :competition
      t.string :score
      t.string :venue
      t.string :status
      t.string :referees
      t.timestamps
    end
  end
end
