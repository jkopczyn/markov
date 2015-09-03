#require "yaml"

class Markov

  def initialize(prefix_size=3)
    @prefix_size = prefix_size
    @probability_random = 0
    @seed = None
    @data = {}
    @recent_data = {}
    @final_clear_length = prefix_size
  end

  def load
    #add try-except
    #read from a file to 'serialized'
    copy, @data = Marshal::load(serialized)
    #self = copy ?? probably doesn't work
  end

  def dump
    #add try-except
    serialized = Marshal::dump(@prefix_size, @data)
    #write this to a file
  end

end
