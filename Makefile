all:
	./rebar get-deps
	./rebar compile
test: all check
check:
	./rebar eunit skip_deps=true
