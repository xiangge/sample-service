# tc-box building dockerfile
# See images.paas.redhat.com/exd-sp-rhel-wf/tc-box:latest
FROM --platform=linux/amd64 registry.fedoraproject.org/fedora:39

ARG GIT_URL=unknown
ARG GIT_COMMIT=unknown

LABEL description="Pipeline base image" \
      summary="Pipeline base image" \
      maintainer="Chuang Cao(CC)" \
      vendor="Red Hat, Inc." \
      distribution-scope="public" \
      vcs-type="git" \
      vcs-url=$GIT_URL \
      vcs-ref=$GIT_COMMIT

ARG USER=tc
ARG UID=10000
ARG HOME_DIR=/home/tc

RUN useradd -d ${HOME_DIR} -u ${UID} -g 0 -m -s /bin/bash ${USER} \
    && chmod -R g+rwx ${HOME_DIR} \
    # Make /etc/passwd writable for root group
    # so we can add dynamic user to the system in entrypoint script
    && chmod g+rw /etc/passwd \
    && dnf install -y \
        --setopt install_weak_deps=false \
        --nodocs \
        --disablerepo=* \
        --enablerepo=fedora,updates \
        git-core \
        python3 \
        python3-pip \
        python3-attrs \
        python3-click \
        python3-retrying \
        python3-requests \
        python3-requests-kerberos \
        python3-gssapi \
        python3-jira \
        python3-dateutil \
        python3-jinja2 \
        python3-graphviz \
        python-unversioned-command \
        krb5-devel \
        krb5-workstation \
        'dnf-command(config-manager)' \
        gcc python3-devel \
        krb5-devel \
        openldap-devel \
        shadow-utils \
        yamllint \
        krb5-workstation \
        ansible \
    && dnf clean all \
    && chmod og+r /etc/krb5.conf

ENV \
    REQUESTS_CA_BUNDLE=/etc/pki/tls/certs/ca-bundle.crt \
    HOME=${HOME_DIR} \
    LANG=en_US.UTF-8 \
    KRB5CCNAME=FILE:/tmp/ccache \
    PIP_DEFAULT_TIMEOUT=100 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1 \
    PYTHONFAULTHANDLER=1 \
    PYTHONUNBUFFERED=1

COPY requirements.txt /tmp/requirements.txt

RUN pip3 install --no-cache-dir -r /tmp/requirements.txt \
    && rm /tmp/requirements.txt

USER ${UID}

ENTRYPOINT ["bash"]