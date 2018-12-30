yum -y install https://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm
sed -i -e "s/enabled=1/enabled=0/g" /etc/yum.repos.d/puppetlabs.repo
yum --enablerepo=puppetlabs-products,puppetlabs-deps -y install puppet-server
vi /etc/puppet/puppet.conf
#dns_alt_names = ${puppet_server}
puppet master --verbose --no-daemonize
puppet cert list
puppet cert --allow-dns-alt-names sign ${puppet_client}
puppet module install puppetlabs-inifile
