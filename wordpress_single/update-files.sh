#!/bin/sh -x
cp -f /home/vagrant/share/fileserver.conf /etc/puppet/
cp -rf /home/vagrant/share/wordpress /etc/puppet/
cp -rf /home/vagrant/share/modules/* /etc/puppet/modules
puppet parser validate /etc/puppet/modules/wordpress/manifests/*.pp
cp -f /home/vagrant/share/manifests/* /etc/puppet/manifests
puppet parser validate /etc/puppet/manifests/*.pp
