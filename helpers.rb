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
      RedCloth.new(text).to_html
    end

    def kid_nicknames
      @@kid_kicknames ||= JSON.parse(RestClient.get("#{_db}/kids"))
    end

    def _db
      @@db
    end

    def recipe_link(permalink)
      recipe = JSON.parse(RestClient.get("#{_db}/#{permalink}"))
      %Q|<a href="/recipes/#{recipe['_id']}">#{recipe['title']}</a>|
    end

    def image_link(doc)
      return nil unless doc['_attachments']

      filename = doc['_attachments'].
        keys.
        detect{ |f| f =~ /jpg/ }

      return nil unless filename

      %Q|<img src="/images/#{doc['_id']}/#{filename}"/>|
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

    def sort_link(text, sort_field, query, results)
      id  = "sort-by-#{text.downcase}"

      sort_field_current =
        results["sort_order"] &&
        results["sort_order"].detect { |sort_options|
        sort_options["field"] == sort_field
      }

      sort = sort_field_current.nil? || sort_field_current["reverse"] ?
        sort_field : "#{sort_field}&order=desc"

      url = "/recipes/search?q=#{query}&sort=#{sort}"
      %Q|<a href="#{url}" id="#{id}">#{text}</a>|
    end
  end
end
