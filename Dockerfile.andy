FROM python:3.10.6-slim-buster
RUN apt-get update && apt-get install -y zsh
SHELL ["/bin/zsh", "-c", "-o", "pipefail"]
RUN python -m pip install --upgrade pip
RUN python -m venv /opt/dev \
    && /opt/dev/bin/python3 -m pip install --upgrade pip \
    && chmod +x /opt/dev/bin/activate

RUN python -m venv /opt/prod \
    && /opt/prod/bin/python -m pip install --upgrade pip \
    && chmod +x /opt/prod/bin/activate

RUN if ! getent passwd app; then groupadd -g 1000 app && useradd -u 1000 -g 1000 -d /home/app -m -s /bin/zsh app; fi \
    && echo app:app | chpasswd \
    && echo 'app ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
    && mkdir -p /etc/sudoers.d \
    && echo 'app ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers.d/app \
    && chmod 0440 /etc/sudoers.d/app \
	&& apt-get autoremove \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/* \
    && chown -R app /opt/dev \
    && chown -R app /opt/prod

USER app
WORKDIR /home/app
RUN touch /home/app/.zshrc \
    && echo 'export PATH=/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin' >> /home/app/.zshrc \
    && echo 'PS1="$ "' >> /home/app/.zshrc \
    && echo 'alias dev="deactivate 2> /dev/null ; . /opt/dev/bin/activate"' >> /home/app/.zshrc \
    && echo 'alias prod="deactivate 2> /dev/null ; . /opt/prod/bin/activate"' >> /home/app/.zshrc  \
    && mkdir -p /home/app/app \
    && mkdir -p /home/app/app/tests \
    && mkdir -p /home/app/app/docs \
    && mkdir -p /home/app/data

CMD python
