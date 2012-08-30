require 'sinatra'
require 'json'
require 'rest_client'
require 'haml'

enable :sessions

set :api, {
  :prefix => "https://appsapi.edmodobox.com",
  :version => "v1",
  :key => "***REMOVED***"
}

# We very much need NOT to send X-Frame-Options: sameorigin (the Sinatra default)
# Also see https://groups.google.com/forum/#!topic/rack-devel/se6HN2yL1VE ("attack prevented" was
# showing up in the logs.)
set :protection, :except => [:remote_token, :frame_options]

# this is a Sinatra route condition
set(:authorized) { |value| condition { (session[:authorized] || false) == value } }

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
  check_launch_request params[:launch_key]
  call env.merge('REQUEST_METHOD' => 'GET')
end


get '/app', :authorized => true do
  haml :index, :locals => { :name => user_name, :interactive => params[:interactive] || '', :assignments => assignments }
end


get '/app', :authorized => false do
  interactive = params[:interactive] || 'interactives/add-random-atoms.json'
  logger.info "Rendering index page for interactive #{interactive}"
  haml :index, :locals => { :name => "Bogus unauthorized User", :interactive => interactive, :assignments => assignments }
end


post '/app/library' do
  api = settings.api
  interactive = params[:interactive] || halt(400)

  RestClient.log = logger
  response = RestClient.post "#{api[:prefix]}/#{api[:version]}/addToLibrary",
    {:api_key => api[:key], :user_token => user_token, :resource => app_link(interactive).to_json}

  redirect to("/app?interactive=#{interactive}")
end


post '/app/assignment' do
  assignment_id = params[:assignment_id] || halt(400)
  interactive = params[:interactive]     || halt(400)
  description = params[:description]

  api = settings.api
  response = RestClient.post "#{api[:prefix]}/#{api[:version]}/turnInAssignment", {
    :api_key => api[:key],
    :user_token => user_token,
    :assignment_id => assignment_id,
    :content => description,
    :attachments => [app_link(interactive)].to_json
  }

  redirect to("/app?interactive=#{interactive}")
end


helpers do

  def check_launch_request(launch_key)
    api = settings.api

    begin
      logger.info "about to GET the launchRequests resource"
      # not sure how to get access to the logger outside of request scope
      RestClient.log = logger
      response = RestClient.get "#{api[:prefix]}/#{api[:version]}/launchRequests",
        {:params => {:api_key => api[:key], :launch_key => launch_key}}
    rescue => e
      logger.info "error response: "
      logger.info e.response
      session[:authorized] = false
      return
    end

    logger.info "launch request response:"
    logger.info response.to_str
    session[:authorized] = true
    session[:launch_info] = JSON.parse response, :symbolize_names => true
  end

  def launch_info
    session[:launch_info]
  end

  def user_name
    launch_info[:first_name] + " " + launch_info[:last_name]
  end

  def user_token
    launch_info[:user_token]
  end

  def student?
    launch_info && launch_info[:user_type] == 'STUDENT'
  end

  def assignments
    return [] if !student?
    api = settings.api
    response = RestClient.get "#{api[:prefix]}/#{api[:version]}/assignmentsComingDue",
      {:params => {:api_key => api[:key], :user_token => user_token}}
    JSON.parse response, :symbolize_names => true
  end

  def app_link(interactive)
    {
      :type => 'link',
      :title => interactive,
      :url => "app://?interactive=#{interactive}",
      :description => 'Next Gen MW Interactive',
      :thumb_url => 'http://ccedmodo.herokuapp.com/logo.png'
    }
  end

end
