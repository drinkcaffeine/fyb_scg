class SCGMetrics < ::Sinatra::Base
  require 'csv'
  get '/conversions.csv' do
    if defined? CONVERSION_SQL and defined? APP_LAUNCH_DATE
      content_type "text/csv"
      today = Date.today
      dates = (APP_LAUNCH_DATE..today).to_a
      CSV.generate(:force_quotes => true, :col_sep => ",") do |csv|
        csv << ['date', 'count']
        dates.each do |d|
          # alter query if already contains 'where' to avoid sql syntax errors
          # NOTE: not fool-proof!
          supplemental_clause = "where created_at > '#{d.to_s}' and created_at <= '#{d.to_s} 23:59:59'"
          supplemental_clause.gsub!('where', 'and') if CONVERSION_SQL =~ /where|WHERE/
          csv << [d.to_s, repository.adapter.select("#{CONVERSION_SQL} #{supplemental_clause}").first]
        end
      end
    else
      "CONVERSION_SQL CONST not defined!"
    end
  end
  
end

