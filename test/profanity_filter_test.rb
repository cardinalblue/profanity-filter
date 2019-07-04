require "test_helper"
require "pry"

class ProfanityFilterTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::ProfanityFilter::VERSION
  end

  def test_it_does_something_useful
    assert true
  end

  def test_profane?
    binding.pry
  end
end
