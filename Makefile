.PHONY: all lint test vspec coverage

all: lint test

lint:
	vimlparser plugin/*/*.vim autoload/*/*.vim > /dev/null
	vint autoload plugin

test:
	rake test

vspec:
	bundle exec vspec . ./.vim-flavor/pack/flavors/start/mattn_vim-prompter/ t/prompter-cmigemo.vim

coverage:
	mkdir -p build
	rm -f ./build/coverage.xml ./build/profile.txt ./build/.coverage.covimerage
	PROFILE_LOG=./build/profile.txt rake test
	covimerage write_coverage ./build/profile.txt --data-file ./build/.coverage.covimerage
	coverage xml -o ./build/coverage.xml
	coverage report
