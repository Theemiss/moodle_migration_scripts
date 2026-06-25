#!/bin/bash
set -euo pipefail

MOODLE_DIR="${MOODLE_DIR:-/var/www/html/moodle}"
MOODLE_DATA_DIR="${MOODLE_DATA_DIR:-/var/moodledata}"
S3_BUCKET="${S3_BUCKET:-s3://your-backup-bucket}"
TEMP_DIR="${TEMP_DIR:-./moodle_restore}"

mkdir -p "$TEMP_DIR" "$MOODLE_DIR" "$MOODLE_DATA_DIR"

echo "[*] Downloading version markers from $S3_BUCKET"
aws s3 cp "$S3_BUCKET/moodledata_version.txt" "$TEMP_DIR/"
aws s3 cp "$S3_BUCKET/moodle_version.txt" "$TEMP_DIR/"

MOODLE_VERSION=$(cat "$TEMP_DIR/moodle_version.txt")
MOODLE_DATA_VERSION=$(cat "$TEMP_DIR/moodledata_version.txt")

echo "[*] Downloading archives..."
aws s3 cp "$S3_BUCKET/$MOODLE_VERSION" "$TEMP_DIR/"
aws s3 cp "$S3_BUCKET/$MOODLE_DATA_VERSION" "$TEMP_DIR/"

echo "[*] Restoring Moodle code..."
tar -xf "$TEMP_DIR/$MOODLE_VERSION" -C "$(dirname "$MOODLE_DIR")"

echo "[*] Restoring moodledata..."
tar -xf "$TEMP_DIR/$MOODLE_DATA_VERSION" -C "$(dirname "$MOODLE_DATA_DIR")"

# Optional DB restore:
# aws s3 cp "$S3_BUCKET/moodle_db_$TIMESTAMP.sql" "$TEMP_DIR/"
# mysql -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" < "$TEMP_DIR/moodle_db_$TIMESTAMP.sql"

rm -rf "$TEMP_DIR"
echo "[OK] Moodle restore completed"
