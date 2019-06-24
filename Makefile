all:
	./rebar get-deps
	./rebar compile
test: all check
check:
	./rebar eunit skip_deps=true

rundists:
	number=1 ; while [[ $$number -le 100 ]] ; do \
		/usr/bin/erl -name test$$number@localhost.localdomain -cookie testcookie -detached ; \
		((number = number + 1)) ; \
	done
