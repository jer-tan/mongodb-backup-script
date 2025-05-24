# MongoDB Backup to S3 Script

This Bash script backs up a MongoDB database, compresses the backup, and uploads it to an AWS S3 bucket. It's ideal for daily automated backups via cron or manual execution.

## 📦 Features

- Backs up a MongoDB database
- Supports authentication
- Compresses backup into a `.zip` file
- Uploads to an AWS S3 bucket
- Cleans up temporary backup files

## 🧾 Requirements

- `bash`
- `mongodump` (from MongoDB Database Tools)
- `zip`
- `aws-cli`

Install required tools:

```bash
# Ubuntu/Debian
sudo apt install zip awscli
```

## ⚙️ Configuration
Edit the script and update the following variables:

MongoDB
```bash
MONGO_HOST="localhost"
MONGO_PORT="27017"
DATABASE_NAME="your_database_name"
MONGO_USERNAME="your_username"        # Leave blank if not needed
MONGO_PASSWORD="your_password"
MONGO_SSL=""                          # Add SSL options if needed
```

AWS S3
```bash
S3_BUCKET="your_bucket_name"
S3_BACKUP_FOLDER="db_backup"
```

AWS Credential
```bash
AWS_ACCESS_KEY_ID="your_access_key_id"
AWS_SECRET_ACCESS_KEY="your_secret_access_key"
AWS_REGION="ap-southeast-1"
```

Local Backup Directory
```bash
BACKUP_DIR="/backup"
```

## 🏃 Usage
To run the script manually:

```bash
bash backup.sh
```
Or make it executable first:

```bash
chmod +x backup.sh
./backup.sh
```

## ⏰ Scheduling via Cron
To run the backup daily at 2:00 AM:

```bash
crontab -e
```
Add the line:
```bash
0 2 * * * /path/to/backup.sh >> /path/to/backup.log 2>&1
```
## 📁 Output

Compressed backup at: `/backup/YYYY-MM-DD.zip`

Uploaded to: `s3://your_bucket_name/db_backup/YYYY-MM-DD.zip`

## ⚠️ Notes

The script assumes mongodump, zip, and aws CLI are available in PATH.

Logs are not stored unless you configure output redirection in cron or run script manually with `>> log.txt`.
