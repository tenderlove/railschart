class Travis
  class Chart
    attr_reader :builds

    def initialize builds
      @builds = builds
    end

    def to_html
      header +
        all +
        railties +
        ap_am_amo_ares_as +
        footer
    end

    def header
      <<-eohtml
<html>
  <head>
    <!--Load the AJAX API-->
    <script type="text/javascript" src="https://www.google.com/jsapi"></script>
    <script type="text/javascript">
    
      // Load the Visualization API and the piechart package.
      google.load('visualization', '1.0', {'packages':['corechart']});
      
      // Set a callback to run when the Google Visualization API is loaded.
      google.setOnLoadCallback(drawChart);
      
      // Callback that creates and populates a data table, 
      // instantiates the pie chart, passes in the data and
      // draws it.
      function drawChart() {
        all();
        railties();
        ap_am_amo_ares_as();
        // ar_mysql2();
        // ar_mysql();
        // ar_postgresql();
      }
      eohtml
    end

    def ap_am_amo_ares_as
      columns = [
        "data.addColumn('number', 'ap:am:amo:ares:as');",
        "data.addColumn('number', 'avg(3)');",
      ].join "\n"

      durations = builds.map { |build|
        command = build.details.commands.find { |c|
          c.env == 'GEM=ap,am,amo,ares,as'
        }
        [build.number, command.duration]
      }
      avgs = durations.map(&:last).each_cons(3).map { |a,b,c|
        (a + b + c) / 3
      }

      # FIXME: make the list the same number. I should find a better way to
      # do this, for example: does google chart allow null data?
      avgs.unshift durations[1].last
      avgs.unshift durations[0].last

      data = durations.zip(avgs).map(&:flatten).inspect

      <<-eojs
      function ap_am_amo_ares_as() {
        var data = new google.visualization.DataTable();
        data.addColumn('string', 'Build');
          #{columns}
        data.addRows(#{data});

        // Set chart options
        var options = {'title':'Test Time for ap:am:amo:ares:as on TravisCI',
                       'width':900,
                       'height':300,
                       'legend': { 'position': 'bottom' } };

        // Instantiate and draw our chart, passing in some options.
        var chart = new google.visualization.LineChart(document.getElementById('ap_am_amo_ares_as'));
        chart.draw(data, options);
      }
      eojs
    end

    def railties
      columns = [
        "data.addColumn('number', 'railties');",
        "data.addColumn('number', 'avg(3)');",
      ].join "\n"

      durations = builds.map { |build|
        command = build.details.commands.find { |c|
          c.env == 'GEM=railties'
        }
        [build.number, command.duration]
      }
      avgs = durations.map(&:last).each_cons(3).map { |a,b,c|
        (a + b + c) / 3
      }

      # FIXME: make the list the same number. I should find a better way to
      # do this, for example: does google chart allow null data?
      avgs.unshift durations[1].last
      avgs.unshift durations[0].last

      data = durations.zip(avgs).map(&:flatten).inspect

      <<-eojs
      function railties() {
        var data = new google.visualization.DataTable();
        data.addColumn('string', 'Build');
          #{columns}
        data.addRows(#{data});

        // Set chart options
        var options = {'title':'Test Time for railties on TravisCI',
                       'width':900,
                       'height':300,
                       'legend': { 'position': 'bottom' } };

        // Instantiate and draw our chart, passing in some options.
        var chart = new google.visualization.LineChart(document.getElementById('railties'));
        chart.draw(data, options);
      }
      eojs
    end

    def all
      columns = builds.first.details.commands.map { |c|
        "data.addColumn('number', '#{c.env}');"
      }.join "\n"

      data = builds.map { |build|
        times = build.details.commands.map { |c| c.duration }.join(', ')
        "['#{build.number}', #{times}],"
      }.join "\n"

      <<-eojs
      function all() {
        var data = new google.visualization.DataTable();
        data.addColumn('string', 'Build');
          #{columns}
        data.addRows([
          #{data}
        ]);

        // Set chart options
        var options = {'title':'Test Time for master on TravisCI',
                       'width':900,
                       'height':300,
                       'legend': { 'position': 'bottom' } };

        // Instantiate and draw our chart, passing in some options.
        var chart = new google.visualization.LineChart(document.getElementById('all'));
        chart.draw(data, options);
      }
      eojs
    end

    def footer
      <<-eohtml
    </script>
  </head>

  <body>
    <div id="all"></div>
    <div id="railties"></div>
    <div id="ap_am_amo_ares_as"></div>
    <div id="ar_mysql2"></div>
    <div id="ar_mysql"></div>
    <div id="ar_postgresql"></div>
  </body>
</html>
      eohtml
    end
  end
end
