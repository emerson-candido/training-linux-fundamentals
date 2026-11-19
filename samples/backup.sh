#!/usr/bin/env bash
# ==============================================================================
# Script 1: Simple Automated Directory Backup
# Demonstrates: Shebang, variables, command substitution, mkdir, tar
# ==============================================================================

SOURCE_DIR="$HOME/myfolder"
BACKUP_DIR="$HOME/backups"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
ARCHIVE_NAME="backup_${TIMESTAMP}.tar.gz"

# Create the backup folder if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Compress the source directory into a timestamped archive
tar -czf "${BACKUP_DIR}/${ARCHIVE_NAME}" "$SOURCE_DIR" 2>/dev/null

echo "[$(date)] Backup completed: ${BACKUP_DIR}/${ARCHIVE_NAME}"
