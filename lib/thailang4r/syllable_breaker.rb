require "thailang4r.rb"

module ThaiLang
	class SyllableBreaker
		FM = :FRONT_MERGE
		FI = :FRONT_INTEREST
		NOR = :NORMAL

		@s = -1
		@e = -1

		def _build_each_word_ranges(words, dag, ranges)
			# puts "$$$$$$$$"
			# puts dag
			# puts "$$$$$$$$"
			answer = []
			
			if words.length > 1 or dag.length > 2
				words.each do |word|
					answer_stack = []
					word_len = ThaiLang::string_chlevel(word).length
					info = []
					factor_path = []
					if @s != 0
						@s = 0
						@e = word_len
						dag.each do |element|
							if element[0] >= @s && element[1] <= word_len
								# puts "e0 = #{element[0]} | e1 = #{element[1]}" 
								info << [element[0], element[1]]
							end 
						end
							answer_stack << _build_factor(words, word, info)
							answer_stack.each{|factor| 
							# print "1st:: factor.length = #{factor.length} VS. word.length = #{word.length} || factor.class = #{factor.class} || factor = #{factor}\n"
								if factor.length < word.length and answer_stack.length == 1 and factor.class != Array
									answer << word
								elsif factor.class == Array
									if factor.length < word.length and factor.length == 1
										answer << word
									else
										factor.each do |f|
											answer << f
										end
									end
								else
									answer << factor
								end
							}	
					else
						@s = @e
						@e = @e + word_len
						dag.each do |element|
							if element[0] >= @s && (element[1] >= @s && element[1] <= @e)
								# puts "e0 = #{element[0]} | e1 = #{element[1]}" 
								info << [element[0] - @s, element[1] - @s]
							end
						end
						# puts "$$$$$$$$"
						answer_stack << _build_factor(words, word, info)
						# print "answer_stack = #{answer_stack}\n"
						answer_stack.each{|factor| 
						# print "2nd:: factor.length = #{factor.length} VS. word.length = #{word.length} || factor.class = #{factor.class} || factor = #{factor}\n"
							if factor.length < word.length and answer_stack.length == 1 and factor.class != Array
									answer << word
								elsif factor.class == Array
									if factor.length < word.length and factor.length == 1
										answer << word
									else
										factor.each do |f|
											answer << f
										end
									end
								else
									answer << factor
								end
						}
						# print "info = #{info}\n"
						# puts "$$$$$$$$"
					end
				end
			elsif words.length == 1
				info = []
				if dag.length == 0
					info << [ranges[0], ranges[1]]
					answer = _build_factor(words, words.join, info)
				else 				
					info << [dag[0][0], dag[0][1]]
					answer = _build_factor(words, words.join, info)
				end
			end
	      	return answer
		end

		def _build_factor(words, word, dag)

			# puts "$$$$$$$$"
			# puts word
			# puts dag
			# puts "$$$$$$$$"
			# find longest string
		
			# word has only one factor
			if dag.length <= 1
				return _singular_factor(words, word, dag)
			# word has more one factor
			else
				return _plural_factor(words, word, dag)
			end
		end

		def _singular_factor(words, word, dag)
			# puts "word has only one factor -> #{word}"
			possibility_word = []
			remaining_word = []
			s = dag.first	
			e = dag.last

			# puts "TRUE"
			if has_vowel(word)
				lexical = _vowel_checking(word)
				for i in 0...lexical.length
					# print "word = #{word}\n"
					if lexical[i] == FM
						possibility_word << word[i-1].concat(word[i])
						remaining_word << word[i+1..word.length]
					elsif lexical[i] == FI 
						if lexical.length > 2 and(word[i+2].ord == 0x0E48 || word[i+2].ord == 0x0E49 || word[i+2].ord == 0x0E4A)
							possibility_word << word[i].concat(word[i+1..i+2])
							# remaining_word << word[i+3..word.length]
						else
							possibility_word << word[i].concat(word[i+1..i+2])
							# remaining_word << word[i+2..word.length]
						end
 					end
				end
				# print "possibility_word = #{possibility_word}\n"
				# print "remaining_word = #{remaining_word}\n"
				remaining_word.each{|word| 
					if word.empty? == false
						possibility_word << word
					end
				}
				# puts possibility_word
				return possibility_word
			# has not vowel in any word
			else
				return word
			end
		end

		def _plural_factor(words, word, dag)
			# puts "word has more one factor -> #{word}"
			possibility_word = []
			max_size = 0
			# print "dag = #{dag}\n"
			# ระบาย ต้องมีระ แต่ในดิก ไม่มีคำว่า "ระ"
			dag.each do |lexical|
				size = lexical[1] - lexical[0]
				if size > max_size
					max_size = size
				end
				possibility_word << [lexical[0], lexical[1], size, word[lexical[0]..lexical[1]-1]]
			end
		
			possibility_word = filter_factor(possibility_word)  #delete  0 5 5			
			possibility_word = find_coor(possibility_word, word, max_size)    #return  2 5 3
			
			return possibility_word
			
		end

		def find_coor(factor, word, max_size)
			return_coor_factor = []
			max_factor = find_max_factor(factor)
			temp_factor = factor.clone
			cumulation = 0

			
			factor.each do |lexical|
				# puts "%%%%%%%%%%"
				# print "#{lexical} VS #{max_factor}\n"
				
				lexical_range = (lexical[0]...lexical[1]).to_a
				max_factor_range = (max_factor[0]...max_factor[1]).to_a

				# check whether a range contains a subset of another range?
				if (lexical_range.first <= max_factor_range.last) and (max_factor_range.first <= lexical_range.last)
					if lexical[0] != max_factor[0] or lexical[1] != max_factor[1]
						# print "delete #{lexical}\n"
						# puts "%%%%%%%%%%"
						temp_factor.delete(lexical)
					end
				# find longest word if factor has a duplicate subset such as  ["จร", "จริง"]
				else
					temp_factor.each do |t_f|
						other_factor_range = (t_f[0]...t_f[1]).to_a
						if (lexical_range.first <= other_factor_range.last) and (other_factor_range.first <= lexical_range.last)
							if (lexical[0] != max_factor[0] or lexical[1] != max_factor[1]) and lexical[2] < t_f[2]
								temp_factor.delete(lexical)
							end
						end
					end
				end	
				
			end

			# check whether a each range contains a subset of another range?


			#counting cumalate to validate max size
			temp_factor.each do |t_lexical|
				cumulation+= t_lexical[2]
			end
			

			if cumulation < max_size  # remaining some word which not being in dict
				# puts "outbound"
				return_coor_factor = outbound_dict(temp_factor, word, max_size, cumulation)
				return return_coor_factor
			else
				temp_factor.each do |t_factor|
					return_coor_factor << t_factor[3]
				end
				return return_coor_factor
			end
		end

		def outbound_dict(factor, word, max_size, cumulation)
			return_factor = []
			boundary_stack = []  # store index of each character in words which are in dict
			outbound_word = []  # store words which are not in dict
			symbol = :FIRST

			# Finds boundry word
			factor.each do |lexical|
				(lexical[0]..lexical[1]).each{|n| boundary_stack << n}	
			end

			for itr in 0..max_size
				if boundary_stack.include? itr
					if symbol == :NOT_EMPTY
						return_factor << outbound_word.join
						return_factor << word[boundary_stack.first..boundary_stack.last]
						symbol = :EMPTY
					elsif symbol == :FIRST
						return_factor << word[boundary_stack.first..boundary_stack.last]
						symbol = :EMPTY
					end
				else
					outbound_word << word[itr]
					symbol = :NOT_EMPTY
					if itr == max_size and outbound_word.empty?
						return_factor << outbound_word.join
					end
				end
			end		
			# puts return_factor
			return return_factor
		end

		def filter_factor(factor)
			factor.delete(find_max_factor(factor))
			return factor
			
		end

		def find_max_factor(factor)
			comp_max = 0
			max = []
			factor.each do |lexical|
				if lexical[2] > comp_max
					comp_max = lexical[2]
					max = lexical
				end
			end
			return max
		end



		def has_vowel(factor) 
			factor.each_char do |ch|
				if ThaiLang::chlevel(ch) == 1 && (ch.ord == 0x0E30 || ch.ord == 0x0E44)
					return true
				end
			end
			return false
		end

		def _vowel_checking(factor)
			ch_factor_list = []
			i = 0
			factor.each_char do |ch|
				ch_factor_list << chvowel(ch.ord)
				i+=1
			end
			ch_factor_list
			# test = ["ะ", "ั", "็", "า", "ิ", "่", "ํ", "ุ", "ู", "เ", "ใ", "ไ", "โ"]
			
		end

		def chvowel(code)
			level = nil
			if code == 0x0E30 	#สระ อะ
				level = FM
			elsif code == 0x0E44  #สระ ไอ
				level = FI 
			else
				level = NOR
			end
		end

	end
end