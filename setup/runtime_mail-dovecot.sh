source setup/functions.sh # load our functions

# Set the location where we'll store user mailboxes. '%d' is the domain name and '%n' is the
# username part of the user's email address. We'll ensure that no bad domains or email addresses
# are created within the management daemon.
tools/editconf.py /etc/dovecot/conf.d/10-mail.conf \
	mail_location=maildir:$STORAGE_ROOT/mail/mailboxes/%d/%n \
	mail_privileged_group=mail \
	first_valid_uid=0

# Enable SSL, specify the location of the SSL certificate and private key files.
# Disable obsolete SSL protocols and allow only good ciphers per http://baldric.net/2013/12/07/tls-ciphers-in-postfix-and-dovecot/.
tools/editconf.py /etc/dovecot/conf.d/10-ssl.conf \
	ssl=required \
	"ssl_cert=<$STORAGE_ROOT/ssl/ssl_certificate.pem" \
	"ssl_key=<$STORAGE_ROOT/ssl/ssl_private_key.pem" \
	"ssl_protocols=!SSLv3 !SSLv2" \
	"ssl_cipher_list=TLSv1+HIGH !SSLv2 !RC4 !aNULL !eNULL !3DES @STRENGTH"

# Setting a `postmaster_address` is required or LMTP won't start. An alias
# will be created automatically by our management daemon.
tools/editconf.py /etc/dovecot/conf.d/15-lda.conf \
	postmaster_address=postmaster@$PRIMARY_HOSTNAME

# Configure sieve. We'll create a global script that moves mail marked
# as spam by Spamassassin into the user's Spam folder.
#
# * `sieve_before`: The path to our global sieve which handles moving spam to the Spam folder.
#
# * `sieve`: The path to the user's main active script. ManageSieve will create a symbolic
# link here to the actual sieve script. It should not be in the mailbox directory
# (because then it might appear as a folder) and it should not be in the sieve_dir
# (because then I suppose it might appear to the user as one of their scripts).
# * `sieve_dir`: Directory for :personal include scripts for the include extension. This
# is also where the ManageSieve service stores the user's scripts.
cat > /etc/dovecot/conf.d/99-local-sieve.conf << EOF;
plugin {
  sieve_before = /etc/dovecot/sieve-spam.sieve
  sieve = $STORAGE_ROOT/mail/sieve/%d/%n.sieve
  sieve_dir = $STORAGE_ROOT/mail/sieve/%d/%n
}
EOF

# PERMISSIONS

# Ensure configuration files are owned by dovecot and not world readable.
chown -R mail:dovecot /etc/dovecot
chmod -R o-rwx /etc/dovecot

# Ensure mailbox files have a directory that exists and are owned by the mail user.
mkdir -p $STORAGE_ROOT/mail/mailboxes
chown -R mail.mail $STORAGE_ROOT/mail/mailboxes

# Same for the sieve scripts.
mkdir -p $STORAGE_ROOT/mail/sieve
chown -R mail.mail $STORAGE_ROOT/mail/sieve

