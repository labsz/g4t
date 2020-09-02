install:
	bundle install
	mv main.rb /usr/local/bin/g4t
	@echo -e "\nSuccessfully installed, now try using \n g4t"

uninstall:
	rm -f /usr/local/bin/g4t
