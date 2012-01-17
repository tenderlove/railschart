require 'psych'
require 'net/http'
require 'uri'
require 'date'
require 'chart'

class Travis
  Build = Struct.new(:internal, :travis) do
    private :internal, :travis

    def id
      internal['id'].to_i
    end

    def branch
      internal['branch']
    end

    def number
      internal['number']
    end

    def details
      @details ||= travis.details id
    end

    def passed?
      details.passed?
    end
  end

  class Command < Struct.new(:start, :finish, :status, :env)
    def start
      DateTime.parse(super).to_time
    end

    def finish
      DateTime.parse(super).to_time
    end

    def duration
      finish - start
    end
  end

  Details = Struct.new(:internal) do
    private :internal

    def commands
      internal['matrix'].first
      internal['matrix'].map { |x|
        c = Command.new(*x.values_at(*%w{ started_at finished_at status }))
        c.env = x['config']['env']
        c
      }
    end

    def passed?
      commands.all? { |x| x.status == 0 }
    end
  end

  def latest_builds
    uri = URI('http://travis-ci.org/rails/rails/builds.json')

    builds = Psych.load Net::HTTP.get_response(uri).body
    builds.map { |x| Build.new x, self }
  end

  def details id
    uri = URI("http://travis-ci.org/rails/rails/builds/#{id}.json")
    body = Net::HTTP.get_response(uri).body
    Details.new Psych.load body
  end
end

t = Travis.new
if File.exists? 'builds.marshal'
  master_builds = Marshal.load File.read 'builds.marshal'
else
  master_builds = t.latest_builds.find_all { |x|
    x.branch == 'master' && x.passed?
  }
  File.write 'builds.marshal', Marshal.dump(master_builds)
end

chart = Travis::Chart.new master_builds
puts chart.to_html
#columns = master_builds.first.details.commands.map { |c|
#  "data.addColumn('number', '#{c.env}');"
#}.join "\n"
#
#puts columns
#
#master_builds.each do |build|
#  times = build.details.commands.map { |c| c.duration }.join(', ')
#  puts "['#{build.number}', #{times}],"
#end
