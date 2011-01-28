require 'rspec'
require 'rack/test'
require 'rack/thumbnailer'
require 'webrat'

def app
  target_app = mock("Target Rack Application", :call => [200, { }, "Target app"])

  @app ||= Rack::ThumbNailer.new(target_app)
end

describe "ThumbNailer" do
  include Rack::Test::Methods
  include Webrat::Matchers

  context "Accessing a non-image resource" do
    it "should return the target app" do
      get "/foo"
      last_response.body.should contain("Target app")
    end
  end

  context "Accessing an image" do
    context "without thumbnail param" do
      it "should return image directly from the target app" do
        get "/foo.jpg"
        last_response.body.should contain("Target app")
      end
    end

    context "with thumbnail param" do
      before(:each) do
        file = mock("File", :read => "Thumbnail")

        File.stub!(:new).and_return(file)
        File.stub!(:exists?).and_return(false)

        app.stub!(:mk_thumbnail)
        app.stub!(:rack_image).and_return("image data")
      end

      it "should pull the image from the target application" do
        app.should_receive(:rack_image)
        get "/foo.jpg", :thumbnail => 1
      end

      it "should generate a thumbnail" do
        app.
          should_receive(:mk_thumbnail).
          with("/var/cache/rack/thumbnails/foo.jpg", "image data")
        get "/foo.jpg", :thumbnail => 1
      end

      it "should return a thumbnail" do
        get "/foo.jpg", :thumbnail => 1
        last_response.body.should contain("Thumbnail")
      end

      context "and a previously generated thumbnail" do
        before(:each) do
          File.stub!(:exists?).and_return(true)
        end
        it "should not make a new thumbnail" do
          Rack::ThumbNailer.
            should_not_receive(:mk_thumbnail)
          get "/foo.jpg", :thumbnail => 1
        end
      end
    end
  end
end
