require 'sinatra'
require 'sinatra/config_file'
require 'sinatra/reloader' if development?

require_relative 'app/github_user'

register Sinatra::ConfigFile
config_file 'config.yml'

members = settings.members.map do |name|
  GitHubUser.new(name)
end

get '/' do
  @members = members
  haml :index
end
