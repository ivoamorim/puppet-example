rm /var/log/puppet/agent.log
systemctl restart puppet
sleep 3
tail -f /var/log/puppet/agent.log
