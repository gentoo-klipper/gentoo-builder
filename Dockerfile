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
    emerge -vq dev-vcs/git && \
    emaint sync -r gh-binhost && \
    emerge -vq app-portage/gh-binhost && \
	emerge -vqe dev-vcs/git app-portage/gh-binhost && \
    emerge -vq eix vim crossdev merge-usr dev-python/pyelftools dev-lang/swig sys-apps/dtc acct-group/users acct-group/nullmail acct-user/nullmail acct-group/cron acct-user/cron dev-embedded/u-boot-tools sys-fs/genext2fs sys-apps/dtc app-text/xmlto dev-util/desktop-file-utils x11-misc/shared-mime-info app-emulation/qemu && \
    crossdev --target armv7a-hardfloat-linux-gnueabi && \
	crossdev --lenv 'USE="nano -nls -threads -unicode" EXTRA_ECONF="--enable-newlib-hw-fp"' --genv 'USE="cxx -nls -nptl -pch -pie -ssp" EXTRA_ECONF="--with-multilib-list=rmprofile --disable-decimal-float --disable-libffi --disable-libgomp --disable-libmudflap --disable-libquadmath --disable-shared --disable-threads --disable-tls"' -s4 --ex-gdb -t arm-none-eabi && \
    eix-update
