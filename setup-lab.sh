#!/bin/bash

# Notes:
# Don't forget to setup your desktop manually before running this script
# as this script will save a state which will be preserved upon logins.

# Can be x86_64 or ix86
ARCH=`uname -m`

BACKGROUND_URL="http://ozancaglayan.com/files/SpaceflareGSU2.jpg"
BACKGROUND_FILE="/opt/gsu/GSUWallpaper.jpg"

if [ "x$UID" != "x0" ]; then
    # Do user-related stuff and exit
    if [ ! -f $BACKGROUND_FILE ]; then
        echo "You should first run this script as root and then as user."
        exit 1
    fi

    # Set wallpaper
    gsettings set org.gnome.desktop.background picture-uri $BACKGROUND_FILE

    # Disable automatic updates
    gsettings set org.gnome.settings-daemon.plugins.updates frequency-get-updates 0

    # Set history opts for bash
    echo -e '
shopt -s histappend
PROMPT_COMMAND="history -a;history -n;$PROMPT_COMMAND"
' >> ~/.bashrc

    echo -e '
set autoindent
set et
set ts=4 sw=4
set copyindent
set smartindent
set preserveindent
set number
set statusline=%F%m%r%h%w\ [FORMAT=%{&ff}]\ [TYPE=%Y]\ [ASCII=\%03.3b]\ [HEX=\%02.2B]\ [POS=%04l,%04v][%p%%]\ [LEN=%L]
' > ~/.vimrc

    # Setup GIT repos to reset configuration at each login
    FOLDERS=".local .config .mozilla"
    for f in $FOLDERS; do
        git init "~/$f"
        git --git-dir="~/$f" commit -a -m "Initial commit"
    done

    exit 0
fi

EDITORS="geany geany-plugins* gedit gedit-plugins gedit-code-assistance vim-enhanced vim-common"
OFFICE="libreoffice gimp inkscape lyx"
PYTHON="ipython bpython python-matplotlib scipy numpy PyQt4 python-kiwi pyserial python-twitter pygame pyexiv2 python-nltk "
PYTHON+="python-scikit-learn opencv-python python-biopython pylint python-pep8"
OCTAVE="octave qtoctave octave-*"
ELECTRONICS="gnusim8085 gsim85 arduino"
UTIL="unrar ltrace strace htop sox vlc dia graphviz"
DEV="gdb git valgrind valkyrie ElectricFence gcc man-pages nemiver openmpi wireshark SDL-devel clang clang-analyzer"
OTHER="opencv opencv-devel-docs R gearbox player stage texlive"
ECLIPSE="eclipse-cdt eclipse-egit eclipse-jdt eclipse-linuxtools eclipse-manpage eclipse-pydev eclipse-valgrind"

yum install "@C Development Tools and Libraries" "@Development Libraries" "@Development Tools" "@Engineering and Scientific" \
            $EDITORS $OFFICE $PYTHON $OCTAVE $ELECTRONICS $UTIL $DEV $OTHER $ECLIPSE

# Package removals
PACKAGES_TO_REMOVE="abrt*"
yum remove $PACKAGES_TO_REMOVE

# Disable services
SERVICES_TO_DISABLE="sendmail.service sm-client.service auditd.service accounts-daemon.service dm-event.service firewalld.service iscsi.service iscsid.service lvm2-monitor.service"
systemctl disable $SERVICES_TO_DISABLE

# Install flash plugin
FLASH_ARCH="i386"
if [[ "$ARCH" == "x86_64" ]]; then
    FLASH_ARCH="x86_64"
fi
yum install "http://linuxdownload.adobe.com/adobe-release/adobe-release-${FLASH_ARCH}-1.0-1.noarch.rpm" -y
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-adobe-linux
yum install flash-plugin -y

# VIM alias
echo -e '

# Alias vi to vim
alias vi="vim"
' >> /etc/bashrc

mkdir /opt/gsu &> /dev/null

# Fetch wallpaper
wget $BACKGROUND_URL -O $BACKGROUND_FILE

# OpenMPI scripts
echo -e '
#!/bin/bash

LIBDIR="lib"
ARCH=`uname -m`
if [[ "$ARCH" == "x86_64" ]]; then
    LIBDIR="lib64"
fi

exec /usr/$LIBDIR/openmpi/bin/mpicc $@
' > /usr/bin/mpicc

echo -e '
#!/bin/bash

LIBDIR="lib"
ARCH=`uname -m`
if [[ "$ARCH" == "x86_64" ]]; then
    LIBDIR="lib64"
fi

export OMPI_MCA_btl="^openib"
exec /usr/$LIBDIR/openmpi/bin/mpirun $@
' > /usr/bin/mpirun

chmod +x /usr/bin/{mpirun,mpicc}

# Install processing
PROCESSING_VER="2.1"
PROCESSING_ARCH="32"
if [[ "$ARCH" == "x86_64" ]]; then
    PROCESSING_ARCH="64"
fi
wget "http://download.processing.org/processing-${PROCESSING_VER}-linux${PROCESSING_ARCH}.tgz" -O /tmp/processing.tgz
cd /opt/
tar xvf /tmp/processing.tgz
rm -rf /tmp/processing.tgz
ln -s /opt/processing-*/processing /usr/bin/processing

# Fix permissions
chmod -R 664 /opt/gsu/*
