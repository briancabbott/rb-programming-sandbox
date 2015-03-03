<<<<<<< HEAD
require 'test/minirunit'
test_check "Test Splat:"

class SplatSubscriptAssignment
  def []=(a,b)
    test_equal(1, a)
    test_equal(2, b)
  end
end

g = [1]
=======
require 'test/minirunit'
test_check "Test Splat:"

class SplatSubscriptAssignment
  def []=(a,b)
    test_equal(1, a)
    test_equal(2, b)
  end
end

g = [1]
>>>>>>> c348867bba82f393fba910b694a77b4685430155
SplatSubscriptAssignment.new[*g] = 2