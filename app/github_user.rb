require 'open-uri'
require 'nokogiri'

class GitHubUser
  attr_reader :username

  def initialize(username)
    @username = username
  end

  def public_feed
    xml  = Nokogiri::XML(open(public_feed_url).read).remove_namespaces!
    html = xml.xpath('//content').map(&:text)
  end

  private

  def public_feed_url
    "https://github.com/#{self.username}.atom"
  end
end
