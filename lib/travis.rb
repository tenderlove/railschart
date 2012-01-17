require 'psych'
require 'net/http'
require 'uri'
require 'date'
require 'chart'
require 'json'

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
      internal['matrix'].map { |x|
        c = Command.new(*x.values_at(*%w{ started_at finished_at status }))
        c.env = x['config']['env']
        c
      }
    end

    def passed?
      commands.all? { |x| x.status == 0 }
    end

    def to_hash
      {
        'matrix' => internal['matrix'].map { |x|
          {
            'started_at'  => x['started_at'],
            'finished_at' => x['finished_at'],
            'status'      => x['status'],
            'config'      => { 'env' => x['config']['env'] }
          }
        },
        'branch' => internal['branch'],
        'number' => internal['number'],
        'id'     => internal['id'],
      }
    end

    def to_json
      JSON.dump to_hash
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
