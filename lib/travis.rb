require 'psych'
require 'net/http'
require 'uri'
require 'date'
require 'json'

class Travis
  def latest_builds
    uri = URI('http://travis-ci.org/rails/rails/builds.json')

    builds = Psych.load Net::HTTP.get_response(uri).body
    builds.map { |x| Build.new x, self }
  end

  def after number
    uri = 'http://travis-ci.org/rails/rails/builds.json?'
    uri << "after_number=#{number}"
    uri = URI(uri)

    Psych.load Net::HTTP.get_response(uri).body
  end

  def latest number
    uri = URI('http://travis-ci.org/rails/rails/builds.json')
    builds = Psych.load Net::HTTP.get_response(uri).body

    while builds.length < number
      builds.concat after(builds.last['number'])
    end

    builds.first(number)
  end

  def details id
    uri = URI("http://travis-ci.org/rails/rails/builds/#{id}.json")
    body = Net::HTTP.get_response(uri).body
    Psych.load body
  end
end
