FROM archlinux:base-devel

MAINTAINER yasunori0418
LABEL description="Create a user in archlinux:base-devel. \
                   You can add packages specified in pkglist. \
                   And configure the user directory with the structure of the XDG Base Directory."

# Load package list file with variable.
ARG PKGLIST_FILE=./pkglist.txt

# You can specify a list of non-aur packages in text format.
# Adding package list.
COPY ${PKGLIST_FILE}   /etc/pacman.d/${PKGLIST_FILE}

# The pacman-key and pacman -Syu commands must be run for the initial time with archlinux images.
RUN pacman-key --init && \
    pacman-key --populate archlinux && \
    pacman -Syu --noconfirm && \
    pacman -S --needed --noconfirm - < /etc/pacman.d/${PKGLIST_FILE}

# Arguments for user making.
ARG UID=1000
ARG GID=1000
ARG USER_NAME=user
ARG GROUP_NAME=user
ARG PASSWD=user
ARG SHELL_NAME=bash
ARG SHELL=/usr/bin/${SHELL_NAME}

RUN groupadd -g ${GID} ${GROUP_NAME} && \
    useradd -m -s ${SHELL} -u ${UID} -g ${GID} -G ${GROUP_NAME} ${USER_NAME} && \
    echo ${USER_NAME}:${PASSWD} | chpasswd && \
    echo "${USER_NAME}    ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Change the user used from root to $USER_NAME.
USER ${USER_NAME}
WORKDIR /home/${USER_NAME}

# Change the value of the environment variable $SHELL to the created user shell.
ENV SHELL=${SHELL}

# Structuring XDG Base Directory in user directory.
RUN xdg-user-dirs-update
