#!/bin/bash

# Start service configuration.

apt_install python3 python3-dev python3-pip \
        wget curl bc \

mount ssl

source setup/mail-postfix.sh
source setup/mail-dovecot.sh
source setup/mail-users.sh
source setup/dkim.sh
source setup/spamassassin.sh
source setup/zpush.sh
source setup/management.sh

