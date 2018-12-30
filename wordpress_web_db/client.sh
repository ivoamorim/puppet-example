yum -y install https://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm
sed -i -e "s/enabled=1/enabled=0/g" /etc/yum.repos.d/puppetlabs.repo
yum --enablerepo=puppetlabs-products,puppetlabs-deps -y install puppet
vi /etc/puppet/puppet.conf
#server = ${puppet_server}
puppet agent --test --ca_server=${puppet_server}
echo 'PUPPET_EXTRA_OPTS="--logdest /var/log/puppet/agent.log"' > /etc/sysconfig/puppet
