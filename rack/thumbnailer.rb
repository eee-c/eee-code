require 'image_science'
require 'pp'

module Rack
  class ThumbNailer
    DEFAULT_CACHE_DIR = '/var/cache/rack/thumbnails'

    def initialize(app, options = { })
      @app = app
      @options = {:cache_dir => DEFAULT_CACHE_DIR}.merge(options)
    end

    def call(env)
      req = Rack::Request.new(env)
      if !req.params['thumbnail'].blank?
        filename = @options[:cache_dir] + req.path_info

        image = ThumbNailer.rack_image(@app, env)
        ThumbNailer.mk_thumbnail(filename, image)

        thumbnail = ::File.new(filename).read
        [200, { }, thumbnail]
      else
        @app.call(env)
      end
    end

    private
    def self.rack_image(app, env)
      http_code, headers, body = app.call(env)

      img_data = ''
      body.each do |data|
        img_data << data
      end
      img_data
    end


    def self.mk_thumbnail(filename, image_data)
      path = filename.sub(/\/[^\/]+$/, '')
      FileUtils.mkdir_p(path)

      ImageScience.with_image_from_memory(image_data) do |img|
        img.resize(200, 150) do |small|
          small.save cache_filename
        end
      end
    end
  end
end
