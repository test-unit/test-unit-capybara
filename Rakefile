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

require 'pathname'

base_dir = Pathname(__FILE__).dirname.expand_path
test_unit_dir = (base_dir.parent + "test-unit").expand_path
test_unit_lib_dir = test_unit_dir + "lib"
lib_dir = base_dir + "lib"

$LOAD_PATH.unshift(test_unit_lib_dir.to_s)
$LOAD_PATH.unshift(lib_dir.to_s)

require 'test/unit/capybara'

require 'rubygems'
require 'hoe'

Test::Unit.run = true

version = Test::Unit::Capybara::VERSION
ENV["VERSION"] = version
Hoe.spec('test-unit-capybara') do
  self.version = version
  self.rubyforge_name = "test-unit"

  developer('Kouhei Sutou', 'kou@clear-code.com')

  extra_deps << ["test-unit", ">= 2.1.2"]
  extra_deps << ["capybara"]
end

desc "Tag the current revision."
task :tag do
  message = "Released test-unit-capybara #{version}!"
  sh 'git', 'tag', '-a', version, '-m', message
end

# vim: syntax=Ruby
