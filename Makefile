all:
	coffee -p bucky.coffee | uglifyjs -m > bucky.min.js

.PHONY: all
