require "test-unit"
require "rake/testtask"
require 'tsort'
require "pry"
# Thanks, @palkan !
# Original impl: https://github.com/mruby/mruby/pull/3748
class RbfilesSorter
  include TSort

  TAG_RXP = /^#\s*require:\s*['"]([\w\.\/]+)["']\s*$/

  def initialize(root)
    @root  = root
    @files = Dir.glob("#{root}/**/*.rb").sort
    @deps  = {}
  end

  def sort
    @files.each { |f| parse_deps(f) }
    tsort
  end

  def tsort_each_child(node, &block)
    @deps[node].each(&block)
  end

  def tsort_each_node(&block)
    @deps.each_key(&block)
  end

  def parse_deps(file)
    f = File.new(file)

    deps_list = @deps[File.expand_path(file)] = []

    f.each_line do |line|
      # Skip blank lines
      next if line =~ /^\s*$/
      # All requires should be in the beginning of the file
      break if line !~ TAG_RXP

      dep = line.match(TAG_RXP)[1]

      dep += ".rb" unless dep.end_with?(".rb")
      x = File.expand_path(dep, File.dirname(file))
      deps_list << x
    end
  end
end

LIB_DIR    = "./ruby_lib"
ENTRY_FILE = "__main.rb"
ENTRY_PATH = File.expand_path(ENTRY_FILE, LIB_DIR)
DEPS       = RbfilesSorter.new(LIB_DIR).sort.reverse

Rake::TestTask.new do |t|
  t.test_files = RbfilesSorter
                  .new(LIB_DIR)
                  .sort
                  .reject {|x| x == ENTRY_PATH}
  t.verbose    = true
end

desc "Resolve dependency for mRuby (no tests, etc)"

task :mrb_deps do
  puts DEPS
    .reject { |x| x.include?("_test.rb") }
    .join("\n")
end

desc "Resolve developer deps (includes tests, reverse load order for MRI)"

task :deps do
  puts DEPS.reject { |x| x.include?("_test.rb") }.join(" ")
end
