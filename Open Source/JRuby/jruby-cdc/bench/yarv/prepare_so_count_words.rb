<<<<<<< HEAD
# prepare 'wc.input'

def prepare_wc_input
  wcinput = File.join(File.dirname($0), 'wc.input')
  wcbase  = File.join(File.dirname($0), 'wc.input.base')
  unless FileTest.exist?(wcinput)
    data = File.read(wcbase)
    13.times{
      data << data
    }
    open(wcinput, 'w'){|f| f.write data}
  end
end

prepare_wc_input
=======
# prepare 'wc.input'

def prepare_wc_input
  wcinput = File.join(File.dirname($0), 'wc.input')
  wcbase  = File.join(File.dirname($0), 'wc.input.base')
  unless FileTest.exist?(wcinput)
    data = File.read(wcbase)
    13.times{
      data << data
    }
    open(wcinput, 'w'){|f| f.write data}
  end
end

prepare_wc_input
>>>>>>> c348867bba82f393fba910b694a77b4685430155
