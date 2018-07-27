FROM massolari/vim-pure
MAINTAINER Douglas Massolari <douglasmassolari@hotmail.com>
RUN apk add --no-cache --update python python2-dev git curl ctags bash ncurses-terminfo musl-dev libxml2-utils nodejs
COPY ./.vimrc /root/
COPY ./.vimrc.local /root/
COPY ./.vimrc.local.bundles /root/
COPY ./plug.vim /root/.vim/autoload/
RUN vim +PlugInstall +qall
WORKDIR /mnt
ENTRYPOINT ["/usr/local/bin/vim", "-c", "colorscheme molokai"]
CMD ["."]
