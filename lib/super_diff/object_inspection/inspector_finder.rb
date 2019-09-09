module SuperDiff
  module ObjectInspection
    class InspectorFinder
      def self.call(object)
        if object.respond_to?(:attributes_for_super_diff)
          Inspectors::CustomObject
        else
          case object
          when Array
            Inspectors::Array
          when Hash
            Inspectors::Hash
          when String
            Inspectors::String
          when true, false, nil, Symbol, Numeric, Regexp
            Inspectors::Primitive
          else
            Inspectors::DefaultObject
          end
        end
      end
    end
  end
end
