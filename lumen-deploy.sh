#!/bin/bash
echo "Trying to get which services have been updated!"
IGNORE=".git .idea commons"
SERVICES=$(git diff --name-only HEAD~1..HEAD | awk -F'/' 'NF!=1{print $1}' | sort -u)
echo $SERVICES #if this contains commons...

if [[ ${SERVICES[@]} =~ "commons" ]]; then
  echo "Commons has been updated; Let's update all!"
  SERVICES=`find . -maxdepth 1 -mindepth 1 -type d -printf "%f\n"`
fi

for SERVICE in $SERVICES; do
  if [[ ! " ${IGNORE[@]} " =~ "${SERVICE}" ]]; then
    echo "${SERVICE} has been updated. Let's deploy!"
    export IMAGE_NAME="${SERVICE}-latest"
    aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_URI}
    docker build . -t ${ECR_URI}/${IMAGE_NAME} --build-arg svc=${SERVICE} --build-arg env=${BITBUCKET_DEPLOYMENT_ENVIRONMENT}
    docker tag ${ECR_URI}/${IMAGE_NAME} ${ECR_URI}:${IMAGE_NAME}
    docker push ${ECR_URI}:${IMAGE_NAME}
    aws ecs update-service --cluster ${ECS_CLUSTER} --service ${SERVICE}-svc --force-new-deployment --region ${AWS_REGION} --task-definition  ${SERVICE}-svc-defn-solo
  fi
done
