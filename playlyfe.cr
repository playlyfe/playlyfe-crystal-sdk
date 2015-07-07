require "http/client"
require "http/headers"
require "json"

alias ReqQuery = Hash(Symbol, String)

class PlaylyfeException < Exception
  getter :name, :message

  def initialize(res)
    @body = res
    @name = res["error"]
    @message = res["error_description"]
    super("#{@name}: #{@message}")
  end

end

class Playlyfe

  def initialize(@client_id = "", @client_secret = "", @type = "client", @version = "v2", @redirect_uri = "", @debug = false, store = nil, load = nil)
    @token_client = HTTP::Client.new("playlyfe.com", ssl: true)
    @api_client = HTTP::Client.new("api.playlyfe.com", ssl: true)
    @code = ""
    @token = {} of String => JSON::Type
    unless store
      @store = ->(token : Hash(String, JSON::Type)) {
        puts "Storing Token"
        @token = token
      }
    end
    if store
      @store = store
    end
    unless load
      @load = -> { @token as Hash }
    else
      @load = load
    end
  end

  def self.createJWT(id, secret, player_id, scopes, expires)
    expires = Time.now.to_i + expires
    # token = JWT.encode({:player_id => player_id, :scopes => scopes, :exp => expires, secret, "HS256")
    # token = "#{:id}:#{token}"
    # token
  end


  def get_access_token
    headers = HTTP::Headers{"Content-Type": "application/json", "Accept": "application/json"}
    body = {
      :client_id => @client_id,
      :client_secret => @client_secret,
      :grant_type => "client_credentials"
    }
    if @type == "code"
      body[:grant_type] = "authorization_code"
      body[:code] = @code
      if @redirect_uri == ""
        raise Exception.new("You need to pass the redirect_uri parameter to the client")
      else
        body[:redirect_uri] = @redirect_uri
      end
    end
    response = @token_client.post("/auth/token", headers, body.to_json)
    token = JSON.parse(response.body) as Hash
    if token["error"]?
      raise PlaylyfeException.new(token)
    end
    expires_at = Time.now.to_i + token["expires_in"] as Int64
    token.delete("expires_in")
    token["expires_at"] = expires_at
    if store = @store
      store.call token
    end
    token
  end

  def check_token(query)
    if load = @load
      if token = @load.call()
        unless token["access_token"]?
          token = get_access_token()
        end
        query[:access_token] = token["access_token"] as String
        # if token["expires_at"] as Int  < Time.now.to_i
        #   token = get_access_token()
        # end
      else
        token = get_access_token()
      end
    end
  end

  def api(method, route, query = ReqQuery.new, body = ReqQuery.new, raw = false)
    check_token(query)
    headers = HTTP::Headers{"Content-Type": "application/json", "Accept": "application/json"}
    route = "/#{@version}#{route}?#{query.map{|k,v| "#{k}=#{v}"}.join("&")}"
    if @debug
      puts "#{method} #{route} #{body.to_json}"
    end
    case method
    when "POST"
      res = @api_client.post(route, headers, body.to_json)
    when "PATCH"
      res = @api_client.patch(route, headers, body.to_json)
    when "PUT"
      res = @api_client.put(route, headers, body.to_json)
    when "DELETE"
      res = @api_client.delete(route, headers)
    else
      res = @api_client.get(route, headers)
    end
    if raw
      return res.body
    else
      result = JSON.parse(res.body) as Hash
      if result["error"]?
        raise PlaylyfeException.new(result)
      else
        return result
      end
    end
  end

  def get(route, query = ReqQuery.new)
    api("GET", route, query, nil, false)
  end

  def get_raw(route, query = ReqQuery.new)
    api("GET", route, query, nil, true)
  end

  def post(route, query = ReqQuery.new, body = ReqQuery.new)
    api("POST", route, query, body, false)
  end

  def put(route, query = ReqQuery.new, body = ReqQuery.new)
    api("PUT", route, query, body, false)
  end

  def patch(route, query = ReqQuery.new, body = ReqQuery.new)
    api("PATCH", route, query, body, false)
  end

  def delete(route, query = ReqQuery.new)
    api("DELETE", route, query, nil, false)
  end
end
