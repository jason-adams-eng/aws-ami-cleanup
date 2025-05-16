# AWS AMI and Snapshot Cleanup

This is a work in progress. This script automates the deregistration from a simple text list of old Amazon Machine Images (AMI IDs) and deletes their associated EBS snapshots. Useful for reducing unnecessary storage and maintaining clean AWS environments.

![ShellCheck](https://github.com/jason-adams-eng/aws-ami-cleanup/actions/workflows/shellcheck.yml/badge.svg)

## Script

- `deregister_amis_verbose.sh` — Main script that:
  - Reads AMI IDs from `ami_list.txt`
  - Deregisters each AMI
  - Tags and deletes its associated snapshots
  - Logs all activity with timestamps to `deregistration_log.txt`

## Usage

1. Upload your list of AMI IDs to `ami_list.txt`
2. Make the script executable:
   ```bash
   chmod +x deregister_amis_verbose.sh
   ```
3. Run the script:
   ```bash
   ./deregister_amis_verbose.sh
   ```

## Output

- Creates a full deregistration_log.txt with timestamps
- Adds DeletedBy=CleanupScript and DeleteDate=YYYY-MM-DD tags before snapshot deletion

## Requirements

- AWS CLI configured with sufficient permissions
- Bash shell environment (Linux, macOS, CloudShell, WSL)
