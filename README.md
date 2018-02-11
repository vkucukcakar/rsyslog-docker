# vkucukcakar/rsyslog

rsyslog and logrotate Docker image with automatic configuration file creation and export

* Brings plain text logging to Docker with rsyslog and built-in logrotate.
* For use with Docker's syslog logging driver
* Automatic configuration creates well-commented configuration files using environment variables or use configuration files at volume "/configurations"
* Various logs are written to text files at volume "/var/log"
* Based on vkucukcakar/runit image for service supervision and zombie reaping
* Alpine and Debian based images

(Note: The image's own logs are sent back to Docker, not written to text files.)

## Supported tags

* alpine, latest
* debian

## Environment variables supported

* AUTO_CONFIGURE=[enable|disable]
	Enable automatic configuration file creation
* CONTAINER_NAME=[my-rsyslog-container]
	Current container name
* COMMON_TAG=[server-common]
	Log tag for common logs
* CONTAINER_TAGS=["server-proxy example-com-web"]
	Space separated container log tags
	
## Caveats

* Automatic configuration, creates configuration files using the supported environment variables 
  unless they already exist at /configurations directory. These are well-commented configuration files
  that you can edit according to your needs and make them persistent by mounting /configurations directory 
  to a location on host. If you need to re-create them using the environment variables, then you must
  delete the old ones. This is all by design.
