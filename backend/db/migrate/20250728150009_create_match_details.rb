class CreateMatchDetails < ActiveRecord::Migration[8.0]
  def change
    create_table :match_details do |t|
      t.references :match, null: false, foreign_key: true
      t.json :scorer_name # 得点者の名前（外部APIから取得した場合）
      t.json :assist_name # アシスト者の名前（外部APIから取得した場合）
      t.json :additional_data # 追加情報（得点の種類、カードの理由など）

      t.timestamps
    end
  end
end
