#!/bin/bash

input_file="ami_list.txt"
log_file="deregistration_log.txt"
date_tag=$(date '+%Y-%m-%d')

# Clear previous log (ShellCheck-safe)
: > "$log_file"

echo "=== AMI & Snapshot Deregistration Started at $(date) ===" | tee -a "$log_file"
echo "" | tee -a "$log_file"

while IFS= read -r ami_id; do
  echo "[$(date '+%F %T')] Processing AMI: $ami_id" | tee -a "$log_file"

  # Get associated snapshots
  snapshot_ids=$(aws ec2 describe-images --image-ids "$ami_id" \
    --query 'Images[].BlockDeviceMappings[].Ebs.SnapshotId' \
    --output text 2>>"$log_file")

  if [ -z "$snapshot_ids" ]; then
    echo "[$(date '+%F %T')] No snapshots found for $ami_id or AMI not found." | tee -a "$log_file"
  else
    echo "[$(date '+%F %T')] Found Snapshots:" | tee -a "$log_file"
    for snapshot_id in $snapshot_ids; do
      echo "  - $snapshot_id" | tee -a "$log_file"
    done
  fi

  # Deregister AMI
  echo "[$(date '+%F %T')] Deregistering AMI: $ami_id" | tee -a "$log_file"
  if aws ec2 deregister-image --image-id "$ami_id" >>"$log_file" 2>&1; then
    echo "[$(date '+%F %T')] Successfully deregistered $ami_id" | tee -a "$log_file"
  else
    echo "[$(date '+%F %T')] Failed to deregister $ami_id, skipping snapshots" | tee -a "$log_file"
    echo "------------------------------" | tee -a "$log_file"
    continue
  fi

  # Tag and delete snapshots
  for snapshot_id in $snapshot_ids; do
    echo "[$(date '+%F %T')] Tagging snapshot: $snapshot_id before deletion" | tee -a "$log_file"
    aws ec2 create-tags --resources "$snapshot_id" \
      --tags "Key=DeletedBy,Value=CleanupScript" "Key=DeleteDate,Value=$date_tag" >>"$log_file" 2>&1

    echo "[$(date '+%F %T')] Deleting snapshot: $snapshot_id" | tee -a "$log_file"
    if aws ec2 delete-snapshot --snapshot-id "$snapshot_id" >>"$log_file" 2>&1; then
      echo "[$(date '+%F %T')] Deleted snapshot $snapshot_id" | tee -a "$log_file"
    else
      echo "[$(date '+%F %T')] Failed to delete snapshot $snapshot_id" | tee -a "$log_file"
    fi
  done

  echo "------------------------------" | tee -a "$log_file"
done < "$input_file"

echo "" | tee -a "$log_file"
echo "=== Completed at $(date) ===" | tee -a "$log_file"
