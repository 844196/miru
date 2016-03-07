require 'sinatra'
require 'sinatra/config_file'
require 'sinatra/reloader' if development?

require_relative 'app/github_user'

register Sinatra::ConfigFile
config_file 'config.yml'

get '/' do
  @members = settings.members.map do |name|
    GitHubUser.new(name)
  end
  haml :index
end
