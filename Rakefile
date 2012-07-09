require 'rake/testtask'

task :default => :test

Rake::TestTask.new(:test) do |t|
  t.libs << 'spec'
  t.pattern = 'spec/**/*.spec.rb'
end

desc 'Add new screenings'
task :update_films do
  OKCMOA.update_films
end
