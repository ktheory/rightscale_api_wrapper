require 'base64'
begin
  require 'curb'
rescue LoadError
  puts "Could not load curb (Libcurl bindings for Ruby)"
  puts "Run $ gem install curb"
  raise
end

class RightScale
  API_VERSION = "1.0"

  attr_reader :account_id, :email, :password
  def initialize(account_id, email, password)
    @account_id = account_id
    @email = email
    @password = password
    @authenticated = false

    @c = Curl::Easy.new do |c|
      c.enable_cookies = true
      c.cookiejar = "/tmp/rightscale.cookie"
      c.headers["X-API-VERSION"] = API_VERSION
      c.verbose = $DEBUG

      # Using c.userpwd doesn't work (!?) but setting the Authorization header does
      #c.userpwd = "#{email}:#{password}"
      c.headers['Authorization'] = "Basic %s" % Base64.encode64("#{email}:#{password}").strip
    end
    authenticate!
    self
  end

  def authenticated?
    @authenticated
  end

  def list_servers
    get "https://my.rightscale.com/api/acct/#{account_id}/servers.xml"
  end

  def list_deployments
    get "https://my.rightscale.com/api/acct/#{account_id}/deployments.xml"
  end
    
  end

  def get(url)
    @c.url = url
    @c.http_get
    @c.body_str
  end

  private

  def authenticate!
    get "https://my.rightscale.com/api/acct/#{account_id}/#{login}"
    @authenticated = true
  end

end

