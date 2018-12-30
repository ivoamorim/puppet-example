#!/bin/sh -x
rm -f /etc/puppet/fileserver.conf
cp -f /home/vagrant/share/fileserver.conf /etc/puppet/

rm -rf /etc/puppet/modules/*
cp -rf /home/vagrant/share/modules/* /etc/puppet/modules
puppet parser validate /etc/puppet/modules/wordpress/manifests/*.pp

rm -rf /etc/puppet/manifests/*
cp -f /home/vagrant/share/manifests/* /etc/puppet/manifests
puppet parser validate /etc/puppet/manifests/*.pp
