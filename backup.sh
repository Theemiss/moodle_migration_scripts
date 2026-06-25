#!/bin/bash
set -euo pipefail

MOODLE_DIR="${MOODLE_DIR:-/var/www/html/moodle}"
MOODLE_DATA_DIR="${MOODLE_DATA_DIR:-/var/moodledata}"
BACKUP_DIR="${BACKUP_DIR:-/tmp/moodle_backup}"
S3_BUCKET="${S3_BUCKET:-s3://your-backup-bucket}"

TIMESTAMP=$(date +"%Y%m%d%H%M%S")
mkdir -p "$BACKUP_DIR"

echo "[*] Streaming Moodle code to S3..."
tar -cf - -C "$(dirname "$MOODLE_DIR")" "$(basename "$MOODLE_DIR")" | aws s3 cp - "$S3_BUCKET/moodle_$TIMESTAMP.tar"

echo "[*] Streaming moodledata to S3..."
tar -cf - -C "$(dirname "$MOODLE_DATA_DIR")" "$(basename "$MOODLE_DATA_DIR")" | aws s3 cp - "$S3_BUCKET/moodledata_$TIMESTAMP.tar"

# Optional DB dump:
# mysqldump -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" | aws s3 cp - "$S3_BUCKET/moodle_db_$TIMESTAMP.sql"

echo "moodledata_$TIMESTAMP.tar" > "$BACKUP_DIR/moodledata_version.txt"
echo "moodle_$TIMESTAMP.tar" > "$BACKUP_DIR/moodle_version.txt"

aws s3 cp "$BACKUP_DIR/moodledata_version.txt" "$S3_BUCKET/moodledata_version.txt"
aws s3 cp "$BACKUP_DIR/moodle_version.txt" "$S3_BUCKET/moodle_version.txt"

echo "[OK] Moodle backup uploaded to $S3_BUCKET"
