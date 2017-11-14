> Create an AMI of the EC2 instances for backup based on tag “Backup” (if set to “true” - instance should be backup)

Achieved by using flag `--filters "Name=tag:Backup,Values=true` for command `aws ec2 describe-instances`.

> Script should not reboot the servers 

Achieved by using flag `--no-reboot` for command `aws ec2 create-image`.

> set a descriptive name for the AMI based on the
Name of the ec2 instance along with the date

Achieved by using bash variables and filtering output of command `aws ec2 describe-instances`

> AMIs older than 7 days should be removed

Achieved by parsing creation date of the AMI and converting it to timestamp
```
date --date="$(aws ec2 describe-images --image-ids ami-something --output text | grep IMAGES | awk '{print $3}' | cut -d'T' -f1)" +"%s"
```
> The full list of AMIs should be printed on the final output - the old ones should be highlighted yellow, new ones - by green colors.

Achieved by parsing creation date of the AMI and converting it to timestamp. Image considers to become old if it's creation time became older then one day.
Text color highlight achieved by using ANSI escape codes.
```
RED='\033[0;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
NC='\033[0m'
```