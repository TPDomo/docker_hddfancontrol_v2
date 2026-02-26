# !!!!! Warning: Not ready - WIP !!!!!

!
!
!
!
!
!

## docker_hddfancontrol
simple Docker image for hddfancontrol by desbma
https://github.com/desbma/hddfancontrol

This is a docker image which includes the following programs to run **hddfancontrol** by desbma.
- smartmontools - needed for the --smartctl option, which uses smartmontolls instead of hdparm to spindown drives
- hdparm - old way of spinning down drives
- hddtemp - to get hddtemps
- fancontrol - to control PWM fan speed
- lm-sensors - package for pwm sensor detect

### Docker compose
- currently privbiliged mode is used, since I didnt find an easy way to bind the sysfs hwmon instances 
- all ENV variables are optional, but hddfancontrol will complain when something important is missing.
```
version: "3"
services:
  hddfancontrol:
    #image: ghcr.io/fightforlife/docker_hddfancontrol:master
    image: docker_hddfancontrol_v2:latest
    restart: unless-stopped
    volumes:
      - /lib/modules:/lib/modules:ro #needed for hwmon
      - /dev:/dev:ro #needed for disks by id
    devices:
      - /dev/i2c-0:/dev/i2c-0
      - /dev/i2c-1:/dev/i2c-1
    privileged: true
    cap_add:
      - SYS_MODULE
      #- SYS_RAWIO #is it really needed?
    environment:
      #- DRIVE_FILEPATHS=/dev/sda1 /dev/sdb1 /dev/sdf1 /dev/sdg1 /dev/sdd1
      #- DRIVE_FILEPATHS=/dev/disk/by-id/ata-SAMSUNG_HD501LJ-part1 /dev/disk/by-id/ata-WDC_WD15EADS-part1 /dev/disk/by-id/ata-ST4000VN006-part1 /dev/disk/by-id/ata-ST4000VN008-part1
      - DRIVE_FILEPATHS=/dev/disk/by-id/ata-ST12000NE0007-2GT116_ZJV3PA2J-part1 /dev/disk/by-id/ata-ST12000NE0008-2JL101_ZHZ0E5PQ-part1 /dev/disk/by-id/ata-ST12000NE0008-2JL101_ZHZ0TR10-part1 /dev/disk/by-id/ata-ST12000NE0008-2JL101_ZHZ658ZR-part1 /dev/disk/by-id/ata-Samsung_SSD_850_PRO_256GB_S1SUNSAFA28321V-part1 /dev/disk/by-id/ata-Samsung_SSD_850_PRO_256GB_S1SUNSAFC11887N-part1
      #- FAN_PWM_FILEPATH=/sys/class/hwmon/hwmon4/pwm1:70:20 /sys/class/hwmon/hwmon4/pwm3:70:20 /sys/class/hwmon/hwmon4/pwm4:70:20 /sys/class/hwmon/hwmon4/pwm5:70:20
      - FAN_PWM_FILEPATH=/sys/class/hwmon/hwmon10/pwm1:70:20 /sys/class/hwmon/hwmon10/pwm2:70:20 /sys/class/hwmon/hwmon10/pwm4:70:20 /sys/class/hwmon/hwmon10/pwm5:70:20
#      - FAN_START_VALUE=70 80
#      - FAN_STOP_VALUE=20 30
#      - MIN_TEMP=40
#      - MAX_TEMP=60
#      - MIN_FAN_SPEED_PRCT=0
      - INTERVAL_S=60sec
#      - CPU_PROBE_FILEPATH=/sys/devices/platform/coretemp.0/hwmon/hwmon0/tempY_input
#      - CPU_TEMP_RANGE=50 70
#      - SPIN_DOWN_TIME_S=900
#      - VERBOSITY=debug
#      - LOG_FILEPATH=/var/log/hddfancontrol.log
#      - TEMP_QUERY_MODE=smartctl  #hddtemp,hdparm,drivetemp,smartctl 
      
      
```

### ToDo
- [X] Split the $ARGS environment variable into the individual configuration paramters
- [ ] Find a way to get rid of the priviliged mode and use the devices directly
- [X] incoperate lm-sensors into the container including the kernel modules
- [ ] run and expose hddtemp daemon
- [X] make way of fetching temp a config

