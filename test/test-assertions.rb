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

  class AllTest < self
    setup do
      @html = <<-HTML
<html>
  <body>
    <h1>Hello</h1>
    <h2>Yay!</h2>
    <div class="section">
      <h2>World</h2>
    </div>
  </body>
</html>
HTML
      Capybara.app = lambda do |environment|
        [
          200,
          {"Content-Type" => "text/html"},
          [@html],
        ]
      end
    end

    def test_no_kind
      visit("/")
      h2s = assert_all("h2")
      assert_equal(["Yay!", "World"], h2s.collect(&:text))
    end

    def test_css
      visit("/")
      h2s = assert_all(:css, "h2")
      assert_equal(["Yay!", "World"], h2s.collect(&:text))
    end

    def test_xpath
      visit("/")
      h2s = assert_all(:xpath, "//h2")
      assert_equal(["Yay!", "World"], h2s.collect(&:text))
    end

    def test_node
      visit("/")
      section = assert_find("div.section")
      h2s = assert_all(section, "h2")
      assert_equal(["World"], h2s.collect(&:text))
    end

    def test_fail
      visit("/")
      message = <<-EOM.strip
<"h3">(:css) expected to be match one or more elements in
<#{PP.pp(@html, "").chomp}>
EOM
      exception = Test::Unit::AssertionFailedError.new(message)
      assert_raise(exception) do
        assert_all("h3")
      end
    end
  end

  class FindTest < self
    setup do
      @html = <<-HTML
<html>
  <body>
    <h1>Hello</h1>
    <h2>Yay!</h2>
    <div class="section">
      <h2>World</h2>
    </div>
  </body>
</html>
HTML
      Capybara.app = lambda do |environment|
        [
          200,
          {"Content-Type" => "text/html"},
          [@html],
        ]
      end
    end

    class WithoutNodeTest < self
      def test_no_kind
        visit("/")
        h2 = assert_find("h2")
        assert_equal("Yay!", h2.text)
      end

      def test_css
        visit("/")
        h2 = assert_find(:css, "h2")
        assert_equal("Yay!", h2.text)
      end

      def test_xpath
        visit("/")
        h2 = assert_find(:xpath, "//h2")
        assert_equal("Yay!", h2.text)
      end

      def test_block
        visit("/")
        assert_find("div.section") do
          h2 = assert_find("h2")
          assert_equal("World", h2.text)
        end
      end

      def test_fail
        visit("/")
        message = <<-EOM.strip
<"h3">(:css) expected to be match a element in
<#{PP.pp(@html, "").chomp}>
EOM
        exception = Test::Unit::AssertionFailedError.new(message)
        assert_raise(exception) do
          assert_find("h3")
        end
      end
    end

    class WithNodeTest < self
      def test_no_kind
        visit("/")
        section = assert_find("div.section")
        h2 = assert_find(section, "h2")
        assert_equal("World", h2.text)
      end

      def test_css
        visit("/")
        section = assert_find("div.section")
        h2 = assert_find(section, :css, "h2")
        assert_equal("World", h2.text)
      end

      def test_xpath
        visit("/")
        section = assert_find("div.section")
        h2 = assert_find(section, :xpath, "//h2")
        assert_equal("Yay!", h2.text)
      end

      def test_block
        visit("/")
        section = assert_find("div.section")
        assert_find(section, "h2") do
          assert_equal("World", text)
        end
      end

      def test_fail
        visit("/")
        section = assert_find("div.section")
        section_html = @html.scan(/<div class="section">.*?<\/div>/m)[0]
        message = <<-EOM.strip
<"h3">(:css) expected to be match a element in
<#{PP.pp(section_html, "").chomp}>
EOM
        exception = Test::Unit::AssertionFailedError.new(message)
        assert_raise(exception) do
          assert_find(section, "h3")
        end
      end
    end
  end
end
