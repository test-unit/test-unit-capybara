# -*- ruby -*-
#
# Copyright (C) 2012  Kouhei Sutou <kou@clear-code.com>
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

require "test-unit-capybara-test-utils"

class AssertionsTest < Test::Unit::TestCase
  include Capybara::DSL

  class BodyTest < self
    setup do
      Capybara.app = lambda do |environment|
        [
          200,
          {"Content-Type" => "application/json"},
          [JSON.generate({"status" => true})],
        ]
      end
    end

    def test_with_shortcut_content_type
      visit("/")
      assert_page_body({"status" => true}, :content_type => :json)
    end

    def test_without_content_type
      visit("/")
      assert_page_body({"status" => true})
    end
  end
end
