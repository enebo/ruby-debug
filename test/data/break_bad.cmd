# ********************************************************
# This tests mostly invalid breakpoints.
# We have some valid ones too.
# ********************************************************
set debuggertesting on
set callstyle last
set autoeval off
set basename on
# There aren't 100 lines in gcd.rb.
break 100
break example/gcd.rb:100
# This line is okay
break example/gcd.rb:4
# No class Foo.
break Foo.bar
q
