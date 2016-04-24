TESTER = sh tester.sh

readme:
	./is-your-readme-ok.sh > README.md

test:
	@$(TESTER)
