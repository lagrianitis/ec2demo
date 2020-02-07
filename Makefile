SHELL:=/bin/bash
include makefile.env
AWS_PROFILE?=default

.PHONY: all help login create-pipeline update-pipeline delete-pipeline clean-all cnf-lint

help: ## All possible make arguements targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | xsort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

## Implicit guard target, that checks that the variable in the stem is defined.
guard-%:
	@if [ -z '${${*}}' ]; then echo "Environment variable $* not set"; exit 1; fi

git:
	git add .
	git commit -m ${m}
	git push origin master

install-req:
	pip install -r requirement.txt

cfn-lint: install-req
	cfn-lint -u
	cfn-lint -o ./validate/cfn-lint/spec.json -a validate/cfn-lint/rules -t ./pipeline.yml ./template/*.yml

check-env: guard-AWS_PROFILE guard-CODEPIPELINE_STACK_NAME guard-GITHUB_OWNER guard-GITHUB_REPO guard-SNS_EMAIL_ADDRESS

check-repo:
	@git ls-remote https://github.com/$(GITHUB_OWNER)/$(GITHUB_REPO) > /dev/null \
	&& exit 0 \
	|| echo "Github owner or repo doesn't exit"; exit 1

create-pipeline: check-env check-repo
	@/bin/bash scripts/create-pipeline.sh
update-pipeline: check-env check-repo
	@/bin/bash scripts/update-pipeline.sh
delete-pipeline:
	@/bin/bash scripts/delete-pipeline.sh

clean-all: create-pipeline update-pipeline delete-pipeline