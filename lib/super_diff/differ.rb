module SuperDiff
  class Differ
    def initialize
    end
    
    def diff!(expected, actual)
      @data = diff(expected, actual)
      self
    end
    
    def diff(expected, actual)
      expected_type = type_of(expected)
      actual_type   = type_of(actual)
      same_type     = (expected_type == actual_type)
      if same_type && expected.class < Enumerable
        if expected.class == Array
          equal, breakdown = diff_array(expected, actual)
        elsif expected.class == Hash
          equal, breakdown = diff_hash(expected, actual)
        end
      else
        equal = (expected == actual)
      end
      data = {
        :state => (equal ? :equal : :inequal),
        :expected => {:value => expected, :type => expected_type},
        :actual => {:value => actual, :type => actual_type},
        :common_type => (expected_type if same_type)
      }
      data[:breakdown] = breakdown if breakdown
      data
    end
    
    def report_to(stdout, data=@data)
      Reporter.new(stdout).report(data)
    end
    
  private
    def diff_array(expected, actual)
      equal = true
      breakdown = []
      (0...expected.size).each do |i|
        if i > actual.size - 1
          subdata = {
            :state => :missing,
            :expected => {:value => expected[i], :type => type_of(expected[i])},
            :actual => nil,
            :common_type => nil
          }
          equal = false
        else
          subdata = diff(expected[i], actual[i])
          equal &&= subdata[:equal]
        end
        breakdown << [i, subdata]
      end
      if actual.size > expected.size
        equal = false
        (expected.size .. actual.size-1).each do |i|
          subdata = {
            :state => :surplus,
            :expected => nil,
            :actual => {:value => actual[i], :type => type_of(actual[i])},
            :common_type => nil
          }
          breakdown << [i, subdata]
        end
      end
      [equal, breakdown]
    end
    
    def diff_hash(expected, actual)
      equal = true
      breakdown = []
      expected.keys.each do |k|
        if actual.include?(k)
          subdata = diff(expected[k], actual[k])
          equal &&= subdata[:equal]
        else
          subdata = {
            :state => :missing,
            :expected => {:value => expected[k], :type => type_of(expected[k])},
            :actual => nil,
            :common_type => nil
          }
          equal = false
        end
        breakdown << [k, subdata]
      end
      (actual.keys - expected.keys).each do |k|
        equal = false
        subdata = {
          :state => :surplus,
          :expected => nil,
          :actual => {:value => actual[k], :type => type_of(actual[k])},
          :common_type => nil
        }
        breakdown << [k, subdata]
      end
      [equal, breakdown]
    end
    
    def type_of(value)
      case value
        when Fixnum then :number
        else value.class.to_s.downcase.to_sym
      end
    end
  end
end