require 'sinatra'
require 'json'
require 'rest_client'
require 'logger'

set :api, {
  :prefix => "https://appsapi.edmodobox.com/",
  :version => "v1",
  :key => "***REMOVED***"
}

# log what RestClient does
RestClient.log = Logger.new(STDOUT)

get '/' do
  "Hello, world"
end

post '/install' do
  install = JSON.parse params[:install], :symbolize_names => true
  logger.info "Install request received"
  logger.info "  install key: #{install[:install_key]}"
  logger.info "  user token: #{install[:user_token]}"
  logger.info "  groups:"
  install[:groups].each do |group|
  	logger.info "    " + group
  end

  content_type :json
  return { :status => "success" }.to_json
end


post '/app' do
  launch_key = params[:launch_key]
  if launch_key_valid?(launch_key)
    haml :index
  else
    halt 401, 'You are not authorized.'
  end
end


helpers do
  def launch_key_valid?(launch_key)
    api = settings.api

    begin
      response = RestClient.get "#{api[:prefix]}/#{api[:version]}/launchRequests", 
        {:params => {:api_key => api[:key], :launch_key => launch_key}}
    rescue => e
      return false
    end

    logger.info "launch request response:"
    logger.info response.to_str
    response.code == 200
  end
end
