$: << 'lib'

require 'travis'

task :clean do
  rm 'report.html'
  rm 'builds.marshal'
end

file 'report.js' do
  t = Travis.new
  builds = t.latest(150)

  json = JSON.dump builds.map { |b| t.details(b['id']) }
  File.open('report.js', 'w') { |f|
    f.write "function travisdata() { return #{json}; }"
  }
end

task :default => 'report.js'
