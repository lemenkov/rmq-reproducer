all:
	./rebar get-deps
	./rebar compile
test: all check
check:
	./rebar eunit skip_deps=true

rundists:
	/usr/bin/erl -name test0@localhost.localdomain -cookie testcookie -detached
	/usr/bin/erl -name test1@localhost.localdomain -cookie testcookie -detached
	/usr/bin/erl -name test2@localhost.localdomain -cookie testcookie -detached
	/usr/bin/erl -name test3@localhost.localdomain -cookie testcookie -detached
	/usr/bin/erl -name test4@localhost.localdomain -cookie testcookie -detached
	/usr/bin/erl -name test5@localhost.localdomain -cookie testcookie -detached
	/usr/bin/erl -name test6@localhost.localdomain -cookie testcookie -detached
	/usr/bin/erl -name test7@localhost.localdomain -cookie testcookie -detached
	/usr/bin/erl -name test8@localhost.localdomain -cookie testcookie -detached
	/usr/bin/erl -name test9@localhost.localdomain -cookie testcookie -detached
