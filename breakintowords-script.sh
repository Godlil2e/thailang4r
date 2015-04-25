#!/bin/bash
input=\"$1\"
gem build thailand4r.gemspec
irb -Ilib -rthailang4r << EOF
require 'thailang4r/word_breaker'
word_breaker = ThaiLang::WordBreaker.new
word_breaker.break_into_words($input)
EOF
