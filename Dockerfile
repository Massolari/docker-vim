FROM ubuntu:rolling
MAINTAINER Douglas Massolari <douglasmassolari@hotmail.com>

# Dependencies
RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y wget git php nodejs curl php-pear neovim pgformatter python3 python3-pip

# Yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt update && apt install yarn && \
        apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Plug.vim
RUN curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Neovim
RUN wget https://github.com/neovim/neovim/releases/download/nightly/nvim.appimage
RUN chmod +x nvim.appimage

# Linters
RUN pear install pear/PHP_CodeSniffer
RUN yarn global add eslint
RUN yarn global add typescript

# Vim configuration files
COPY ./.vimrc /root/
COPY ./.vimrc.bundles /root/
COPY ./.eslintrc.json /root/
COPY ./.phpcs.xml /root/
RUN mkdir /root/.config
RUN mkdir /root/.config/nvim
COPY ./init.vim /root/.config/nvim/

# Install plugins
RUN ./nvim.appimage --appimage-extract
RUN squashfs-root/AppRun +PlugInstall +qall

# Clean
RUN apt remove php-pear -y
RUN rm ./nvim.appimage

WORKDIR /mnt
ENTRYPOINT ["/squashfs-root/AppRun"]
