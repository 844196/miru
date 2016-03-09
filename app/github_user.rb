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
    doc = Nokogiri::HTML.parse(open(profile_url))
    cal = doc.css('div.js-calendar-graph').tap do |html|
      html.css('svg.js-calendar-graph-svg').tap do |svg|
        width, height = svg.attribute('width'), svg.attribute('height')
        svg.attr('viewBox', "0 0 #{width} #{height}")
        svg.attr('style', "max-width: #{width}")
        svg.remove_attr('width')
        svg.remove_attr('height')
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
end
