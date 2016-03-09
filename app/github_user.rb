require 'ostruct'
require 'open-uri'
require 'nokogiri'

class GitHubUser
  attr_reader :username, :profile

  def initialize(username)
    @username = username
    fetch_profile
  end

  def public_activity
    xml  = Nokogiri::XML.parse(open(public_feed_url)).remove_namespaces!
    html = xml.xpath('//content').map(&:text).map do |text|
      text.gsub!(%Q(href="/), 'href="https://github.com/')
    end
  end

  def contributions_calendar
    cal = Nokogiri::HTML.parse(open(contributions_calendar_svg)).tap do |html|
      html.css('svg.js-calendar-graph-svg').instance_eval do |svg|
        width, height = attribute('width'), attribute('height')
        attr('viewBox', "0 0 #{width} #{height}")
        attr('style', "max-width: #{width}")
        remove_attr('width')
        remove_attr('height')
      end
    end
  end

  def icon
    profile_url + '.png'
  end

  private

  def fetch_profile
    return @profile if instance_variable_defined?(:@profile)

    doc = Nokogiri::HTML.parse(open(profile_url))
    prf = doc.css('ul.vcard-details li').each_with_object({}) do |element, return_hash|
      key = element.css('svg').first.values.find {|v| v =~ /octicon/ }.gsub(/.* octicon-(.+)/, '\1').to_sym
      val = element.inner_text
      return_hash[key] = val
    end
    @profile = OpenStruct.new(prf)
  end

  def public_feed_url
    "https://github.com/#{self.username}.atom"
  end

  def profile_url
    "https://github.com/#{self.username}"
  end

  def contributions_calendar_svg
    "https://github.com/users/#{self.username}/contributions"
  end
end
