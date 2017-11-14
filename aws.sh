
#!/bin/bash
set -x
TAG_KEY=Backup
TAG_VALUE=true
NOW="$(date +%y-%m-%d-%H%M%S)"
TIMESTAMP="$(date +%s)"
OLDTIME=7200

# Backup instances

instance=( `aws ec2 describe-instances --filters "Name=tag:$TAG_KEY,Values=$TAG_VALUE" --output text | grep INSTANCES | awk '{print $9}'` )

  for f in "${instance[@]}"
    do
      instancename=$(aws ec2 describe-instances  --instance-ids "$f" --output text | grep Name | awk '{print $3}')
      echo "Creating AMI from instance $f-$instancename"
      aws ec2 create-image --instance-id "$f" --name "$instancename"."$NOW" --no-reboot
    done

# Delete old AMIs

amiid=( `aws ec2 describe-images  --output text | grep IMAGES | awk '{print $9}'` )

  for i in "${amiid[@]}"
    do
      creation-date="$(date --date="$(aws ec2 describe-images --image-ids $i --output text | grep IMAGES | awk '{print $3}' | cut -d'T' -f1)" +"%s")"
        TIMEDIFF=$(expr $TIMESTAMP - $creation-date)
           if [ $TIMEDIFF -gt $OLDTIME ]; then
            aws ec2 deregister-image --image-id $i
            echo "AMI $i has been deregistered"
           fi
    done


