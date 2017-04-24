OWNER:=jamesramsay

NAME:=jupyter-rjdbc

# Use bash for inline if-statements in test target
SHELL:=bash

build: ## build the latest image
	docker build --rm --force-rm -t $(OWNER)/$(NAME):latest .

test: ## check for jupyter server liveliness
	@-docker rm -f iut
	@docker run -d --name iut $(OWNER)/$(NAME)
	@for i in $$(seq 0 9); do \
		sleep $$i; \
		docker exec iut bash -c 'wget http://localhost:8888 -O- | grep -i jupyter'; \
		if [[ $$? == 0 ]]; then exit 0; fi; \
	done ; exit 1

