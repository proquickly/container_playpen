# Docker image to use with Vagrant
# Aims to be as similar to normal Vagrant usage as possible
# Adds Puppet, SSH daemon, Systemd
# Adapted from https://github.com/BashtonLtd/docker-vagrant-images/blob/master/ubuntu1404/Dockerfile

FROM python:3.11.2-slim-bullseye
ENV container docker
RUN apt-get update -y && apt-get dist-upgrade -y
RUN apt-get install -y --no-install-recommends ssh sudo libffi-dev systemd openssh-client

RUN useradd --create-home -s /bin/bash vagrant
RUN echo -n 'vagrant:vagrant' | chpasswd
RUN echo 'vagrant ALL = NOPASSWD: ALL' > /etc/sudoers.d/vagrant
RUN chmod 440 /etc/sudoers.d/vagrant
RUN mkdir -p /home/vagrant/.ssh
RUN chmod 700 /home/vagrant/.ssh
RUN echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ==" > /home/vagrant/.ssh/authorized_keys
RUN chmod 600 /home/vagrant/.ssh/authorized_keys
RUN chown -R vagrant:vagrant /home/vagrant/.ssh
RUN sed -i -e 's/Defaults.*requiretty/#&/' /etc/sudoers
RUN sed -i -e 's/\(UsePAM \)yes/\1 no/' /etc/ssh/sshd_config

RUN mkdir /var/run/sshd
EXPOSE 22
RUN /usr/sbin/sshd

RUN mkdir -p /home/vagrant/app \
  && mkdir -p /home/vagrant/app/docs \
  && mkdir -p /home/vagrant/data

ENV PATH="/home/vagrant/local/bin:${PATH}"
ENV COLORTERM=truecolor
ENV PYTHONDONTWRITEBYTECODE=1
EXPOSE 22

#WORKDIR /home/vagrant/app
RUN python -m pip install --user --upgrade pip
COPY --chown=vagrant requirements.txt .
COPY --chown=vagrant requirements.dev.txt .
RUN python -m pip install --user -r requirements.txt
COPY --chown=vagrant tests/ app/tests/
COPY --chown=vagrant src/ app/src/
#WORKDIR /vagrant
CMD ["/lib/systemd/systemd"]
