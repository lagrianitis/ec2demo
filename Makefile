SHELL:=/bin/bash
include makefile.env
AWS_PROFILE?=default

.PHONY: all help login create-pipeline update-pipeline delete-pipeline clean-all

help: ## All possible make arguements targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | xsort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

## Implicit guard target, that checks that the variable in the stem is defined.
guard-%:
	@if [ -z '${${*}}' ]; then echo "Environment variable $* not set"; exit 1; fi

check-env: guard-AWS_PROFILE guard-CODEPIPELINE_STACK_NAME guard-GITHUB_OWNER guard-GITHUB_REPO guard-SNS_EMAIL_ADDRESS

check-repo:
	@git ls-remote https://github.com/$(GITHUB_OWNER)/$(GITHUB_REPO) > /dev/null \
	&& exit 0 \
	|| echo "Github owner or repo doesn't exit"; exit 1

create-pipeline: check-env check-repo
	@/bin/bash scripts/create-pipeline.sh
update-pipeline:
	@/bin/bash scripts/update-pipeline.sh
delete-pipeline:
	@/bin/bash scripts/delete-pipeline.sh

clean-all: create-pipeline update-pipeline delete-pipeline