#!/bin/bash
# This is the entry point for configuring the system.
#####################################################

source setup/functions.sh # load our functions

# Check system setup: Are we running as root on Ubuntu 14.04 on a
# machine with enough memory? If not, this shows an error and exits.
source setup/preflight.sh

# Ensure Python reads/writes files in UTF-8. If the machine
# triggers some other locale in Python, like ASCII encoding,
# Python may not be able to read/write files. Here and in
# the management daemon startup script.

if [ -z `locale -a | grep en_US.utf8` ]; then
    # Generate locale if not exists
    hide_output locale-gen en_US.UTF-8
fi

export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_TYPE=en_US.UTF-8

# Recall the last settings used if we're running this a second time.
if [ -f /etc/mailinabox.conf ]; then
	# Run any system migrations before proceeding. Since this is a second run,
	# we assume we have Python already installed.
	setup/migrate.py --migrate || exit 1

	# Load the old .conf file to get existing configuration options loaded
	# into variables with a DEFAULT_ prefix.
	cat /etc/mailinabox.conf | sed s/^/DEFAULT_/ > /tmp/mailinabox.prev.conf
	source /tmp/mailinabox.prev.conf
	rm -f /tmp/mailinabox.prev.conf
fi

# Put a start script in a global location. We tell the user to run 'mailinabox'
# in the first dialog prompt, so we should do this before that starts.
cat > /usr/local/bin/mailinabox << EOF;
#!/bin/bash
cd `pwd`
source setup/start.sh
EOF
chmod +x /usr/local/bin/mailinabox

if [ -n "$NONINTERACTIVE" ]; then
  source setup/runtime_start.sh
  source setup/attended_start.sh
fi

