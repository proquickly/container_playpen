FROM python:3.11.2-slim-bullseye
ENV container docker
RUN apt-get update -y \
  && apt-get install -y --no-install-recommends ssh sudo libffi-dev systemd openssh-client

RUN useradd --create-home -s /bin/bash vagrant \
  && echo -n 'vagrant:vagrant' | chpasswd \
  && echo 'vagrant ALL = NOPASSWD: ALL' > /etc/sudoers.d/vagrant \
  && chmod 440 /etc/sudoers.d/vagrant \
  && mkdir -p /home/vagrant/.ssh \
  && chmod 700 /home/vagrant/.ssh \
  && echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ==" > /home/vagrant/.ssh/authorized_keys \
  && chmod 600 /home/vagrant/.ssh/authorized_keys \
  && chown -R vagrant:vagrant /home/vagrant/.ssh \
  && sed -i -e 's/Defaults.*requiretty/#&/' /etc/sudoers \
  && sed -i -e 's/\(UsePAM \)yes/\1 no/' /etc/ssh/sshd_config

RUN mkdir /var/run/sshd
EXPOSE 22
RUN /usr/sbin/sshd

RUN mkdir -p /home/vagrant/app \
  && mkdir -p /home/vagrant/app/docs \
  && mkdir -p /home/vagrant/data

ENV PATH="/home/vagrant/local/bin:${PATH}"
ENV COLORTERM=truecolor
ENV PYTHONDONTWRITEBYTECODE=1

RUN python -m pip install --user --upgrade pip
COPY --chown=vagrant requirements.txt /home/vagrant/app/
COPY --chown=vagrant requirements.dev.txt /home/vagrant/app/
RUN python -m pip install --user -r /home/vagrant/app/requirements.dev.txt \
  && python -m pip install --user -r /home/vagrant/app/requirements.txt
COPY --chown=vagrant tests/ app/tests/
COPY --chown=vagrant src/ app/src/
CMD ["/lib/systemd/systemd"]
