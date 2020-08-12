echo "Trying to get which services have been updated!"
IGNORE=".idea commons"
SERVICES=$(git diff --name-only HEAD~1..HEAD | awk -F'/' 'NF!=1{print $1}' | sort -u)
echo $SERVICES

for SERVICE in $SERVICES; do
  if [[ ! " ${IGNORE[@]} " =~ "${SERVICE}" ]]; then
    echo "${SERVICE} has been updated. Let's deploy!"
    export IMAGE_NAME="${SERVICE}-latest"
    aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_URI}
    docker build . -t ${ECR_URI}/${IMAGE_NAME} --build-arg svc=${SERVICE} --build-arg env=${BITBUCKET_DEPLOYMENT_ENVIRONMENT}
    docker tag ${ECR_URI}/${IMAGE_NAME} ${ECR_URI}:${IMAGE_NAME}
    docker push ${ECR_URI}:${IMAGE_NAME}
  fi
done
