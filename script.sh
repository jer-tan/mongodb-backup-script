#!/bin/bash

set -euo pipefail

# === MongoDB Configuration ===
MONGO_HOST="localhost"
MONGO_PORT="27017"
DATABASE_NAME="your_database_name"
MONGO_USERNAME="your_username"    # Leave empty if not using auth
MONGO_PASSWORD="your_password"    # Leave empty if not using auth
MONGO_SSL=""                      # Example: "--ssl --sslCAFile /path/to/ca.pem"

# === S3 Bucket Configuration ===
S3_BUCKET="your_bucket_name"
S3_BACKUP_FOLDER="backup_dir_in_s3"

# === AWS CLI Configuration (Hardcoded) ===
AWS_REGION="ap-southeast-1"
AWS_ACCESS_KEY_ID="your_access_key_id"
AWS_SECRET_ACCESS_KEY="your_secret_access_key"

# === Backup Directory ===
BACKUP_DIR="/backup"

# === Get current date ===
CURRENT_DATE=$(date +%F)
BACKUP_PATH="$BACKUP_DIR/$CURRENT_DATE"
ZIP_FILE="$BACKUP_DIR/$CURRENT_DATE.zip"

# === Ensure required commands exist ===
for cmd in mongodump aws zip; do
  if ! command -v $cmd &> /dev/null; then
    echo "❌ Error: '$cmd' is not installed."
    exit 1
  fi
done

# === Set AWS credentials in environment ===
export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY
export AWS_REGION

# === Prepare authentication params ===
AUTH_PARAMS=""
if [[ -n "$MONGO_USERNAME" && -n "$MONGO_PASSWORD" ]]; then
  AUTH_PARAMS="--username $MONGO_USERNAME --password $MONGO_PASSWORD --authenticationDatabase admin"
fi

# === Run mongodump ===
echo "📦 Starting MongoDB backup..."
mongodump --host "$MONGO_HOST" --port "$MONGO_PORT" --db "$DATABASE_NAME" $AUTH_PARAMS $MONGO_SSL --out "$BACKUP_PATH"
echo "✅ MongoDB backup successful."

# === Zip the backup ===
echo "🗜 Compressing backup..."
zip -r "$ZIP_FILE" "$BACKUP_PATH"
echo "✅ Backup compressed into $ZIP_FILE."

# === Cleanup local raw backup ===
rm -rf "$BACKUP_PATH"
echo "🧹 Removed temporary backup folder."

# === Upload to S3 ===
echo "☁️ Uploading to S3..."
aws s3 cp "$ZIP_FILE" "s3://$S3_BUCKET/$S3_BACKUP_FOLDER/$CURRENT_DATE.zip"

echo "✅ Backup uploaded to S3: s3://$S3_BUCKET/$S3_BACKUP_FOLDER/$CURRENT_DATE.zip"
echo "🎉 Backup process completed successfully."
