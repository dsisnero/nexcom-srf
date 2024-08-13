# frozen_string_literal: true

require "bundler/gem_tasks"
require "standard/rake"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "spec"
  t.libs << "lib"
  t.test_files = FileList["spec/**/*_spec.rb"]
end

desc "Push gem to github."
task release_to_github: [:build] do
  gem = FileList["pkg/*.gem"].last
  sh %(gem push --key github --host https://rubygems.pkg.github.com/dsisnero "#{gem}")
end

require "standard/rake"

task default: %i[test standard]
