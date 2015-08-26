source setup/functions.sh # load our functions

# Ask the user for the PRIMARY_HOSTNAME, PUBLIC_IP, PUBLIC_IPV6, and CSR_COUNTRY
# if values have not already been set in environment variables. When running
# non-interactively, be sure to set values for all! Also sets STORAGE_USER and
# STORAGE_ROOT.
source setup/questions.sh

# Run some network checks to make sure setup on this machine makes sense.
# Skip on existing installs since we don't want this to block the ability to
# upgrade, and these checks are also in the control panel status checks.
if [ -z "$DEFAULT_PRIMARY_HOSTNAME" ]; then
if [ -z "$SKIP_NETWORK_CHECKS" ]; then
	source setup/network-checks.sh
fi
fi

# Create the STORAGE_USER and STORAGE_ROOT directory if they don't already exist.
# If the STORAGE_ROOT is missing the mailinabox.version file that lists a
# migration (schema) number for the files stored there, assume this is a fresh
# installation to that directory and write the file to contain the current
# migration number for this version of Mail-in-a-Box.
if ! id -u $STORAGE_USER >/dev/null 2>&1; then
	useradd -m $STORAGE_USER
fi
if [ ! -d $STORAGE_ROOT ]; then
	mkdir -p $STORAGE_ROOT
fi
if [ ! -f $STORAGE_ROOT/mailinabox.version ]; then
	echo $(setup/migrate.py --current) > $STORAGE_ROOT/mailinabox.version
	chown $STORAGE_USER.$STORAGE_USER $STORAGE_ROOT/mailinabox.version
fi


# Save the global options in /etc/mailinabox.conf so that standalone
# tools know where to look for data.
cat > /etc/mailinabox.conf << EOF;
STORAGE_USER=$STORAGE_USER
STORAGE_ROOT=$STORAGE_ROOT
PRIMARY_HOSTNAME=$PRIMARY_HOSTNAME
PUBLIC_IP=$PUBLIC_IP
PUBLIC_IPV6=$PUBLIC_IPV6
PRIVATE_IP=$PRIVATE_IP
PRIVATE_IPV6=$PRIVATE_IPV6
CSR_COUNTRY=$CSR_COUNTRY
EOF


