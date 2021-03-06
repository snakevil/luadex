cosmo = require 'cosmo'
ViewNode = require 'view/node'

--- 影片索引节点视图组件
-- @module view/movieset
-- @author Snakevil Zen <zsnakevil@gmail.com>
-- @copyright 2017 SZen.in
-- @license GPL-3.0+
-- @class ViewMovieSet
class ViewMovieSet extends ViewNode
    --- 是否使用瀑布流式列表布局
    -- @field
    masonry: true

    --- 定制页面内容块代码
    -- @function body
    -- @int[opt] birthday
    -- @return string
    -- @usage html = view:body()
    body: (birthday) =>
        cosmo.fill [=[
$cond_movies[[
  $yield_years[[
    <h2>
      <span class="label label-info pull-right">$size</span>
      $year
      $if{ $age }[[
        <span class="small">$age</span>
      ]]
    </h2>
    <ul class="list-unstyled row -list">
      $movies[[
        <li class="col-xs-6 col-sm-4 col-lg-3 -item">
          <a class="thumbnail" href="$uri" style="background-image:url($uri./cover.jpg)">
            <img src="$uri./cover.jpg">
          </a>
        </li>
      ]]
    </ul>
  ]]
]]
]=],
            if: cosmo.cif
            cond_movies: do
                movies = @node\children!
                table.sort movies, (one, another) ->
                    one_time = os.date '%s', one.meta.date
                    another_time = os.date '%s', another.meta.date
                    one_time > another_time
                cosmo.cond 0 < #movies,
                    yield_years: ->
                        years = {}
                        ymovies = {}
                        born = if birthday
                            os.date '%Y', birthday
                        for movie in *movies
                            year = os.date '%Y', movie.meta.date
                            if not ymovies[year]
                                table.insert years, year
                                ymovies[year] = {}
                            table.insert ymovies[year], movie
                        for year in *years
                            cosmo.yield
                                :year
                                age: if born
                                    '/' .. (year - born) .. 'y'
                                movies: ymovies[year]
                                size: #ymovies[year]
