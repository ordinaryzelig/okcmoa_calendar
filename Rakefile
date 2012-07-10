require 'rake/testtask'

task :default => :test

Rake::TestTask.new(:test) do |t|
  t.libs << 'spec'
  t.pattern = 'spec/**/*.spec.rb'
end

task :init do
  require './lib/okcmoa'
  OKCMOA.config.verbose = true
end

desc 'Add new screenings'
task :update_films => :init do
  mail_on_error do
    OKCMOA.update_films
  end
end

def mail_on_error
  begin
    yield
  rescue Exception => ex
    OKCMOA::Mailer.mail_exception(ex)
  end
end
