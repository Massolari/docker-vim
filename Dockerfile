FROM ubuntu:disco
MAINTAINER Douglas Massolari <douglasmassolari@hotmail.com>

# Dependencies
RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends \
    apt-transport-https \
    curl \
    git \
    gnupg2 \
    nodejs \
    openjdk-8-jre-headless \
    pgformatter \
    php \
    php-pear \
    php-tokenizer \
    php-xml \
    python3 \
    python3-pip \
    python3-setuptools \
    wget \
    xsel

# Yarn e Dart
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && sh -c 'wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -' \
    && sh -c 'wget -qO- https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list > /etc/apt/sources.list.d/dart_stable.list' \
    && apt update \
    && DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends yarn dart

# Plug.vim
RUN curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Ripgrep
RUN curl -LO https://github.com/BurntSushi/ripgrep/releases/download/11.0.2/ripgrep_11.0.2_amd64.deb \
    && dpkg -i ripgrep_11.0.2_amd64.deb

# Neovim
RUN curl -LO https://github.com/neovim/neovim/releases/download/stable/nvim.appimage \
    && chmod +x nvim.appimage \
    && ./nvim.appimage --appimage-extract \
    && pip3 install neovim

# PHP CodeSniffer
RUN pear install pear/PHP_CodeSniffer

# Typescript e Elm
RUN yarn global add typescript tslint elm elm-format @elm-tooling/elm-language-server

# Vim configuration files
COPY ./.phpcs.xml /root/
COPY ./init.sh /
RUN git clone https://github.com/massolari/vimrc-files \
    && ln -s $PWD/vimrc-files/.vimrc /root/ \
    && ln -s $PWD/vimrc-files/.vimrc.bundles /root/ \
    && mkdir /root/.config \
    && mkdir /root/.config/nvim \
    && chmod +x ./init.sh
COPY ./init.vim /root/.config/nvim/

# Clean
RUN apt remove php-pear gnupg2 -y \
    && rm ./nvim.appimage \
    && rm ./ripgrep_11.0.2_amd64.deb \
    && apt autoremove -y \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /root/workspace
ENV SHELL /bin/bash
ENV JAVA_HOME /usr/lib/jvm/java-1.8.0-openjdk-amd64
ENV ANDROID_HOME /root/android-sdk
ENV PATH /root/flutter/bin:${PATH}
ENTRYPOINT ["/init.sh"]
