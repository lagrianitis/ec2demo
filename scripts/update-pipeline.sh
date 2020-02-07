#!/usr/bin/env bash
echo -n "Github OAuth Token: <hidden> "
read -r -s token
if [ ${#token} != 40 ]
then
  echo -e "\nYour Github Access Key is not correct. It needs to be 40 alpnumerical charachers"
  exit 1
fi

# -e: Exit immediately if a command exits with a non-zero status.
# -u: Treat unset variables as an error when substituting.
set -eu

aws cloudformation update-stack \
        --capabilities CAPABILITY_NAMED_IAM \
        --stack-name "$CODEPIPELINE_STACK_NAME" \
        --parameters ParameterKey=GitHubOAuthToken,ParameterValue="${token}" \
                     ParameterKey=GitHubOwner,ParameterValue="${1}" \
                     ParameterKey=GitHubRepo,ParameterValue="${2}" \
                     ParameterKey=NotificationEmailAddress,ParameterValue="${3}" \
        --template-body file://../templates/pipeline.template.yaml \
        --profile "$AWS_PROFILE"

echo "Cloudformation create stack operation sucessfully completed"
