install:
	@bundle install 2> /dev/null
	@install -m 0755 main.rb /usr/local/bin/g4t
	@echo -e "\nSuccessfully installed, now try using \n g4t"

uninstall:
	@rm -f /usr/local/bin/g4t