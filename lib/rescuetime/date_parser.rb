# frozen_string_literal: true

module Rescuetime
  # Responsible for formatting user-inputted dates into proper Rescuetime format
  # @since v0.3.2
  class DateParser
    # Valid string formats for date parsing. The key is a human-readable pattern
    # (ex. 'yyyy-mm-dd'), and the value is the corresponding regular expression.
    DATE_FORMATS = {
      'yyyy-mm-dd'                => /\d{4}-\d{2}-\d{2}/,
      'yyyy/mm/dd'                => %r{\d{4}\/\d{2}\/\d{2}},
      'mm-dd-yyyy or mm/dd/yyyy'  => %r{\d{2}[-\/]\d{2}[-\/]\d{4}},
      'mm-dd or mm/dd'            => %r{\d{2}[-\/]\d{2}}
    }.freeze

    class << self
      # Returns a date as a string in the correct Rescuetime API format
      #
      # Allowed date formats:
      # - Object that responds to #strftime
      # - String in "YYYY-MM-DD" format
      # - String in "YYYY/MM/DD" format
      # - String in "MM-DD-YYYY" format
      # - String in "MM/DD/YYYY" format
      # - String in "MM-DD" format (defaults to current year)
      # - String in "MM/DD" format (defaults to current year)
      #
      # @example Basic Use
      #   parser = Rescuetime::DateParser
      #   parser.parse '12-25' # assuming the current year is 2015
      #   #=> '2015-12-25'
      #
      #   parser.parse '2015/12/25'
      #   #=> '2015-12-25'
      #
      #   parser.parse Time.parse('2015-12-25')
      #   #=> '2015-12-25'
      #
      #   parser.parse 'Dec. 25, 2015'
      #   #=> Rescuetime::Errors::InvalidQueryError: Invalid date entered. Please
      #   #                                  see docs for allowed formats.
      #
      # @param  [#strftime, String] date  a date to be formatted
      # @return [String]                  a date string in the YYYY-MM-DD format
      #
      # @raise [Rescuetime::Errors::InvalidQueryError] if the date format is invalid
      def parse(date)
        if date.respond_to? :strftime
          date.strftime '%Y-%m-%d'
        else
          reformat_string(date)
        end
      end

      private

      # Reformats a date string to follow the YYYY-MM-DD format
      #
      # @param  [String] date          A string representation of a date
      # @param  [Hash]   formatted_as  A hash of date formats and patterns
      # @return [String] a string date in YYYY-MM-DD format
      #
      # @raise [Rescuetime::Errors::InvalidQueryError] if the date format is invalid
      def reformat_string(date, formatted_as: DATE_FORMATS)
        case date
        when formatted_as['yyyy-mm-dd']  then date
        when formatted_as['yyyy/mm/dd']  then date.tr '/', '-'
        when formatted_as['mm-dd-yyyy or mm/dd/yyyy']
          month, day, year = date.scan(/\d+/)
          "#{year}-#{month}-#{day}"
        when formatted_as['mm-dd or mm/dd']
          year = Time.now.year
          month, day = date.scan(/\d+/)
          "#{year}-#{month}-#{day}"
        else
          fail_date_format
        end
      end

      # Raises Rescuetime::Errors::InvalidQueryError
      # @raise [Rescuetime::Errors::InvalidQueryError]
      def fail_date_format(exception: Rescuetime::Errors::InvalidQueryError)
        message = 'Invalid date entered. Please see docs for allowed formats.'
        raise exception, message
      end
    end
  end
end
