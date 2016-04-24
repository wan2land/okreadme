TESTER = sh tester.sh

readme:
	./okreadme > README.md

test:
	@$(TESTER)
