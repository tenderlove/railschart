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
  builds = t.latest(150)

  json = JSON.dump builds.map { |b| t.details(b['id']) }
  puts "function travisdata() { return #{json}; }"
end
