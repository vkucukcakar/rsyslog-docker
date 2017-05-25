# vkucukcakar/rsyslog

rsyslog and logrotate Docker image with automatic configuration file creation and export

* Brings plain text logging to Docker with rsyslog and built-in logrotate.
* For use with Docker's syslog logging driver
* Auto create or use configuration files at volume "/configurations" using environment variables
* Various logs are written to text files at volume "/var/log"
* Based on vkucukcakar/runit image for service supervision and zombie reaping
* Alpine and Debian based images

(Note: The image's own logs are sent back to Docker, not written to text files.)

## Supported tags

* alpine, latest
* debian

## Environment variables supported

* AUTO_CONFIGURE=[enable|disable]

* EXECUTABLES=[space separated filenames to give execute permission]

* CONTAINER_NAME=[your-container-name]

* COMMON_TAG=[log-tag-for-common-logs]

* CONTAINER_TAGS=[space separated container log tags]