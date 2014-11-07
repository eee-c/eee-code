# -*- coding: utf-8 -*-
module Eee
  module Helpers
    require 'RedCloth'

    def hours(minutes)
      h = minutes.to_i / 60
      m = minutes.to_i % 60
      h > 0 ? "#{h} hours" : "#{m} minutes"
    end

    def amazon_url(asin)
      "http://www.amazon.com/exec/obidos/ASIN/#{asin}/eeecooks-20"
    end

    def categories(context)
      categories = %w{Italian Asian Latin Breakfast Chicken Fish Meat Salad Vegetarian}

      links = categories.map do |category|
        %Q|<li>#{recipe_category_link(context, category)}</li>|
      end

      links << %Q|<li><a href="/recipes/search?q=">Recipes</a></li>|

      %Q|<ul id="eee-categories">#{links}</ul>|
    end

    def recipe_category_link(recipe, category)
      recipes = recipe.is_a?(Array) ? recipe : [recipe]
      href = "/recipes/search?q=category:#{category.downcase}"
      if recipes.any? { |r|
          r['tag_names'] &&
          r['tag_names'].include?(category.downcase)
        }
        %Q|<a class="active" href="#{href}">#{category}</a>|
      else
        %Q|<a href="#{href}">#{category}</a>|
      end
    end

    def wiki(original, convert_textile=true)
      text = (original || '').dup
      text.gsub!(/\b(\d+)F/, "\\1° F")
      text.gsub!(/\[kid:(\w+)\]/m) { |kid| kid_nicknames[$1] }
      text.gsub!(/\[recipe:(\S+)\]/m) { |r| recipe_link($1) }
      text.gsub!(/\[recipe:(\S+)\s(.+?)\]/m) { |r| recipe_link($1, $2) }
      text.gsub!(/\[meal:(\S+)\]/m) { |m| meal_link($1) }
      text.gsub!(/\[meal:(\S+)\s(.+?)\]/m) { |m| meal_link($1, $2) }
      if convert_textile
        textile = RedCloth.new(text)
        textile.hard_breaks = false
        textile.to_html
      else
        text
      end
    end

    def kid_nicknames
      @@kid_kicknames ||= JSON.parse(RestClient.get("#{_db}/kids"))
    end

    def _db
      self.class.send(:class_variable_get, "@@db")
    end

    def wiki_recipe(text)
      if text =~ /\[recipe:([-\/\w]+)/
        permalink = $1.gsub(/\//, '-')
        JSON.parse(RestClient.get("#{_db}/#{permalink}"))
      end
    end

    def url_from_permalink(permalink)
      permalink.split(/-/, 4).join('/')
    end

    def recipe_link(link, title=nil)
      permalink = link.gsub(/\//, '-')
      recipe = JSON.parse(RestClient.get("#{_db}/#{permalink}"))
      url = "/recipes/" + url_from_permalink(recipe['_id'] || recipe['id'])
      %Q|<a href="#{url}">#{title || recipe['title']}</a>|
    end

    def meal_link(link, title=nil)
      permalink = link.gsub(/\//, '-')
      title ||= JSON.parse(RestClient.get("#{_db}/#{permalink}"))['title']
      %Q|<a href="/meals/#{link}">#{title}</a>|
    end

    def image_link(doc, options={ }, query_params={ })
      return nil unless doc['_attachments']

      filename = doc['_attachments'].
        keys.
        detect{ |f| f =~ /jpg/ }

      return nil unless filename

      attrs = options.map{|kv| %Q|#{kv.first}="#{kv.last}"|}.join(" ")
      query = query_params.empty? ? "" : "?" + Rack::Utils.build_query(query_params)
      %Q|<img #{attrs} src="/images/#{doc['_id'] || doc['id']}/#{filename}#{query}"/>|
    end

    def pagination(query, results)
      total = results['total_rows']
      limit = results['limit']
      skip  = results['skip']

      last_page    = (total + limit - 1) / limit
      current_page = skip / limit + 1

      link = base_pagination_link(query, results)

      links = []
      links << edge_page_link(current_page == 1, link, current_page-1, "&laquo; Previous")

      links << page_link(link, 1) if current_page != 1

      start_window = current_page > 4 ? current_page - 3 : 2
      links << "..." if start_window > 2
      links << (start_window...current_page).map { |p| page_link(link, p) }

      links << %Q|<span class="current">#{current_page}</span>|

      end_window = current_page + 3 < last_page ? current_page + 3 : last_page - 1
      links << (current_page+1..end_window).map { |p| page_link(link, p) }
      links << "..." if end_window < last_page - 1

      links << page_link(link, last_page) if current_page != last_page

      links << edge_page_link(current_page == last_page, link, current_page+1, "Next &raquo;")

      %Q|<div class="pagination">#{links.join}</div>|
    end

    def base_pagination_link(query, results)
      link = "/recipes/search?q=#{query}"

      if results['sort_order']
        link += "&sort=#{results['sort_order'].first['field']}"
        if results['sort_order'].first['reverse']
          link += "&order=desc"
        end
      end
      return link
    end

    def edge_page_link(disabled, link, page, text)
      disabled ?
        %Q|<span class="inactive">#{text}</span>| :
        page_link(link, page, text)
    end

    def page_link(link, page, text=nil)
      %Q|<a href="#{link}&page=#{page}">#{text || page}</a>|
    end

    def sort_link(text, sort_field, results, options = { })
      id  = "sort-by-#{text.downcase}"

      query = options[:query] || results['query']

      # Current state of sort on the requested field
      sort_field_current =
        results["sort_order"] &&
        results["sort_order"].detect { |sort_options|
        sort_options["field"] == sort_field
      }

      if sort_field_current
        order = sort_field_current["reverse"] ? "" : "&order=desc"
      elsif options[:reverse]
        order = "&order=desc"
      end

      url = "/recipes/search?q=#{query}&sort=#{sort_field}#{order}"
      %Q|<a href="#{url}" id="#{id}">#{text}</a>|
    end

    # TODO: use CouchDB view directly here, with limit=1 to determine
    # the next record
    def link_to_adjacent_view_date(current, couch_view, options={})
      # If looking for the record previous to this one, then we seek a
      # date prior to the current one - build a Proc capable of
      # finding that
      compare = options[:previous] ?
        Proc.new { |date_fragment, current| date_fragment < current} :
        Proc.new { |date_fragment, current| date_fragment > current}

      # If looking for the record previous to this one, then we need
      # to reverse the list before using the compare Proc to detect
      # the record
      next_result = couch_view.
        send(options[:previous] ? :reverse : :map).
        detect{|result| compare[result['key'], current.to_s]}

      # If a next record was found, then return link text - either by
      if next_result
        if block_given?
          yield next_result['key'], next_result['value']
        else
          next_uri = next_result['key'].gsub(/-/, '/')
          %Q|<a href="/meals/#{next_uri}">#{next_result['key']}</a>|
        end
      else
        nil
      end
    end

    def month_text(date_frag)
      Date.parse("#{date_frag}-01").strftime("%B %Y")
    end

    def breadcrumbs(date, context=nil)
      crumbs = [ %Q|<a href="/">home</a>| ]

      if context == :year
        crumbs << %Q|<span>#{date.year}</span>|
      else
        crumbs << %Q|<a href="/meals/#{date.year}">#{date.year}</a>|
      end

      if context == :month
        crumbs << %Q|<span>#{date.strftime("%B")}</span>|
      elsif context == :day || context == nil
        crumbs << %Q|<a href="#{date.strftime("/meals/%Y/%m")}">#{date.strftime("%B")}</a>|
      end

      if context == :day
        crumbs << %Q|<span>#{date.day}</span>|
      elsif context == nil
        crumbs << %Q|<a href="#{date.strftime("/meals/%Y/%m/%d")}">#{date.day}</a>|
      end

      crumbs.join(" &gt; ")
    end

    def google(term)
      query = Rack::Utils.escape(term)
      "Search " +
        %Q|<span class="google">| +
        %Q|<span class="blue">G</span>| +
        %Q|<span class="red">o</span>| +
        %Q|<span class="yellow">o</span>| +
        %Q|<span class="blue">g</span>| +
        %Q|<span class="green">l</span>| +
        %Q|<span class="red">e</span>| +
        %Q|</span>| +
        %Q| for other | +
        %Q|<a href="http://www.google.com/search?q=#{query}">| +
        term +
        %Q|</a>|
    end

    def google_ads
      <<_EOM
<div id="eee-google-ads">
<script type="text/javascript"><!--
google_ad_client = "pub-2549261339485273";
google_ad_width = 728;
google_ad_height = 90;
google_ad_format = "728x90_as";
google_color_border = "CCCCCC";
google_color_bg = "FFFFFF";
google_color_link = "000000";
google_color_url = "666666";
google_color_text = "333333";
//--></script>
<script type="text/javascript" src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
</script>
</div>
_EOM
    end

    def amazon_cookbook(keyword)
      %Q|<a href="http://www.amazon.com/gp/search?ie=UTF8&keywords=#{Rack::Utils.escape(keyword)}%20cookbook&tag=eeecooks-20&index=books&linkCode=ur2&camp=1789&creative=9325">#{keyword.capitalize}</a>|
    end

    def couch_recipe_update_of(permalink)
      url = "#{_db}/_design/recipes/_view/update_of?key=%22#{permalink}%22"
      data = RestClient.get url
      results = JSON.parse(data)['rows']
      results.first && results.first['value']
    end

    def recipe_update_of(permalink)
      previous = couch_recipe_update_of(permalink)
      if previous
        links = previous.map do |update_permalink|
          date_str = Date.parse(update_permalink).strftime("%B %e, %Y")
          url = "/recipes/" + url_from_permalink(update_permalink)
          %Q|<a href="#{url}">#{date_str}</a>|
        end

        %Q|<span class="update-of">| +
          %Q|This is an update of a previous recipe: | +
          links.join(", ") +
          %Q|</span>|
      end
    end

    def couch_recipe_updated_by(permalink)
      url = "#{_db}/_design/recipes/_view/updated_by?key=%22#{permalink}%22"
      data = RestClient.get url
      results = JSON.parse(data)['rows']
      results.first && results.first['value']
    end

    def recipe_updated_by(permalink)
      update = couch_recipe_updated_by(permalink)
      if update
        date_str = Date.parse(update).strftime("%B %e, %Y")
        link = %Q|<a href="/recipes/#{update}">#{date_str}</a>|

        %Q|<span class="update">| +
          %Q|This recipe has been updated: | +
          link +
          %Q|</span>|
      end
    end

    def couch_alternatives(permalink)
      url = "#{_db}/_design/recipes/_view/alternatives?key=%22#{permalink}%22"
      data = RestClient.get url
      results = JSON.parse(data)['rows']
      results.first && results.first['value']
    end

    def alternate_preparations(permalink)
      ids = couch_alternatives(permalink)
      if ids && ids.size > 0
        %Q|<span class="label">Alternate Preparations:</span> | +
        couch_recipe_titles(ids).
          map{ |recipe| %Q|<a href="/recipes/#{url_from_permalink(recipe[:id])}">#{recipe[:title]}</a>|}.
          join(", ")
      end
    end

    def couch_recipe_titles(ids)
      data = RestClient.post "#{_db}/_design/recipes/_view/titles",
        %Q|{"keys":[#{ids.map{|id| "\"#{id}\""}.join(',')}]}|

      JSON.parse(data)['rows'].map do |recipe|
        { :id => recipe["id"], :title => recipe["value"] }
      end
    end

    def rss_for_date_view(feed)
      url = "#{_db}/_design/#{feed}/_view/by_date?limit=10&descending=true"
      data = RestClient.get url
      view = JSON.parse(data)['rows']

      rss = RSS::Maker.make("2.0") do |maker|
        maker.channel.title = "EEE Cooks: #{feed.capitalize}"
        maker.channel.link  = ROOT_URL
        maker.channel.description = "#{feed.capitalize} from a Family Cookbook"

        view.each do |couch_rec|
          data = RestClient.get "#{_db}/#{couch_rec['id']}"
          record = JSON.parse(data)
          maker.items.new_item do |item|
            item.title = record['title']
            item.pubDate = Time.parse(record['date'])
            item.description = wiki record['summary']

            yield item, record
          end
        end
      end

      rss.to_s
    end

    # Swiped from the Sinatra Book
    # Usage: partial :foo
    def partial(page, options={})
      haml page, options.merge!(:layout => false)
    end
  end
end
