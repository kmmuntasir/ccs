.PHONY: lint test install clean

lint:
	shellcheck *.sh
	bashate *.sh

test:
	@echo "No tests yet."

install:
	./install.sh

clean:
	rm -f *.tmp *.bak
