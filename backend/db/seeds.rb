# 管理者ユーザーを作成
unless User.exists?(email: 'admin@manchester.com')
  User.create!(
    name: 'Administrator',
    role: 'admin',
    email: 'admin@manchester.com',
    password: 'admin123',
    password_confirmation: 'admin123',
    confirmed_at: Time.current # メール確認をスキップ
  )
  
  puts "✅ Admin user created: admin@manchester.com / admin123"
else
  puts "ℹ️  Admin user already exists: admin@manchester.com"
end

# テスト用ユーザーを作成（開発環境のみ）
if Rails.env.development?
  unless User.exists?(email: 'test@example.com')
    User.create!(
      name: 'Test User',
      role: 'user',
      email: 'test@example.com',
      password: 'password123',
      password_confirmation: 'password123',
      confirmed_at: Time.current # メール確認をスキップ
    )
    
    puts "✅ Test user created: test@example.com / password123"
  else
    puts "ℹ️  Test user already exists: test@example.com"
  end
end

# 追加のテストユーザー（開発環境のみ）
if Rails.env.development?
  unless User.exists?(email: 'user@example.com')
    User.create!(
      name: 'Regular User',
      role: 'user',
      email: 'user@example.com',
      password: 'password123',
      password_confirmation: 'password123',
      confirmed_at: Time.current
    )
    
    puts "✅ Regular user created: user@example.com / password123"
  else
    puts "ℹ️  Regular user already exists: user@example.com"
  end
end

puts "\n🎉 Seeding completed!"
