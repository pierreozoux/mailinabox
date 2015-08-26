source setup/functions.sh # load our functions

# ### Basic Settings

# Set some basic settings...
#
# * Have postfix listen on all network interfaces.
# * Set our name (the Debian default seems to be "localhost" but make it our hostname).
# * Set the name of the local machine to localhost, which means xxx@localhost is delivered locally, although we don't use it.
# * Set the SMTP banner (which must have the hostname first, then anything).
tools/editconf.py /etc/postfix/main.cf \
	inet_interfaces=all \
	myhostname=$PRIMARY_HOSTNAME\
	smtpd_banner="\$myhostname ESMTP Hi, I'm a Mail-in-a-Box (Ubuntu/Postfix; see https://mailinabox.email/)" \
	mydestination=localhost

# Modify the `outgoing_mail_header_filters` file to use the local machine name and ip
# on the first received header line.  This may help reduce the spam score of email by
# removing the 127.0.0.1 reference.
sed -i "s/PRIMARY_HOSTNAME/$PRIMARY_HOSTNAME/" /etc/postfix/outgoing_mail_header_filters
sed -i "s/PUBLIC_IP/$PUBLIC_IP/" /etc/postfix/outgoing_mail_header_filters

# Enable TLS on these and all other connections (i.e. ports 25 *and* 587) and
# require TLS before a user is allowed to authenticate. This also makes
# opportunistic TLS available on *incoming* mail.
# Set stronger DH parameters, which via openssl tend to default to 1024 bits
# (see ssl.sh).
tools/editconf.py /etc/postfix/main.cf \
	smtpd_tls_security_level=may\
	smtpd_tls_auth_only=yes \
	smtpd_tls_cert_file=$STORAGE_ROOT/ssl/ssl_certificate.pem \
	smtpd_tls_key_file=$STORAGE_ROOT/ssl/ssl_private_key.pem \
	smtpd_tls_dh1024_param_file=$STORAGE_ROOT/ssl/dh2048.pem \
	smtpd_tls_ciphers=medium \
	smtpd_tls_exclude_ciphers=aNULL \
	smtpd_tls_received_header=yes

