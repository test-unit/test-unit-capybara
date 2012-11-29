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
require 'packnga'
require "bundler/gem_helper"

base_dir = File.dirname(__FILE__)
helper = Bundler::GemHelper.new(base_dir)
helper.install
spec = helper.gemspec

Gem::PackageTask.new(spec) do |pkg|
  pkg.need_tar_gz = true
end

document_task = Packnga::DocumentTask.new(spec) do
end

Packnga::ReleaseTask.new(spec) do |task|
end

# XXX: Workaround. This should be fixed in packnga.
task :htaccess do
  htaccess = "doc/html/test-unit-capybara/.htaccess"
  htaccess_content = File.read(htaccess)
  File.open(htaccess, "w") do |htaccess_file|
    htaccess_file.print(htaccess_content.gsub(/#test-unit-capybara/, ""))
  end
end
task "release:reference:publish" => :htaccess

desc "Tag the current revision."
task :tag do
  message = "Released test-unit-capybara #{version}!"
  sh 'git', 'tag', '-a', version, '-m', message
end

desc "Run test"
task :test do
  ruby "test/run-test.rb"
end

task :default => :test

# vim: syntax=Ruby
