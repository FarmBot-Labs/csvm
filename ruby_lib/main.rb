if RUBY_ENGINE == "mruby"
  puts "BOOTING MRUBY"
end

if RUBY_ENGINE == "ruby"
  puts "BOOTING MRI (Not mRuby)"
end

# App.current.run!
