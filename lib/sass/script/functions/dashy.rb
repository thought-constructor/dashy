module Sass::Script::Functions
  module Dashy

    def select *selectors
      select_as unquoted_string(""), *selectors
    end

    def select_new selector
      string_new selector, :selector
    end

    private :select_new

    def select_as separator, *selectors
      unquote   = method :unquote
      separator = separator.value
      selectors = selectors.first if 1 == selectors.length
      selectors = selectors.to_a.map { |selector| selector.to_a.map &unquote }
      
      selectors = selectors.shift.product *selectors
      selectors.map! do |selector|
        selector = selector.join separator
        
        selector.gsub! %r{                 [*] (?=[\\\w\-\.\#\[]) }x, '' # Remove any wildcards before any tags, classes, ids or attributes.
        selector.gsub! %r{ (?<=[\\\w\-\]]) [*]                    }x, '' # Remove any wildcards after any words or attributes.

        select_new selector
      end
      
      list_new selectors
    end

    def select_either *selectors
      list_new selectors.map(&:to_a).flatten
    end

    def string_new string, type = :string
      Sass::Script::Value::String.new string, type
    end

    private :string_new

    def string_join strings, separator
      strings = strings.to_a
      type = strings.first.type
      strings = strings.map { |string| string.to_s quote: :none }
      separator = separator.to_s quote: :none
      string_new strings.join(separator), type
    end

    def number_new number, numerator_units = nil, denominator_units = nil
      Sass::Script::Value::Number.new number, numerator_units, denominator_units
    end

    private :number_new

    def list_new list, separator = :comma
      Sass::Script::Value::List.new list, :comma
    end

    private :list_new

    def list_series *lists
      lists.map! do |list|
        list = list.to_a
        sentinel = list.first

        first, second, operator, *rest, last = list.map &:value
        next list unless Numeric === last &&
                         Numeric === first &&
                         Numeric === second &&
                         /^_+$/ === operator &&
                         rest.all?(&Numeric.method(:===))

        delta = second - first
        case operator
        when "_"  then (first..  last)
        when "__" then (first... last)
        end.step(delta).map do |value|
          number_new value, sentinel.numerator_units, sentinel.denominator_units
        end
      end
      list_new lists.flatten, :comma
    end

    def to_number_from_fraction str
      number_new eval "1.0 * #{ str.value }" if %r{ ^ [0-9]+ / [0-9]+ $ }x === str.value
    end

    def to_fraction_from_number num
      string_new Rational(num.value).rationalize(0.001).to_s, :identifier
    end

  end
  prepend Dashy
end
