#!/bin/bash

if [ "$(id -u)" != "0" ]; then
    echo "Please run this script as root"
    exit 1
fi

if ! hash git 2>/dev/null; then
    apt-get -y update
    apt-get -y install git
fi

if [ ! -d /etc/chef-devbox ] || [ ! -f /etc/chef-devbox/Berksfile ] ; then
    git clone https://github.com/aoepeople/chef-devbox.git /etc/chef-devbox || { echo >&2 "Cloning failed"; exit 1; }
else 
    cd /etc/chef-devbox && git pull
fi

if [ ! -f /opt/chefdk/bin/chef ] || [ "$(/opt/chefdk/bin/chef --version)" != "Chef Development Kit Version: 0.3.5" ] ; then
    echo
    echo "Installing ChefDK (includes Berkshelf)..."
    echo "-----------------------------------------"
    echo
    wget https://opscode-omnibus-packages.s3.amazonaws.com/ubuntu/12.04/x86_64/chefdk_0.3.5-1_amd64.deb -O /tmp/chefdk.deb || { echo >&2 "Downloading ChefDK package failed"; exit 1; }
    dpkg -i /tmp/chefdk.deb || { echo >&2 "Installing ChefDK failed"; exit 1; }
fi

echo
echo "Fetching dependencies via Berkshelf..."
echo "--------------------------------------"
echo
if [ -f /etc/chef-devbox/Berksfile.lock ] ; then rm /etc/chef-devbox/Berksfile.lock; fi
if [ -d ~/.berkshelf ] ; then rm -rf ~/.berkshelf; fi
if [ -d /etc/chef-devbox/cookbooks ] ; then rm -rf /etc/chef-devbox/cookbooks; fi
cd /etc/chef-devbox && berks vendor /etc/chef-devbox/cookbooks || { echo >&2 "Installing berkshelf depenencies failed"; exit 1; }

#echo
#echo "Running Chef..."
#echo "---------------"
#echo
#cd /etc/chef-devbox && chef-solo -c solo.rb -j solo.json || { echo >&2 "Chef provsioning failed"; exit 1; }