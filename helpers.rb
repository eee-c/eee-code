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

    def recipe_category_link(recipe, category)
      if recipe['tag_names'] && recipe['tag_names'].include?(category.downcase)
        %Q|<a class="active">#{category}</a>|
      else
        %Q|<a>#{category}</a>|
      end
    end

    def wiki(original)
      text = (original || '').dup
      text.gsub!(/\b(\d+)F/, "\\1° F")
      text.gsub!(/\[kid:(\w+)\]/m) { |kid| kid_nicknames[$1] }
      text.gsub!(/\[recipe:(\S+)\]/m) { |r| recipe_link($1) }
      text.gsub!(/\[recipe:(\S+)\s(.+?)\]/m) { |r| recipe_link($1, $2) }
      RedCloth.new(text).to_html
    end

    def kid_nicknames
      @@kid_kicknames ||= JSON.parse(RestClient.get("#{_db}/kids"))
    end

    def _db
      self.class.send(:class_variable_get, "@@db")
    end

    def recipe_link(link, title=nil)
      permalink = link.gsub(/\//, '-')
      recipe = JSON.parse(RestClient.get("#{_db}/#{permalink}"))
      %Q|<a href="/recipes/#{recipe['_id']}">#{title || recipe['title']}</a>|
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

      link = "/recipes/search?q=#{query}"

      if results['sort_order']
        link += "&sort=#{results['sort_order'].first['field']}"
        if results['sort_order'].first['reverse']
          link += "&order=desc"
        end
      end

      links = []

      links <<
        if current_page == 1
          %Q|<span class="inactive">&laquo; Previous</span>|
        else
          %Q|<a href="#{link}&page=#{current_page - 1}">&laquo; Previous</a>|
        end

      links << (1..last_page).map do |page|
        if page == current_page
          %Q|<span class="current">#{page}</span>|
        else
          %Q|<a href="#{link}&page=#{page}">#{page}</a>|
        end
      end

      links <<
        if current_page == last_page
          %Q|<span class="inactive">Next »</span>|
        else
          %Q|<a href="#{link}&page=#{current_page + 1}">Next »</a>|
        end

      %Q|<div class="pagination">#{links.join}</div>|
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

    def link_to_adjacent_view_date(current, couch_view, options={})
      compare = options[:previous] ?
        Proc.new { |date_fragment, current| date_fragment < current} :
        Proc.new { |date_fragment, current| date_fragment > current}

      next_result = couch_view.
        send(options[:previous] ? :reverse : :map).
        detect{|result| compare[result['key'], current.to_s]}

      if next_result
        next_uri = next_result['key'].gsub(/-/, '/')
        link_text = block_given? ?
          yield(next_result['key'], next_result['value']) :
          next_result['key']

        %Q|<a href="/meals/#{next_uri}">#{link_text}</a>|
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
  end
end
