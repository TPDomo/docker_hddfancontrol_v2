#use official slim python image
FROM rust:slim AS build

#update repository
RUN apt-get update

#install needed packages
#hddtemp package is deprecated as of debian bookworm, see https://groups.google.com/g/linux.debian.bugs.dist/c/fRxG4xEJQUs
RUN apt-get install -y smartmontools hdparm fancontrol lm-sensors kmod git sdparm

#install hddfancontrol
RUN git clone https://github.com/desbma/hddfancontrol
RUN cd hddfancontrol && \
    cargo build --release && \
    install -Dm 755 -t /usr/local/bin target/release/hddfancontrol
RUN install -Dm 644 hddfancontrol/systemd/hddfancontrol.service /etc/systemd/system/hddfancontrol.service
RUN install -Dm 644 hddfancontrol/systemd/hddfancontrol.conf /etc/conf.d/hddfancontrol
RUN rm -rf hddfancontrol


FROM debian:bookworm-slim

#update repository
RUN apt-get update

#install needed packages
#hddtemp package is deprecated as of debian bookworm, see https://groups.google.com/g/linux.debian.bugs.dist/c/fRxG4xEJQUs
RUN apt-get install -y smartmontools hdparm fancontrol lm-sensors kmod git sdparm

RUN apt-get clean -y

COPY --from=build /usr/local/bin/hddfancontrol /usr/local/bin/hddfancontrol
RUN chmod 755 /usr/local/bin/hddfancontrol
COPY --from=build /etc/systemd/system/hddfancontrol.service /etc/systemd/system/hddfancontrol.service
RUN chmod 644 /etc/systemd/system/hddfancontrol.service
COPY --from=build /etc/conf.d/hddfancontrol /etc/conf.d/hddfancontrol
RUN chmod 644 /etc/conf.d/hddfancontrol

#start hddtemp daemon and expose port
#EXPOSE 7634
#CMD hddtemp -q -d -F /dev/sd*
COPY start_services.sh /usr/local/bin
RUN chmod +x /usr/local/bin/start_services.sh
CMD /usr/local/bin/start_services.sh
