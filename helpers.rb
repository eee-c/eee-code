module Eee
  module Helpers
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

    def wiki(text)
      text
    end
  end
end
