FROM ubuntu:noble AS base
WORKDIR /usr/local/bin
ENV DEBIAN_FRONTEND=noninteractive
RUN echo "resolvconf resolvconf/linkify-resolvconf boolean false" | debconf-set-selections
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y software-properties-common curl git build-essential && \
    apt-add-repository -y ppa:ansible/ansible && \
    apt-get update && \
    apt-get install -y snapd curl git ansible build-essential && \
    dpkg --configure -a && \
    apt-get install -y resolvconf && \
    apt-get clean autoclean && \
    apt-get autoremove --yes

FROM base AS custom
RUN apt-get update && apt-get install sudo -y
RUN apt-get install dialog apt-utils -y
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN adduser --disabled-password --gecos '' docker
RUN adduser docker sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER docker
WORKDIR /home/docker
RUN chmod -R 755 /home/docker

FROM custom
COPY . ./

CMD ["sh", "-c", "ansible-playbook main.yml --ask-vault-pass"]