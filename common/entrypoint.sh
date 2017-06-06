#!/bin/bash

###
# vkucukcakar/rsyslog
# rsyslog and logrotate Docker image with automatic configuration file creation and export
# Copyright (c) 2017 Volkan Kucukcakar
# 
# This file is part of vkucukcakar/rsyslog.
# 
# vkucukcakar/rsyslog is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
# 
# vkucukcakar/rsyslog is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
# 
# This copyright notice and license must be retained in all files and derivative works.
###

# Create configuration files using environment variables if auto configuration is enabled and configuration files are not found
if [ "$AUTO_CONFIGURE" == "enable" ]; then
	echo "AUTO_CONFIGURE enabled, starting auto configuration."	
	# Limit environment variables to substitute
	SHELL_FORMAT='$CONTAINER_NAME,$_CONTAINER_LOG_TAG,$COMMON_TAG'
	
	# Check if the required environment variables are set and create configuration files
	if [ ! -z "$CONTAINER_NAME" ] && [ ! -z "$COMMON_TAG" ] && [ ! -z "$CONTAINER_TAGS" ] && [[ $CONTAINER_TAGS =~ ^([[:alnum:]\._-]+[[:blank:]]*)+$ ]]; then
		# Check if /configurations/rsyslog.conf configuration file already exists/mounted
		if [ ! -f /configurations/rsyslog.conf ]; then
			echo "Creating configuration file '/configurations/rsyslog.conf' from template."
			# Substitute the values of environment variables to create the real configuration file from template
			envsubst "$SHELL_FORMAT" < /templates/rsyslog.conf > /configurations/rsyslog.conf
		else
			echo "Configuration file '/configurations/rsyslog.conf' already exists, skipping file creation. You can edit the file according to your needs."
		fi
		
		# Check if /configurations/logrotate.conf configuration file already exists/mounted
		if [ ! -f /configurations/logrotate.conf ]; then
			echo "Creating configuration file '/configurations/logrotate.conf' from template."
			# Substitute the values of environment variables to create the real configuration file from template
			envsubst "$SHELL_FORMAT" < /templates/logrotate.conf > /configurations/logrotate.conf
		else
			echo "Configuration file '/configurations/logrotate.conf' already exists, skipping file creation. You can edit the file according to your needs."
		fi
		
		# Common (catch-all) log tag
		export _CONTAINER_LOG_TAG=$COMMON_TAG
		# Check if /configurations/${COMMON_TAG}-logrotate configuration file already exists/mounted
		if [ ! -f /configurations/${COMMON_TAG}-logrotate ]; then
			echo "Creating configuration file '/configurations/${COMMON_TAG}-logrotate' from template."
			# Substitute the values of environment variables to create the real configuration file from template
			envsubst "$SHELL_FORMAT" < /templates/container-tag-logrotate > /configurations/${COMMON_TAG}-logrotate
		else
			echo "Configuration file '/configurations/${COMMON_TAG}-logrotate' already exists, skipping file creation. You can edit the file according to your needs."
		fi
		
		# Parse CONTAINER_TAGS. CONTAINER_TAGS contains log tags separated by space. (e.g.: "example-com-web example-com-php")
		for _CONTAINER_LOG_TAG in $CONTAINER_TAGS; do
			# export new variables to use with envsubst later (required here!)
			export _CONTAINER_LOG_TAG
			echo "Creating configuration files container log tag ${_CONTAINER_LOG_TAG}"
			# Check if /configurations/${_CONTAINER_LOG_TAG}-rsyslog.conf configuration file already exists/mounted
			if [ ! -f /configurations/${_CONTAINER_LOG_TAG}-rsyslog.conf ]; then
				echo "Creating configuration file '/configurations/${_CONTAINER_LOG_TAG}-rsyslog.conf' from template."
				# Substitute the values of environment variables to create the real configuration file from template
				envsubst "$SHELL_FORMAT" < /templates/container-tag-rsyslog.conf > /configurations/${_CONTAINER_LOG_TAG}-rsyslog.conf
			else
				echo "Configuration file '/configurations/${_CONTAINER_LOG_TAG}-rsyslog.conf' already exists, skipping file creation. You can edit the file according to your needs."
			fi

			# Check if /configurations/${_CONTAINER_LOG_TAG}-logrotate configuration file already exists/mounted
			if [ ! -f /configurations/${_CONTAINER_LOG_TAG}-logrotate ]; then
				echo "Creating configuration file '/configurations/${_CONTAINER_LOG_TAG}-logrotate' from template."
				# Substitute the values of environment variables to create the real configuration file from template
				envsubst "$SHELL_FORMAT" < /templates/container-tag-logrotate > /configurations/${_CONTAINER_LOG_TAG}-logrotate
			else
				echo "Configuration file '/configurations/${_CONTAINER_LOG_TAG}-logrotate' already exists, skipping file creation. You can edit the file according to your needs."
			fi
			
			# Create symbolic links for configuration files
			# Create symbolic link for configuration file '/configurations/${_CONTAINER_LOG_TAG}-rsyslog.conf' to real location
			if [ -f /configurations/${_CONTAINER_LOG_TAG}-rsyslog.conf ] && [ ! -f /etc/rsyslog.d/${_CONTAINER_LOG_TAG}-rsyslog.conf ]; then
				echo "Creating symbolic link for configuration file '/configurations/${_CONTAINER_LOG_TAG}-rsyslog.conf' to '/etc/rsyslog.d/${_CONTAINER_LOG_TAG}-rsyslog.conf'"
				ln -s /configurations/${_CONTAINER_LOG_TAG}-rsyslog.conf /etc/rsyslog.d/${_CONTAINER_LOG_TAG}-rsyslog.conf
			fi
			
			# Create symbolic link for configuration file '/configurations/${_CONTAINER_LOG_TAG}-logrotate' to real location
			if [ -f /configurations/${_CONTAINER_LOG_TAG}-logrotate ] && [ ! -f /etc/logrotate.d/${_CONTAINER_LOG_TAG}-logrotate ]; then
				echo "Creating symbolic link for configuration file '/configurations/${_CONTAINER_LOG_TAG}-logrotate' to '/etc/logrotate.d/${_CONTAINER_LOG_TAG}-logrotate'"
				ln -s /configurations/${_CONTAINER_LOG_TAG}-logrotate /etc/logrotate.d/${_CONTAINER_LOG_TAG}-logrotate
			fi			
		done
	else
		echo "Error: One or more environment variable required for AUTO_CONFIGURE is not set, please check: CONTAINER_NAME, COMMON_TAG, CONTAINER_TAGS"
		exit 1
	fi	
	
	# Create symbolic links for common configuration file(s)	
	# Create symbolic link for configuration file '/configurations/rsyslog.conf' to real location
	if [ -f /configurations/rsyslog.conf ] && [ ! -f /etc/rsyslog.conf ]; then
		echo "Creating symbolic link for configuration file '/configurations/rsyslog.conf' to '/etc/rsyslog.conf'"
		ln -s /configurations/rsyslog.conf /etc/rsyslog.conf
	fi

	# Create symbolic link for configuration file '/configurations/logrotate.conf' to real location
	if [ -f /configurations/logrotate.conf ] && [ ! -f /etc/logrotate.conf ]; then
		echo "Creating symbolic link for configuration file '/configurations/logrotate.conf' to '/etc/logrotate.conf'"
		ln -s /configurations/logrotate.conf /etc/logrotate.conf
	fi

	# Create symbolic link for configuration file '/configurations/${COMMON_TAG}-logrotate' to real location
	if [ -f /configurations/${COMMON_TAG}-logrotate ] && [ ! -f /etc/logrotate.d/${COMMON_TAG}-logrotate ]; then
		echo "Creating symbolic link for configuration file '/configurations/${COMMON_TAG}-logrotate' to '/etc/logrotate.d/${COMMON_TAG}-logrotate'"
		ln -s /configurations/${COMMON_TAG}-logrotate /etc/logrotate.d/${COMMON_TAG}-logrotate
	fi
	echo "AUTO_CONFIGURE completed."
else
	echo "AUTO_CONFIGURE disabled."
fi


# Empty /etc/rsyslog.d directory notice
if [ ! "$(ls -A /etc/rsyslog.d)" ]; then
	echo 'Notice: Empty "/etc/rsyslog.d" directory.'
fi

# Empty /etc/logrotate.d directory notice
if [ ! "$(ls -A /etc/logrotate.d)" ]; then
	echo 'Notice: Empty "/etc/logrotate.d" directory.'
fi

# Validate logrotate files
if logrotate -d /etc/logrotate.d/*; then
	echo 'Warning: You logrotate file(s) under "/etc/logrotate.d/" did not passed the validity check.'
fi

# Execute another entrypoint or CMD if there is one
if [[ "$@" ]]; then
	echo "Executing $@"
	$@
	EXITCODE=$?
	if [[ $EXITCODE > 0 ]]; then 
		exit $EXITCODE
	fi
fi
