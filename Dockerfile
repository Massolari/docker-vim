FROM ubuntu:disco
MAINTAINER Douglas Massolari <douglasmassolari@hotmail.com>

# Dependencies
RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y wget git php php-xml php-tokenizer nodejs curl php-pear neovim pgformatter python3 python3-pip dos2unix libxml2-utils

# Yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt update && apt install yarn && \
        apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Plug.vim
RUN curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Ripgrep
RUN curl -LO https://github.com/BurntSushi/ripgrep/releases/download/11.0.2/ripgrep_11.0.2_amd64.deb
RUN dpkg -i ripgrep_11.0.2_amd64.deb

# Neovim
RUN wget https://github.com/neovim/neovim/releases/download/stable/nvim.appimage
RUN chmod +x nvim.appimage

# PHP CodeSniffer
RUN pear install pear/PHP_CodeSniffer

# Typescript e Elm
RUN yarn global add typescript tslint elm elm-format @elm-tooling/elm-language-server

# Vim configuration files
RUN git clone https://github.com/massolari/vimrc-files
RUN ln -s $PWD/vimrc-files/.vimrc /root/
RUN ln -s $PWD/vimrc-files/.vimrc.bundles /root/
COPY ./.phpcs.xml /root/
COPY ./init.sh /
RUN chmod +x ./init.sh
RUN mkdir /root/.config
RUN mkdir /root/.config/nvim
COPY ./init.vim /root/.config/nvim/

# Extract neovim
RUN ./nvim.appimage --appimage-extract

# Clean
RUN apt remove php-pear -y
RUN rm ./nvim.appimage
RUN apt autoremove -y
RUN rm ripgrep_11.0.2_amd64.deb

WORKDIR /root/workspace
ENV SHELL /bin/bash
ENTRYPOINT ["/init.sh"]
