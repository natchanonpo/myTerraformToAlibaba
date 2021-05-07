# Prerequisites
- The service user that have the following permissions:
  - AliyunOSSFullAccess
  - AliyunECSFullAccess
  - AliyunRDSFullAccess
  - AliyunVPCFullAccess
  - AliyunLogFullAccess
  - AliyunYundunSASFullAccess
  - AliyunARMSFullAccess
  - AliyunFCFullAccess
  - AliyunCSFullAccess
  - AliyunKMSFullAccess
  - AliyunKafkaFullAccess
  - AliyunContainerRegistryFullAccess
  - AliyunAHASFullAccess
- Generate access token and secret token from the service user and save to the Settings -> Secrets of this repository.
# Steps
- Go to Actions and run the `Prepare OSS for Terraform State` pipeline and wait until finish.
- Run `Terraform Non-Prod Deploy` or `Terraform Prod Deploy`, type **yes** and wait until finish.
- Capture the pipeline output by clicking on the job and expand the `Terraform Apply` step.
# Post Steps
- Ask **Zhang, Calvin Zhen** to grant Administrator access to the specific RAM roles e.g. xom-editor on the new K8S cluster that is shown in the output pipeline.
  - Go to the new cluster
  - Click on Authorizations menu on the left
  - Select RAM Roles tab
  - Paste the specific RAM role e.g. xom-editor as a RAM Role Name
  - Select the specific cluster and select Adminstrator role
  - Next until done