# Host build
MRuby::Build.new do |conf|
  toolchain :gcc
  enable_debug

  conf.gembox 'default'
  conf.gem github: 'mattn/mruby-json'
  conf.gem github: 'mattn/mruby-thread'
end

MIX_ENV = ENV["MIX_ENV"] || raise("NO MIX ENV")
MIX_TARGET = ENV["MIX_TARGET"] || raise("NO MIX TARGET")

# raise(MIX_TARGET + '-' + MIX_ENV)

# Nerves deploy build. (may be the same as host build.)
# This one just uses the `make` environment variables.
MRuby::Build.new(MIX_TARGET + '-' + MIX_ENV) do |conf|
  toolchain :gcc
  enable_debug
  conf.gembox 'default'

  conf.gem github: 'mattn/mruby-json'
  conf.gem github: 'mattn/mruby-thread'

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
