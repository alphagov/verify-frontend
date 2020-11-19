RSpec::Matchers.define :a_list_of_size do |x|
  match { |actual| actual.length == x }
end
