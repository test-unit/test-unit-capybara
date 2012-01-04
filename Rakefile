# -*- ruby -*-
#
# Copyright (C) 2011-2012  Kouhei Sutou <kou@clear-code.com>
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

require './lib/test/unit/capybara/version'

require 'rubygems'
require 'rubygems/package_task'
require 'yard'
require 'jeweler'
require 'packnga'

def cleanup_white_space(entry)
  entry.gsub(/(\A\n+|\n+\z)/, '') + "\n"
end

ENV["VERSION"] ||= Test::Unit::Capybara::VERSION
version = ENV["VERSION"].dup
spec = nil
Jeweler::Tasks.new do |_spec|
  spec = _spec
  spec.name = "test-unit-capybara"
  spec.version = version
  spec.rubyforge_project = "test-unit"
  spec.homepage = "http://test-unit.rubyforge.org/#test-unit-capybara"
  spec.authors = ["Kouhei Sutou"]
  spec.email = ["kou@clear-code.com"]
  entries = File.read("README.textile").split(/^h2\.\s(.*)$/)
  description = cleanup_white_space(entries[entries.index("Description") + 1])
  spec.summary, spec.description, = description.split(/\n\n+/, 3)
  spec.license = "LGPLv2 or later"
  spec.files = FileList["lib/**/*.rb",
                        "bin/*",
                        "doc/text/*",
                        "README",
                        "COPYING",
                        "Rakefile",
                        "Gemfile"]
  spec.test_files = FileList["test/**/*.rb"]
end

Rake::Task["release"].prerequisites.clear
Jeweler::RubygemsDotOrgTasks.new do
end

Gem::PackageTask.new(spec) do |pkg|
  pkg.need_tar_gz = true
end

document_task = Packnga::DocumentTask.new(spec) do
end

Packnga::ReleaseTask.new(spec) do |task|
end

desc "Tag the current revision."
task :tag do
  message = "Released test-unit-capybara #{version}!"
  sh 'git', 'tag', '-a', version, '-m', message
end

# vim: syntax=Ruby
