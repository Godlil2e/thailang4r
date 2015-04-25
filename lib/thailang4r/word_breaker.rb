require 'rubygems'
require 'thailang4r/dict.rb'
require 'thailang4r/word_dag_builder.rb'
require 'thailang4r/ranges_builder.rb'
require 'thailang4r/syllable_breaker.rb'

module ThaiLang
  class WordBreaker
    
    S = 0
    E = 1
    word_size = 0
    
    def initialize(path = nil)
      if path.nil?
        # Find absolute path of arg[0] that relative woth arg[1]-> the path's code being in this file(word_breaker.rb) 
        path = File.expand_path('../../../data/lexitron.txt', __FILE__)
      end
      @dict = Dict.new path
      @dag_builder = WordDagBuilder.new @dict
      @ranges_builder = RangesBuilder.new
    end

    def break_into_words(string)
      len = string.length
      # puts len
      dag = @dag_builder.build(string, len)

      # puts "+++++++++++++++++"
      # dag.each do |x|
      #   puts "#{x}"
      #   puts string[x[0], x[1] - x[0]]
      # end
      # puts "+++++++++++++++++"
      
      ranges = @ranges_builder.build_from_dag(dag, len)
      ranges.map{|range| string[range[S], range[E] - range[S]]}    #answer can be puts

    end
     
    def break_into_syllable(string)
      answer = []
      @syllable = SyllableBreaker.new
      len = string.length
      dag = @dag_builder.build(string, len)
      ranges = @ranges_builder.build_from_dag(dag, len)
      words = ranges.map{|range| string[range[S], range[E] - range[S]]}
      

      # puts "+++++++++++++++++"
      # puts words
      # puts ranges
      # # dag.each do |x|
      # #   puts "#{x}"
      # #   puts word[x[0], x[1] - x[0]]
      # # end
      # puts "+++++++++++++++++"

      answer = @syllable._build_each_word_ranges(words, dag, ranges)
      print "#{answer}\n"
      if answer.class != Array
        return 1
      else
        return answer.length
      end
      
    end
  end
end
