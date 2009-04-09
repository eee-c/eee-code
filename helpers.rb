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
      text = original.dup
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

  end
end
