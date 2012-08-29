require 'sinatra'
require 'json'

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
  halt 401, 'You are not authorized.'
end
