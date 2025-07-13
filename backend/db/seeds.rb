# 管理者ユーザーを作成
unless User.exists?(email: 'admin@manchester-united.com')
  User.create!(
    name: 'Administrator',
    role: 'admin',
    email: 'admin@manchester.com',
    password: 'admin123'
  )
  
  puts "✅ Admin user created: admin@manchester-united.com / admin123"
else
  puts "ℹ️  Admin user already exists: admin@manchester-united.com"
end

# テスト用ユーザーを作成（開発環境のみ）
if Rails.env.development?
  unless User.exists?(email: 'test@example.com')
    User.create!(
      name: 'Test User',
      role: 'user',
      email: 'test@gmail.com',
      password: 'password123'
    )
    
    puts "✅ Test user created: test@example.com / password123"
  else
    puts "ℹ️  Test user already exists: test@example.com"
  end
end
