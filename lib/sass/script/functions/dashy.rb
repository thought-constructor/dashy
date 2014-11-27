require 'sass/script/functions'

class Sass::Script::Value::String

   prepend Module.new {

     def to_s opt = {}
       return @value.gsub(/(?<!\\)(?=[\$\%\/\?\!])/, "\\") if :selector == @type
       return super
     end

   }

end

module Sass
  module Script
    module Functions

      # Defined directly on `Functions` so we can use `declare`.

      def is_wildcard value
        '*' == value.to_s
      end

      def select *selectors
        this = select_identifier ""
        select_as this, *selectors
      end
      declare :select, [], :var_args => true

      def select_as separator, *selectors
        unquote   = method :unquote
        separator = separator.value
        selectors = selectors.first if 1 == selectors.length
        selectors = selectors.to_a.map { |selector| selector.to_a.map &unquote }
        selectors = selectors.shift.product *selectors
        Sass::Script::Value::List.new selectors.map! { |selector|
         # selector = selector.reject &method(:is_wildcard) unless 1 == selector.length && is_wildcard(selector.first)
          selector = selector.join separator
          selector.gsub! /(?<=[\w\-\]])\*/, ''  # Remove any wildcards after any words or attributes.
          selector.gsub! /\*(?=[\w\.\#\[])/, '' # Remove any wildcards before any tags, classes, ids or attributes.
          select_identifier selector
        }, :comma
      end
      declare :select_with, [:string], :var_args => true

      def select_as_descendants *selectors
        descendants = select_identifier " "
        select_as descendants, *selectors
      end
      declare :select_as_descendants, [], :var_args => true

      def select_as_children *selectors
        children = select_identifier ">"
        select_as children, *selectors
      end
      declare :select_as_children, [], :var_args => true

      def select_as_adjacent_siblings *selectors
        adjacent_siblings = select_identifier "+"
        select_as adjacent_siblings, *selectors
      end
      declare :select_as_adjacent_siblings, [], :var_args => true

      def select_as_general_siblings *selectors
        general_siblings = select_identifier "~"
        select_as general_siblings, *selectors
      end
      declare :select_as_general_siblings, [], :var_args => true

      def select_descendants selector = select_any
        descendants = select_identifier " "
        select descendants, selector
      end
      declare :select_descendants, [:string], :var_args => true

      def select_children selector = select_any
        children = select_identifier ">"
        select children, selector
      end
      declare :select_children, [:string], :var_args => true

      def select_adjacent_siblings selector = select_any
        adjacent_siblings = select_identifier "+"
        select adjacent_siblings, selector
      end
      declare :select_adjacent_siblings, [:string], :var_args => true

      def select_general_siblings selector = select_any
        general_siblings = select_identifier "~"
        select general_siblings, selector
      end
      declare :select_general_siblings, [:string], :var_args => true

      def select_either *selectors
        selectors = selectors.first if 1 == selectors.length
        selectors = selectors.map &:to_a
        Sass::Script::Value::List.new selectors.flatten, :comma
      end
      declare :select_either, [], :var_args => true

      def select_attribute attribute, *selectors
        selectors = selectors.first if 1 == selectors.length
        selectors = selectors.to_a.map { |selector| select_string "[#{ attribute }=\'#{ select_escaped! selector }\']" }
        Sass::Script::Value::List.new selectors, :comma
      end
     
      def select_attribute_prefix attribute, *selectors
        selectors = selectors.first if 1 == selectors.length
        selectors = selectors.to_a.map { |selector|
          [
            (select_string "[#{ attribute }^=\'#{  select_escaped! selector }\']"),
            (select_string "[#{ attribute }*=\' #{ select_escaped! selector }\']")
          ]
        }
        Sass::Script::Value::List.new selectors.flatten, :comma
      end

      def select_attribute_suffix attribute, *selectors
        selectors = selectors.first if 1 == selectors.length
        selectors = selectors.to_a.map { |selector|
          [
            (select_string "[#{ attribute }$=\'#{ select_escaped! selector }\']"),
            (select_string "[#{ attribute }*=\'#{ select_escaped! selector } \']")
          ]
        }
        Sass::Script::Value::List.new selectors.flatten, :comma
      end

      def select_class_prefix *selectors
        attribute = select_identifier "class"
        select_attribute_prefix attribute, *selectors
      end

      def select_class_suffix *selectors
        attribute = select_identifier "class"
        select_attribute_suffix attribute, *selectors
      end

      def select_class selector
        selectors = selector.to_a.map &:to_a
        selectors = selectors.shift.product *selectors
        selectors.map! { |selector| select_identifier "." + select_escaped!(selector.to_a.map { |s| s.to_s(quote: :none).gsub(/(?<!\\)(?=[.\$\%\/\?\!])/, "\\") }.join "-") }
        Sass::Script::Value::List.new selectors, :comma
      end

      def select_classes *selectors
        select_either *(selectors.map! &(method :select_class))
      end

      def select_pseudoclass selector
        select_identifier ":" + (selector.to_a.join "-")
      end

      def select_pseudoclasses *selectors
        select_either *(selectors.map! &(method :select_pseudoclass))
      end

      def select_quasiclass selector
        select_either select_class(selector), select_pseudoclass(selector)
      end

      def select_quasiclasses *selectors
        select_either *(selectors.map! &(method :select_quasiclass))
      end

      def select_adjacent_odd_siblings limit, *selectors
        selectors.push select_identifier '*' if selectors.empty?
        selectors = selectors.first if 1 == selectors.length
        selectors = (0 .. limit.value).select { |i| 1 == i % 2 }.map { |i| select select_identifier(" + * " * i + " + "),  *selectors }
        select_either *selectors
      end

      def select_odd_siblings limit, *selectors
        select_either select_first_sibling, select(select_first_sibling, select_adjacent_odd_siblings(limit, *selectors))
      end

      def select_odd_children limit, *selectors
        select_children select_odd_siblings(limit, *selectors)
      end

      def select_adjacent_even_siblings limit, *selectors
        selectors.push select_identifier '*' if selectors.empty?
        selectors = selectors.first if 1 == selectors.length
        selectors = (0 .. limit.value).select { |i| 0 == i % 2 }.map { |i| select select_identifier(" + * " * i + " + "),  *selectors }
        select_either *selectors
      end

      def select_even_siblings limit, *selectors
        select select_first_sibling, select_adjacent_even_siblings(limit, *selectors)
      end

      def select_even_children limit, *selectors
        select_children select_even_siblings(limit, *selectors)
      end

      def select_first_child
        select_children select_first_sibling
      end

      def select_first_sibling
        select_identifier ":first_child"
      end

      def select_any
        select_identifier "*"
      end

      def select_string selector
        Sass::Script::Value::String.new selector.to_s, :string
      end

      def select_identifier selector
        Sass::Script::Value::String.new selector.to_s, :selector
      end

      def select_escaped! thing
        thing.tap { |t|
          case thing

          when Sass::Script::Value::String
            select_escaped! t.value

          when String
            t.gsub! /(?<!\\)(?=[\=\$\%\/\?\!\.])/, "\\"

          end
        }
      end

      def select_escaped_string selector
        select_escaped! select_string selector
      end

      def select_escaped_identifier selector
        select_escaped! select_identifier selector
      end

      def select_arguments namespace, *name_value_pairs
        inputs = name_value_pairs.map { |name_value_pair|
          name, value = name_value_pair.to_a
          select select_identifier('input:checked'), select_attribute('form',  namespace),
                                                     select_attribute('name',  name),
                                                     select_attribute('value', value)
        }
        select_as_general_siblings *inputs

        # $form: select-class($form);

        # $left:  select($input select-general-siblings($form));
        # $right: select($form select-class($name $value));

        # @return select-either($left, $right);
      end

      def select_lists *selectors
        select_either select_ordered_lists(*selectors), select_unordered_lists(*selectors)
      end

      def select_ordered_lists *selectors
        select select_identifier('ol'), *selectors
      end

      def select_unordered_lists *selectors
        select select_identifier('ul'), *selectors
      end

      def list_of *lists
        Sass::Script::Value::List.new lists.map { |list|
          list                                 = list.to_a
          number                               = list.first
          first, second, operator, *rest, last = list.map &:value
          this                                 = first
          delta                                = second - first
          case operator
          when "_"  then [].tap { |list| while this <= last; list << this; this += delta; end }
          when "__" then [].tap { |list| while this <  last; list << this; this += delta; end }
          else list
          end.map { |value| Sass::Script::Value::Number.new value, number.numerator_units, number.denominator_units }
        }.flatten, :comma
      end
      declare :list_of, [:list], :var_args => true

    end
  end
end
