source setup/functions.sh # load our functions

# Start service configuration.
source setup/system.sh
source setup/ssl.sh
source setup/dns.sh
source setup/mail-postfix.sh
source setup/mail-dovecot.sh
source setup/mail-users.sh
source setup/dkim.sh
source setup/spamassassin.sh
source setup/web.sh
source setup/webmail.sh
source setup/owncloud.sh
source setup/zpush.sh
source setup/management.sh
source setup/munin.sh

# Ping the management daemon to write the DNS and nginx configuration files.
until nc -z -w 4 localhost 10222
do
	echo Waiting for the Mail-in-a-Box management daemon to start...
	sleep 2
done
tools/dns_update
tools/web_update

# If there aren't any mail users yet, create one.
source setup/firstuser.sh

# Done.
echo
echo "-----------------------------------------------"
echo
echo Your Mail-in-a-Box is running.
echo
echo Please log in to the control panel for further instructions at:
echo
if management/status_checks.py --check-primary-hostname; then
	# Show the nice URL if it appears to be resolving and has a valid certificate.
	echo https://$PRIMARY_HOSTNAME/admin
	echo
	echo If you have a DNS problem use the box\'s IP address and check the SSL fingerprint:
	echo https://$PUBLIC_IP/admin
else
	echo https://$PUBLIC_IP/admin
	echo
	echo You will be alerted that the website has an invalid certificate. Check that
	echo the certificate fingerprint matches:
	echo
fi
openssl x509 -in $STORAGE_ROOT/ssl/ssl_certificate.pem -noout -fingerprint \
        | sed "s/SHA1 Fingerprint=//"
echo
echo Then you can confirm the security exception and continue.
echo
