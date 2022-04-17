FROM ubuntu:impish
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

# Copy local code to the container image.
COPY . ./

CMD ["sh", "-c", "ansible-playbook main.yml"]
