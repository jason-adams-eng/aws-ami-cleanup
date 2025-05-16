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
3. Dry-run preview (try this first)
   ```bash
   ./deregister_amis_verbose.sh --dry-run ami_list.txt
   ```
4. Real execution
   ```bash
   ./deregister_amis_verbose.sh ami_list.txt
   ```

## Output

- Creates a full deregistration_log.txt with timestamps
- Adds DeletedBy=CleanupScript and DeleteDate=YYYY-MM-DD tags before snapshot deletion

## Requirements

- AWS CLI configured with sufficient permissions
- Bash shell environment (Linux, macOS, CloudShell, WSL)
- The ami_list.txt file must be saved as an "LF"-based text file (not MS Windows "CLRF" type) for proper end of line breaks.

## Log file

The log file will look similar to this (dry run mode):

```text
=== AMI & Snapshot Deregistration Started at Fri May 16 06:40:11 PM UTC 2025 ===
Dry-run mode: true
=== DEBUG: Contents of ami_list.txt ===
ami-1234567890abcdefg
DEBUG: Read AMI ID = 'ami-1234567890abcdefg'
[2025-05-16 18:40:11] Processing AMI: ami-1234567890abcdefg
[2025-05-16 18:40:12] Found Snapshots:
- snap-abcdefg1234567890
  [2025-05-16 18:40:12] Deregistering AMI: ami-1234567890abcdefg
  [2025-05-16 18:40:12] [DRY-RUN] Would deregister ami-1234567890abcdefg
  [2025-05-16 18:40:12] Tagging snapshot: snap-abcdefg1234567890 before deletion
  [2025-05-16 18:40:12] [DRY-RUN] Would tag and delete snapshot snap-abcdefg1234567890
---
=== Completed at Fri May 16 06:40:24 PM UTC 2025 ===
```
