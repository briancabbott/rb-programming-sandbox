<<<<<<< HEAD
require 'rspec'

describe "JRUBY-6570: autoload called from instance method" do
  it "defines an autoload on the current object's class" do
    cls = Class.new do
      def go
        autoload :Time, 'time'
        autoload? :Time
      end
    end
    
    obj = cls.new
    obj.go.should == 'time'
    cls.autoload?(:Time).should == 'time'
  end
=======
require 'rspec'

describe "JRUBY-6570: autoload called from instance method" do
  it "defines an autoload on the current object's class" do
    cls = Class.new do
      def go
        autoload :Time, 'time'
        autoload? :Time
      end
    end
    
    obj = cls.new
    obj.go.should == 'time'
    cls.autoload?(:Time).should == 'time'
  end
>>>>>>> c348867bba82f393fba910b694a77b4685430155
end