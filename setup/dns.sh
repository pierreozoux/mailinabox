#!/bin/bash
# DNS
# -----------------------------------------------

# This script installs packages, but the DNS zone files are only
# created by the /dns/update API in the management server because
# the set of zones (domains) hosted by the server depends on the
# mail users & aliases created by the user later.

source setup/functions.sh # load our functions
source /etc/mailinabox.conf # load global vars

# Install the packages.
#
# * nsd: The non-recursive nameserver that publishes our DNS records.
# * ldnsutils: Helper utilities for signing DNSSEC zones.
# * openssh-client: Provides ssh-keyscan which we use to create SSHFP records.
echo "Installing nsd (DNS server)..."
apt_install nsd ldnsutils openssh-client

# Prepare nsd's configuration.

mkdir -p /var/run/nsd

cat > /etc/nsd/nsd.conf << EOF;
# No not edit. Overwritten by Mail-in-a-Box setup.
server:
  hide-version: yes

  # identify the server (CH TXT ID.SERVER entry).
  identity: ""

  # The directory for zonefile: files.
  zonesdir: "/etc/nsd/zones"

  # Allows NSD to bind to IP addresses that are not (yet) added to the
  # network interface. This allows nsd to start even if the network stack
  # isn't fully ready, which apparently happens in some cases.
  # See https://www.nlnetlabs.nl/projects/nsd/nsd.conf.5.html.
  ip-transparent: yes

EOF

if [ -n "$NONINTERACTIVE" ]; then
  source setup/runtime_dns.sh
fi

# Force the dns_update script to be run every day to re-sign zones for DNSSEC
# before they expire. When we sign zones (in `dns_update.py`) we specify a
# 30-day validation window, so we had better re-sign before then.
cat > /etc/cron.daily/mailinabox-dnssec << EOF;
#!/bin/bash
# Mail-in-a-Box
# Re-sign any DNS zones with DNSSEC because the signatures expire periodically.
`pwd`/tools/dns_update
EOF
chmod +x /etc/cron.daily/mailinabox-dnssec

# Permit DNS queries on TCP/UDP in the firewall.

ufw_allow domain

