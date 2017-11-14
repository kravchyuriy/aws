#!/bin/bash
TAG_KEY=Backup
TAG_VALUE=true
NOW="$(date +%y-%m-%d)"
TIMESTAMP="$(date +%s)"
OLDTIME=86400
RMTIME=604800
RED='\033[0;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Backup instances

INSTANCE=( `aws ec2 describe-instances --filters "Name=tag:$TAG_KEY,Values=$TAG_VALUE" --output text | grep INSTANCES | awk '{print $9}'` )
if [ -n "$INSTANCE" ]; then
  for f in "${INSTANCE[@]}"
    do
      INSTANCENAME=$(aws ec2 describe-instances  --instance-ids "$f" --output text | grep Name | awk '{print $3}')
      echo -e "${NC}Creating AMI from instance ${GREEN}$f-$INSTANCENAME${NC}"
      aws ec2 create-image --instance-id "$f" --name "$INSTANCENAME"."$NOW" --no-reboot
    done
fi

# Delete old images

AMIID=( `aws ec2 describe-images --filters "Name=is-public,Values=false" --output text | grep IMAGES | awk '{print $6}'` )
if [ -n "$AMIID" ]; then
  for i in "${AMIID[@]}"
    do
      CREATETIME="$(date --date="$(aws ec2 describe-images --image-ids $i --output text | grep IMAGES | awk '{print $3}' | cut -d'T' -f1)" +"%s")"
        TIMEDIFF=$(expr "$TIMESTAMP" - "$CREATETIME")
           if [ "$TIMEDIFF" -gt "$RMTIME" ]; then
            aws ec2 deregister-image --image-id "$i"
            echo -e "${NC}AMI ${RED}$i ${NC}has been ${RED}deregistered${NC}"
           fi
    done
fi

# List images

if [ -n "$AMIID" ]; then
  for i in "${AMIID[@]}"
    do
      CREATETIME="$(date --date="$(aws ec2 describe-images --image-ids $i --output text | grep IMAGES | awk '{print $3}' | cut -d'T' -f1)" +"%s")"
      AMINAME="$(aws ec2 describe-images --image-ids $i --output text | grep IMAGES | awk '{print $9}')"
        TIMEDIFF=$(expr "$TIMESTAMP" - "$CREATETIME")
           if [ "$TIMEDIFF" -gt "$OLDTIME" ]; then
            echo -e "${NC}AMI ID: ${YELLOW}$i ${NC}AMI Name ${YELLOW}$AMINAME${NC}"
           else
             echo -e "${NC}AMI ID: ${GREEN}$i ${NC}AMI Name ${GREEN}$AMINAME${NC}"
           fi
    done
fi
