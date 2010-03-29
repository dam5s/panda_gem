require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Panda do
  before(:each) do
    FakeWeb.allow_net_connect = false
    Time.stub!(:now).and_return(mock("time", :iso8601 => "2009-11-04T17:54:11+00:00"))
  end

  describe "Connected", :shared => true do

    it "should make get request with signed request to panda server" do
      FakeWeb.register_uri(:get, "http://myapihost:85/v2/videos?timestamp=2009-11-04T17%3A54%3A11%2B00%3A00&signature=CxSYPM65SeeWH4CE%2FLcq7Ny2NtwxlpS8QOXG2BKe4p8%3D&access_key=my_access_key&cloud_id=my_cloud_id", :body => "abc")
      @panda.get("/videos").should == "abc"
    end

    it "should make delete request with signed request to panda server" do
      FakeWeb.register_uri(:delete, "http://myapihost:85/v2/videos/1?timestamp=2009-11-04T17%3A54%3A11%2B00%3A00&signature=t0IYclDXgjZFRYaMf0Gbg%2B5vOqp7q8QQRN8tlQ3bk8Q%3D&access_key=my_access_key&cloud_id=my_cloud_id", :query => {})
      @panda.delete("/videos/1").should
      FakeWeb.should have_requested(:delete, "http://myapihost:85/v2/videos/1?timestamp=2009-11-04T17%3A54%3A11%2B00%3A00&signature=t0IYclDXgjZFRYaMf0Gbg%2B5vOqp7q8QQRN8tlQ3bk8Q%3D&access_key=my_access_key&cloud_id=my_cloud_id")
    end

    it "should create a signed version of the parameters" do
      signed_params = @panda.signed_params('POST',
                                           '/videos.json',
                                           {"param1" => 'one', "param2" => 'two'}
                                           )
      signed_params.should == {
        'access_key' => "my_access_key",
        'timestamp' => "2009-11-04T17:54:11+00:00",
        'cloud_id' => 'my_cloud_id',
        'signature' => 'w66goW6Ve5CT9Ibbx3ryvq4XM8OfIfSZe5oapgZBaUs=',
        'param1' => 'one',
        'param2' => 'two'
      }
    end

    it "should create a signed version of the parameters without additional arguments" do
      @panda.signed_params('POST', '/videos.json').should == {
        'access_key' => "my_access_key",
        'timestamp' => "2009-11-04T17:54:11+00:00",
        'cloud_id' => 'my_cloud_id',
        'signature' => 'TI2n/dsSllxFhxcEShRGKWtDSqxu+kuJUPs335NavMo='
      }
    end


    it "should create a signed version of the parameters and difficult characters" do
      signed_params = @panda.signed_params('POST',
                                           '/videos.json',
                                           {"tilde" => '~', "space" => ' '}
                                           )
      signed_params.should == {
        'access_key' => "my_access_key",
        'timestamp' => "2009-11-04T17:54:11+00:00",
        'cloud_id' => 'my_cloud_id',
        'signature' => 'w5P9+xPpQpRlweTh0guFYqQOmF+ZuTKXCmaKpUP3sH0=',
        'tilde' => '~',
        'space' => ' '
      }
    end

    it "should return a json file for every http code" do
      FakeWeb.register_uri(:get, "http://myapihost:85/v2/videos?timestamp=2009-11-04T17%3A54%3A11%2B00%3A00&signature=CxSYPM65SeeWH4CE%2FLcq7Ny2NtwxlpS8QOXG2BKe4p8%3D&access_key=my_access_key&cloud_id=my_cloud_id", :body => "abc")

      resource = RestClient::Resource.new("http://myapihost:85/v2")
      RestClient::Resource.stub!(:new).and_return(resource)

      e = RestClient::Exception.new({:body => "abc", :code => 400})
      e.stub!(:http_body).and_return("abc")

      resource.stub!(:get).and_raise(e)

      panda = Panda::Connection.new({"access_key" => "my_access_key", "secret_key" => "my_secret_key", "api_host" => "myapihost", "api_port" => 85, "cloud_id" => 'my_cloud_id' })
      panda.get("/videos").should == "abc"
    end
  end
  
  describe "Connected with a string url" do
    before(:each) do
      @panda = Panda::Connection.new('http://my_access_key:my_secret_key@myapihost:85/my_cloud_id')
    end
    
    it_should_behave_like "Connected"
  end
  
  describe "Panda.connect " do
    before(:each) do
      Panda.connect!({"access_key" => "my_access_key", "secret_key" => "my_secret_key", "api_host" => "myapihost", "api_port" => 85, "cloud_id" => 'my_cloud_id' })
      @panda = Panda
    end
   it_should_behave_like "Connected"
  end

  describe "Panda.connect with PANDASTREAM_URL" do
     before(:each) do
       Panda.connect!('http://my_access_key:my_secret_key@myapihost:85/my_cloud_id')
       @panda = Panda
     end
    it_should_behave_like "Connected"
  end
  describe "Panda::Connection.new" do
     before(:each) do
       @panda = Panda::Connection.new({"access_key" => "my_access_key", "secret_key" => "my_secret_key", "api_host" => "myapihost", "api_port" => 85, "cloud_id" => 'my_cloud_id' })
     end
    it_should_behave_like "Connected"
  end
  
end
