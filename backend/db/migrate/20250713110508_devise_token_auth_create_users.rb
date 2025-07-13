class DeviseTokenAuthCreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table(:users) do |t|
      ## User Info (基本情報)
      t.string :name
      t.string :nickname
      t.string :image
      t.string :email
      t.string :role, :default => "user"

      ## Required (devise_token_auth必須)
      t.string :provider, :null => false, :default => "email"
      t.string :uid, :null => false, :default => ""

      ## Database authenticatable (認証)
      t.string :encrypted_password, :null => false, :default => ""

      ## Confirmable (メール確認)
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string   :unconfirmed_email # Only if using reconfirmable

      ## Recoverable (パスワードリセット)
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at
      t.boolean  :allow_password_change, :default => false

      ## Rememberable (ログイン記憶)
      t.datetime :remember_created_at

      ## Lockable (アカウントロック)
      # t.integer  :failed_attempts, :default => 0, :null => false # Only if lock strategy is :failed_attempts
      # t.string   :unlock_token # Only if unlock strategy is :email or :both
      # t.datetime :locked_at

      ## Tokens (JWTトークン)
      t.text :tokens

      t.timestamps
    end

    add_index :users, :email,                unique: true
    add_index :users, [:uid, :provider],     unique: true
    add_index :users, :reset_password_token, unique: true
    add_index :users, :confirmation_token,   unique: true
    add_index :users, :role
    # add_index :users, :unlock_token,         unique: true
  end
end
