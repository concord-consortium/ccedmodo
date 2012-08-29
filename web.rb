require 'sinatra'

get '/' do
  logger.info "Serving Hello, world page at /"
  "Hello, world"
end
