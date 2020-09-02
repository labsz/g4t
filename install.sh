if [[ $EUID -ne 0 ]]; then
	echo "Run it as sudo, please. ;)"
else
	cp "main.rb" "/usr/local/bin/g4t"
    bundle install
	chmod +x "/usr/local/bin/g4t"
	echo -e "\nSuccessfully installed, now try using \n g4t"
fi
