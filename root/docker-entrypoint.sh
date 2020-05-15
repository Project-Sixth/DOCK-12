#!/bin/bash

# If there is no virtual_users.txt file inside /etc/vsftpd dir, then generate either user
if [ ! -f /etc/vsftpd/virtual_users.txt ]; then
	# This one is for later, since we generate user manually
	export FTP_BLANK="Yup..."

	# If no env var for FTP_USER has been specified, use 'admin':
	if [ "$FTP_USER" = "**String**" ]; then
		export FTP_USER='admin'
	fi
	# If no env var has been specified for password, generate a random password for FTP_USER:
	if [ "$FTP_PASS" = "**Random**" ]; then
		export FTP_PASS=$(cat /dev/urandom | tr -dc [:upper:][:lower:][:digit:] | head -c 16)
	fi
	echo -e "${FTP_USER}\n${FTP_PASS}" > /etc/vsftpd/virtual_users.txt
	ln -sf /mnt "/home/${FTP_USER}"
fi

# Regardless of existence of virtual_users file, now it should be here. Create users.db
db_load -T -t hash -f /etc/vsftpd/virtual_users.txt /etc/vsftpd/virtual_users.db

# If FTP_OWN is active then own /mnt as well
if [ "$FTP_OWN" = "YES" ]; then
	chown -R ftp:ftp /home
	chown -R ftp:ftp /mnt
fi

# Set passive mode parameters:
if [ "$PASV_ADDRESS" = "**IPv4**" ]; then
	export PASV_ADDRESS="127.0.0.1"
fi

# Append parameters to config
echo "pasv_address=${PASV_ADDRESS}" >> /etc/vsftpd/vsftpd.conf
echo "pasv_max_port=${PASV_MAX_PORT}" >> /etc/vsftpd/vsftpd.conf
echo "pasv_min_port=${PASV_MIN_PORT}" >> /etc/vsftpd/vsftpd.conf
echo "pasv_addr_resolve=${PASV_ADDR_RESOLVE}" >> /etc/vsftpd/vsftpd.conf
echo "pasv_enable=${PASV_ENABLE}" >> /etc/vsftpd/vsftpd.conf
echo "file_open_mode=${FILE_OPEN_MODE}" >> /etc/vsftpd/vsftpd.conf
echo "local_umask=${LOCAL_UMASK}" >> /etc/vsftpd/vsftpd.conf
echo "xferlog_std_format=${XFERLOG_STD_FORMAT}" >> /etc/vsftpd/vsftpd.conf

# stdout server info:
if [ ! "$FTP_BLANK" ]; then
cat << EOB
        *************************************************
        *                                               *
        *    Docker image: projectsixth/vsftpd          *
        *      Made for ProfitClicks Company 15052020   *
        *                                               *
        *************************************************

        SERVER SETTINGS
        ---------------
        · FTP User: As specified in mounted /virtual_users.txt file
        · FTP Password: As specified in mounted /virtual_users.txt file
        · Log file: Docker STDOUT
EOB
else
cat << EOB
        *************************************************
        *                                               *
        *    Docker image: projectsixth/vsftpd          *
        *      Made for ProfitClicks Company 15052020   *
        *                                               *
        *************************************************

        SERVER SETTINGS
        ---------------
        · FTP User: $FTP_USER
        · FTP Password: $FTP_PASS
        · Log file: Docker STDOUT
EOB
fi

# Run vsftpd:
/usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf
