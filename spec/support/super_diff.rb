if $active_record_available
  require "super_diff/rspec-rails"
else
  require "super_diff/rspec"
end

SuperDiff.configure do |config|
  config.diff_elision_enabled = true
  config.diff_elision_threshold = 3
  config.diff_elision_padding = 3
end
