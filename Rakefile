# -*- ruby -*-

require "rubygems"
require "hoe"

Hoe.plugin :bundler
# Hoe.plugin :compiler
# Hoe.plugin :gem_prelude_sucks
# Hoe.plugin :inline
# Hoe.plugin :minitest
# Hoe.plugin :racc
# Hoe.plugin :rcov
# Hoe.plugin :rdoc
# Hoe.plugin :yard

Hoe.spec "nexcom-srf" do
  # HEY! If you fill these out in ~/.hoe_template/default/Rakefile.erb then
  # you'll never have to touch them again!
  # (delete this comment too, of course)
  dependency('robust_excel_ole', '~> 1.3')
  dependency('concurrent-ruby','>= 0.0')
  dependency('dry-core', '~>0.4')
  dependency('guard', '>=0', :developer)
  dependency('guard-minitest', '>= 0.0', :developer)
  developer("dominic", "dsisnero@gmail.com")
  license "MIT" # this should match the license in the README
end

desc 'Push gem to github.' 
task :release_to_github  => [:prerelease, :repackage] do
  gem = FileList['pkg/*.gem'].last
  sh %Q[gem push --key github --host https://rubygems.pkg.github.com/dsisnero "#{gem}"]
end

# vim: syntax=ruby
 
