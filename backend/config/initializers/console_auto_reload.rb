if Rails.env.development? && defined?(Rails::Console)
  require "listen"

  roots = [
    Rails.root.join("app").to_s,
    Rails.root.join("lib").to_s
  ]

  listener = Listen.to(*roots) do |_modified, _added, _removed|
    begin
      Rails.autoloaders.main.reload
    rescue => e
      warn "⚠️ Reload failed: #{e.class}: #{e.message}"
    end
  end

  listener.start
  puts "👂 Auto-reloader for console started (watching: #{roots.join(', ')})"
end
