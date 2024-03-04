#TODO: use nightly versions

ARG PORTAGE_VERSION=latest
ARG STAGE3_VERSION=amd64-openrc

FROM gentoo/portage:${PORTAGE_VERSION} as portage
FROM gentoo/stage3:${STAGE3_VERSION}

COPY --from=portage /var/db/repos/gentoo /var/db/repos/gentoo

ADD portage /etc/portage

RUN --mount=type=secret,id=GITHUB_TOKEN \
    export GITHUB_TOKEN=$(cat /run/secrets/GITHUB_TOKEN) && \
    rm -f /etc/portage/binrepos.conf/gentoobinhost.conf && \
    mkdir -p /var/db/repos/crossdev/{profiles,metadata} && \
    echo 'crossdev' > /var/db/repos/crossdev/profiles/repo_name && \
    echo 'masters = gentoo' > /var/db/repos/crossdev/metadata/layout.conf && \
    chown -R portage:portage /var/db/repos/crossdev && \
    emerge -v dev-vcs/git && \
    emaint sync -r gh-binhost && \
    emerge -v app-portage/gh-binhost && \
    emerge -v eix vim crossdev merge-usr && \
    crossdev --target armv7a-hardfloat-linux-gnueabi && \
    eix-update
