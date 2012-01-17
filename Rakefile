$: << 'lib'

require 'travis'

file 'report.html' do
  t = Travis.new
  if File.exists? 'builds.marshal'
    master_builds = Marshal.load File.read 'builds.marshal'
  else
    master_builds = t.latest_builds.find_all { |x|
      x.branch == 'master' && x.passed?
    }
    File.write 'builds.marshal', Marshal.dump(master_builds)
  end

  chart = Travis::Chart.new master_builds.sort_by { |b|
    b.number.to_i
  }
  File.write 'report.html', chart.to_html
end

task :default => 'report.html'

task :clean do
  rm 'report.html'
  rm 'builds.marshal'
end

task :json do
  t = Travis.new
  if File.exists? 'builds.marshal'
    builds = Marshal.load File.read 'builds.marshal'
  else
    builds = t.latest_builds
    builds.each(&:details)
    File.write 'builds.marshal', Marshal.dump(builds)
  end

  json = JSON.dump builds.map { |b| b.details.to_hash }
  puts "function travisdata() { return #{json}; }"
end
