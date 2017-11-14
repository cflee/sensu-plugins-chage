require 'date'

module SensuPluginsChage
  module Util
    def parse_chage_password_expiry(output)
      date_lines = output.lines.grep(/^Password expires/)
      raise 'Could not parse output from chage' if date_lines.length != 1

      # extract the date string
      date_str = date_lines[0].split(':').last.strip
      return date_str if date_str == 'never'

      # parse the date string
      Date.strptime(date_str, '%b %d, %Y')
    end

    def days_to_password_expiry(now_date, output)
      chage_date = parse_chage_password_expiry(output)
      return chage_date if chage_date == 'never'

      (chage_date - now_date).to_i
    end
  end
end
