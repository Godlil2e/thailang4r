thailang4r (Forked from veer66/thailang4r)
==========
Thai language utility for Ruby

I have built this project in order to collect and share tools for Thai language, which are written in Ruby language. 

<<<<<<< HEAD
# New Feature
=======
# New Features
>>>>>>> 71990f46082d34609c049356a5e90d566e7d2719
* Breaking sentences or word into syllables (Return number of syllables)
* More vocabulary with new Dictionary (more than 40,000 vocab)

# Installation
------------
> gem 'thailang4r', git: 'https://github.com/Godlil2e/thailang4r.git'

# Character level
---------------
* chlevel is similar th_chlevel in [libthai](http://linux.thai.net/projects/libthai).
* string_chlevel gives array of level back for example string_chlevel("กี") will return [1, 2]

# Usage
------------
* Word breaker
```ruby
# encoding: UTF-8
require 'thailang4r/word_breaker'
word_breaker = ThaiLang::WordBreaker.new
puts word_breaker.break_into_words("ฉันกินข้าว")
```
* Syllable breaker (New Feature)
```ruby
# encoding: UTF-8
require 'thailang4r/syllable_breaker.rb'
word_breaker = ThaiLang::WordBreaker.new
puts word_breaker.break_into_syllable("ฉันกินข้าว")
```
