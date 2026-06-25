# moodle_migration_scripts

Bash toolkit for **Moodle** backup/restore via S3 and batch plugin installation from a JSON manifest. Works with traditional installs and container targets (see `Dockerfile` for Bitnami base).

Pairs with public [moodle_sdk](https://github.com/Theemiss/moodle_sdk) and [moodle-local_oauth](https://github.com/Theemiss/moodle-local_oauth).

---

## Scripts

| Script | Purpose |
|--------|---------|
| `backup.sh` | Stream Moodle code + moodledata tarballs to S3 |
| `restore.sh` | Pull version markers and archives from S3, restore locally |
| `plugin.sh` | Install plugins listed in `plugins.json` (zip, tar.gz, git) |
| `theme.sh` | Extract a theme tarball into the Moodle themes directory |
| `setup.sh` | Install OS dependencies (jq, awscli, etc.) |

---

## Quick start

```bash
git clone https://github.com/Theemiss/moodle_migration_scripts.git
cd moodle_migration_scripts
./setup.sh
```

### Backup

```bash
export S3_BUCKET="s3://your-backup-bucket"
export MOODLE_DIR="/var/www/html/moodle"
export MOODLE_DATA_DIR="/var/moodledata"
sudo -E ./backup.sh
```

### Restore

```bash
export S3_BUCKET="s3://your-backup-bucket"
export MOODLE_DIR="/var/www/html/moodle"
export MOODLE_DATA_DIR="/var/moodledata"
sudo -E ./restore.sh
```

### Plugins

Edit `plugins.json`, then:

```bash
export INSTALL_DIR="./moodle_installation"
./plugin.sh
```

---

## Environment variables

| Variable | Scripts | Default |
|----------|---------|---------|
| `S3_BUCKET` | backup, restore | `s3://your-backup-bucket` |
| `MOODLE_DIR` | backup, restore | `/var/www/html/moodle` |
| `MOODLE_DATA_DIR` | backup, restore | `/var/moodledata` |
| `BACKUP_DIR` | backup | `/tmp/moodle_backup` |
| `INSTALL_DIR` | plugin | `./moodle_installation` |
| `PLUGIN_FILE` | plugin | `./plugins.json` |
| `THEME_TAR_FILE` | theme | `./Themes/theme.tar.gz` |
| `THEMES_DIR` | theme | `./moodle_installation/theme` |

---

## Plugin manifest

`plugins.json` entries:

```json
{
  "name": "local_oauth",
  "link": "https://github.com/Theemiss/moodle-local_oauth.git",
  "type": "git",
  "version": "1.0"
}
```

Supported `type` values: `zip`, `tar.gz`, `git`.

---

## Moodle config

Copy `config.php.example` to your Moodle root as `config.php` and edit credentials. **Do not commit** real `config.php` files.

---

## Docker

```dockerfile
FROM bitnami/moodle:4.2-debian-11
```

Extend the base image and layer your restored code or use as a migration target.

---

## Requirements

- bash, tar, awscli, jq, curl, unzip, git
- AWS credentials configured for S3 access
- Run backup/restore as a user with read/write access to Moodle paths

---

## License

MIT - see [LICENSE](LICENSE).
