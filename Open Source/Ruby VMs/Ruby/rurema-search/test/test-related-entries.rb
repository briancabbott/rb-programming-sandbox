# Copyright (C) 2010  Kouhei Sutou <kou@clear-code.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

class RelatedEnetriesTest < Test::Unit::TestCase
  include RuremaSearchTestUtils

  def test_not_show_drilldowned_entry_link
    visit "/class:File/"
    assert_equal([], related_entry_links("/class:File/"))
  end

  def test_remove_same_type_drilldown
    visit "/query:File.lstat/"
    links = related_entry_links("/query:File.stat/")
    assert_equal(["File.stat"],
                 links.collect {|link| link.text}.uniq)
  end

  private
  def related_entry_links(href=nil)
    links = page.all(:xpath, "//ul[@class='entry-related-entries']/li/a")
    return links if href.nil?
    links.find_all do |link|
      link["href"] == href
    end
  end
end
