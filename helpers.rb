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

    def wiki(original)
      text = (original || '').dup
      text.gsub!(/\b(\d+)F/, "\\1° F")
      text.gsub!(/\[kid:(\w+)\]/m) { |kid| kid_nicknames[$1] }
      text.gsub!(/\[recipe:(\S+)\]/m) { |r| recipe_link($1) }
      text.gsub!(/\[recipe:(\S+)\s(.+?)\]/m) { |r| recipe_link($1, $2) }
      text.gsub!(/\[meal:(\S+)\]/m) { |m| meal_link($1) }
      text.gsub!(/\[meal:(\S+)\s(.+?)\]/m) { |m| meal_link($1, $2) }
      RedCloth.new(text).to_html
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

    def recipe_link(link, title=nil)
      permalink = link.gsub(/\//, '-')
      recipe = JSON.parse(RestClient.get("#{_db}/#{permalink}"))
      %Q|<a href="/recipes/#{recipe['_id']}">#{title || recipe['title']}</a>|
    end

    def meal_link(link, title=nil)
      permalink = link.gsub(/\//, '-')
      title ||= JSON.parse(RestClient.get("#{_db}/#{permalink}"))['title']
      %Q|<a href="/meals/#{link}">#{title}</a>|
    end

    def image_link(doc, options={ })
      return nil unless doc['_attachments']

      filename = doc['_attachments'].
        keys.
        detect{ |f| f =~ /jpg/ }

      return nil unless filename

      attrs = options.map{|kv| %Q|#{kv.first}="#{kv.last}"|}.join(" ")
      %Q|<img #{attrs} src="/images/#{doc['_id']}/#{filename}"/>|
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

      start_window = current_page < 3 ? 1 : current_page - 3
      links << (start_window...current_page).map { |p| page_link(link, p) }

      links << %Q|<span class="current">#{current_page}</span>|

      links << (current_page+1...last_page).map { |p| page_link(link, p) }

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
        ""
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
            item.description = record['summary']

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
