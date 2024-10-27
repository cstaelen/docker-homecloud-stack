#!/bin/bash

export $(grep -v '^#' .env | xargs)

mkdir -p $HOMECLOUD_PATH/exports

echo -n "--- [PHOTOPRISM] Export MySQL dump... "
rm $HOMECLOUD_PATH/apps/photoprism/dump/*.sql
cd $HOMECLOUD_PATH && docker compose exec photoprism photoprism backup -i -a -f
echo "OK"
echo "------------------------------------"

# RASPOTIFY
echo -n "--- Backup raspotify conf... "
cp /etc/default/raspotify $HOMECLOUD_PATH/exports/raspotify
echo "OK"
# Crontab
echo -n "--- Backup contrab file... "
crontab -l > $HOMECLOUD_PATH/exports/crontab_root
echo "OK"
echo "------------------------------------"

# Export Calendar
echo "--- Export calendar perso..."
curl -u $NEXTCLOUD_USER:$NEXTCLOUD_PASSWORD  $NEXTCLOUD_PUBLIC_URL/remote.php/dav/calendars/$NEXTCLOUD_USER/personal/?export > $HOMECLOUD_PATH/exports/calendar-personal.ics
echo "OK"

echo "--- Export calendar Amandine..."
curl -u $NEXTCLOUD_USER:$NEXTCLOUD_PASSWORD  $NEXTCLOUD_PUBLIC_URL/remote.php/dav/calendars/$NEXTCLOUD_USER/business/?export > $HOMECLOUD_PATH/exports/calendar-business.ics
echo "OK"

# Export Contacts
echo "--- Export contacts... "
curl -u $NEXTCLOUD_USER:$NEXTCLOUD_PASSWORD  $NEXTCLOUD_PUBLIC_URL/remote.php/dav/addressbooks/users/$NEXTCLOUD_USER/contacts/?export > $HOMECLOUD_PATH/exports/contacts.vcf
echo "OK"

# RASPBIAN SYSTEM CONFIG FILES
echo "--- Backup homecloud files... "
rsync -a --delete $HOMECLOUD_PATH/* $BACKUP_PATH
echo "OK"

# README
echo `date +"%d/%m/%Y - %H:%M:%S"` > $BACKUP_PATH/.readme