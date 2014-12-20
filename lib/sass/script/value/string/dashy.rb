class Sass::Script::Value::String
  module Dashy

    def to_s *sig
      return super unless :selector === type
      selector = self.value.dup

      # Escape...
      # 
      # ...decimals:
      # 
      selector.gsub! %r{ (?<=[0-9])                             (?=[.][0-9]) }x, '\\' # Escape any unescaped decimal points...
      selector.gsub! %r{ (?<=[0-9]) ( [\\][.] [0-9]{2} ) [0-9]+              }x, '\1' # Remove extra precision (> 2).
      selector.gsub! %r{ (?<=[0-9]) ( [\\][.] [0-9]*?  )   [0]+   (?=[^0-9]) }x, '\1' # Remove trailing zeroes.
      selector.gsub! %r{ (?<=[0-9]) ( [\\][.]          )          (?=[^0-9]) }x, ''   # Remove trailing dot.
      #
      # ...punctuation:
      #
      selector.gsub! %r{ (?<!\\) (?=[/%$?!]) }x, "\\" # Escape any unescaped punctuation...
      selector
    end

  end
  prepend Dashy
end
