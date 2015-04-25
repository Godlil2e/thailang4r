#!/bin/bash
input=\"$1\"
gem build thailand4r.gemspec
irb -Ilib -rthailang4r << EOF
require 'thailang4r/word_breaker'
ThaiLang::string_chlevel($input)
EOF
