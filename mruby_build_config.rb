MIX_ENV = ENV["MIX_ENV"] || "dev"
MIX_TARGET = ENV["MIX_TARGET"] || "host"

MRuby::Build.new do |conf|
  toolchain :gcc
  enable_debug

  # include the default GEMs

  conf.gembox 'default'
  conf.gem :github => 'mattn/mruby-json'
  conf.gem :github => 'mattn/mruby-thread'

  # C compiler settings
  conf.cc do |cc|
    cc.command = ENV['CC']  || raise("Missing C Compiler.")
  end

  # Linker settings
  conf.linker do |linker|
    linker.command = ENV['CC'] || raise("Missing Linker")
  end

  # Archiver settings
  conf.archiver do |archiver|
    archiver.command = ENV['AR'] || raise("Missing archiver.")
  end

end
