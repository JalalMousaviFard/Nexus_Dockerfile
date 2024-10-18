FROM ubuntu:latest

#Please be informed that the following commands are reviewed for Nexus Repository manager image...
RUN apt update && apt install openjdk-17-jdk ufw iputils-ping -y

WORKDIR /opt

#we should have downloaded latest tar gz file for the sonatype nexus before proceeding using "wget https://download.sonatype.com/nexus/3/latest-unix.tar.gz"
#and then copy it in the working directory as follows:

COPY . .

#now that we have the tar file in the image we untar it:

RUN tar -xvzf nexus-3.73.0-12-unix.tar.gz 

RUN mv /opt/nexus-3.73.0-12 /opt/nexus

#to reduce image size ! 
RUN rm -rf nexus-3.73.0-12-unix.tar.gz
#adds user "nexus"
RUN useradd nexus
USER nexus
ENV user=nexus

USER root
#getting the nexus user as a sudoer and changing the permissions in a chain of commands...
RUN echo "nexus ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && chown -R nexus:nexus /opt/nexus && chown -R nexus:nexus /opt/sonatype-work

#this adds a pre-written nexus systemd service to desired destination
RUN mv nexus.service /etc/systemd/system/nexus.service

RUN systemctl enable nexus

#firewall configuration

RUN ufw allow 8081/tcp

EXPOSE 8081

CMD ./Required_Entrypoint.sh
  
