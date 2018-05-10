require "test-unit"
require "rake/testtask"

Rake::TestTask.new do |t|
  t.test_files = FileList["./ruby_lib/**/*.rb"]
  t.verbose    = true
end

desc "Generate list of files for compilation in the correct order"
