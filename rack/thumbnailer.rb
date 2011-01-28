require 'image_science'
require 'mime/types'

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

        unless ::File.exists?(filename)
          image = rack_image(@app, env)
          mk_thumbnail(filename, image)
        end

        thumbnail = ::File.new(filename).read
        [200, { "Content-Type" => content_type(filename) }, thumbnail]
      else
        @app.call(env)
      end
    end

    private
    def rack_image(app, env)
      http_code, headers, body = app.call(env)

      img_data = ''
      body.each do |data|
        img_data << data
      end
      img_data
    end

    def content_type(filename)
      type = MIME::Types.type_for(filename).first.to_s
      (type && type != '') ? type : nil
    end

    def mk_thumbnail(filename, image_data)
      path = filename.sub(/\/[^\/]+$/, '')
      FileUtils.mkdir_p(path)

      ImageScience.with_image_from_memory(image_data) do |img|
        img.thumbnail(200) do |small|
          small.save filename
        end
      end
    end
  end
end
