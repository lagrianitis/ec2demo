.PHONY: all help
help: ## All possible make arguements targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'


lint-stacks:
	cfn-lint -u && cfn-lint -o ./validate/cfn-lint/spec.json \
	-a ./validate/cfn-lint/rules -t ./*.template.yaml -e \
	&& echo 'CFN templates successfully validated.'

validate-stacks:
	for template in *.template.yaml ; do \
  		echo "\nValidating template $$template\n"; \
		aws cloudformation validate-template \
		--template-body file://$$template \
		--output text --profile ${AWS_PROFILE} ; \
	done

create-pipeline:  ## Deploy the pipeline CFN stacks
	aws cloudformation create-stack \
	--stack-name $(SERVICE_NAME)-pipeline \
	--template-body file://`pwd`/templates/pipeline.template.yaml \
	--parameters file://`pwd`/$(PARAMETERS_FILE) \
	--profile $(AWS_PROFILE) --region $(AWS_REGION) \
	--tags Key=ApplicationName,Value=$(SERVICE_NAME) \
	--capabilities CAPABILITY_IAM \
	&& echo "Creating $(SERVICE_NAME)-pipeline (CodeCommit and S3 Bucket) cfn stack please wait..." || ${MAKE} update-pipeline
	# Waiting for the stack to be completed
	@aws cloudformation wait stack-create-complete \
	--stack-name $(SERVICE_NAME)-pipeline \
	--profile $(AWS_PROFILE) --region $(AWS_REGION)\
	&& echo "$(SERVICE_NAME)-pipeline successfully created."

update-pipeline:  ## Updated the cfn stack for the pipeline
	@aws cloudformation update-stack \
	--stack-name $(SERVICE_NAME)-pipeline \
	--template-body file://`pwd`/templates/pipeline.template.yaml \
	--parameters file://`pwd`/$(PARAMETERS_FILE) \
	--profile $(AWS_PROFILE) --region $(AWS_REGION) \
	--tags Key=ApplicationName,Value=$(SERVICE_NAME) \
	--capabilities CAPABILITY_IAM \
	&& echo "Creating $(SERVICE_NAME)-pipeline (CodeCommit and S3 Bucket) cfn stack please wait..." || true
	# Wcloudformation stack to be completed
	aws cloudformation wait stack-update-complete \
	--stack-name $(SERVICE_NAME)-pipeline-repos \
	--profile $(AWS_PROFILE) --region $(AWS_REGION) \
	&& echo "$(SERVICE_NAME)-pipeline successfully created."
delete-pipeline:  # Delete the pipeline stack
	@aws cloudformation delete-stack --stack-name $(SERVICE_NAME)-pipeline --profile $(AWS_PROFILE) --region $(AWS_REGION)