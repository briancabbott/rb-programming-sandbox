# -*- coding: utf-8 -*-
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

class QueryParameterTest < Test::Unit::TestCase
  include RuremaSearchTestUtils
  include ERB::Util

  def test_post_euc_jp
    page.driver.post("/",
                     :query => "クラス変数".encode("euc-jp"),
                     :encoding => "euc-jp")
    assert_equal("#{host}/query:#{u('クラス変数')}/", current_url)
  end

  def test_get
    visit "/?query=#{u("クラス変数")}"
    assert_equal("#{host}/query:#{u('クラス変数')}/", current_url)
  end
end
