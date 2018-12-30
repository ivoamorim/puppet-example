class wordpress::db (
  $root_password = 'password',
  $wordpress_db_name = 'wordpress',
  $wordpress_db_user = 'wordpress',
  $wordpress_db_password = 'wp_password',
) {
  $db_root_password = $root_password
  $db_name = $wordpress_db_name
  $db_user = $wordpress_db_user
  $db_password = $wordpress_db_password
  $db_host = $wordpress_db_host

  $mysqlserver = $::operatingsystem ? {
    CentOS   => mariadb-server,
    default  => mariadb-server,
  }

  $mysqlclient = $::operatingsystem ? {
    CentOS   => mariadb,
    default  => mariadb,
  }

  $mysqlservice = $::operatingsystem ? {
    CentOS   => mariadb,
    default  => mariadb,
  }

  package { [ $mysqlclient, $mysqlserver ]:
    ensure => latest,
  }

  ini_setting { '/etc/my.cnf':
    ensure  => present,
    path    => '/etc/my.cnf',
    section => 'mysqld',
    setting => 'character-set-server',
    value   => 'utf8',
    notify  => Service[$mysqlservice],
  }

  service { $mysqlservice:
    ensure      => running,
    enable      => true,
    hasrestart  => true,
    hasstatus   => true,
    require     => Package[ $mysqlserver, $mysqlclient ],
  }

  exec { 'flush_privileges_for_root_password':
    path        => '/usr/bin:/usr/sbin:/bin',
    command     => 'mysql -e "FLUSH PRIVILEGES;"',
    refreshonly => true,
    subscribe   => Exec['set_root_password'],
  }

  exec { 'set_root_password':
    path     => '/usr/bin:/usr/sbin:/bin',
    command  => "mysql -e \"UPDATE mysql.user SET Password=PASSWORD('${db_root_password}') WHERE User='root';\"",
    unless   => 'grep client /root/.my.cnf',
    require  => Service[$mysqlservice],
    notify   => Exec['set_/root/.my.cnf'],
  }

  exec { 'set_/root/.my.cnf':
    path        => '/usr/bin:/usr/sbin:/bin',
    command     => "echo \"[client]\nuser=root\npassword=${db_root_password}\" > /root/.my.cnf",
    require     => Exec['flush_privileges_for_root_password'],
    refreshonly => true;
  }

  exec { 'reload_privilege_tables':
    path        => '/usr/bin:/usr/sbin:/bin',
    command     => 'mysql --defaults-file=/root/.my.cnf -e "FLUSH PRIVILEGES;"',
    refreshonly => true,
    require  => [Service[$mysqlservice], Exec['set_/root/.my.cnf']],
  }

  exec { 'remove_anonymous_users':
    path     => '/usr/bin:/usr/sbin:/bin',
    command  => "mysql --defaults-file=/root/.my.cnf -e \"DELETE FROM mysql.user WHERE User='';\"",
    unless   => "mysql --defaults-file=/root/.my.cnf -BN -e \"SELECT EXISTS(SELECT * FROM mysql.user WHERE User='');\" | grep '^0$'",
    require  => [Service[$mysqlservice], Exec['set_/root/.my.cnf']],
  }

  exec { 'remove_remote_root':
    path     => '/usr/bin:/usr/sbin:/bin',
    command  => "mysql --defaults-file=/root/.my.cnf -e \"DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');\"",
    unless   => "mysql --defaults-file=/root/.my.cnf -BN -e \"SELECT EXISTS(SELECT * FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1'));\" | grep '^0$'",
    require  => [Service[$mysqlservice], Exec['set_/root/.my.cnf']],
  }

  exec { 'remove_test_database':
    path     => '/usr/bin:/usr/sbin:/bin',
    command  => "mysql --defaults-file=/root/.my.cnf -e \"DROP DATABASE test;\"",
    onlyif   => "mysql --defaults-file=/root/.my.cnf -BN -e \"SHOW DATABASES LIKE 'test';\" | grep test",
    require  => [Service[$mysqlservice], Exec['set_/root/.my.cnf']],
  }

  exec { 'create_wordpress_db':
    path     => '/usr/bin:/usr/sbin:/bin',
    command  => "mysql --defaults-file=/root/.my.cnf -e \"CREATE DATABASE ${db_name};\"",
    unless   => "mysql --defaults-file=/root/.my.cnf -BN -e \"SHOW DATABASES LIKE '${db_name}';\" | grep ${db_name}",
    require  => [Service[$mysqlservice], Exec['set_/root/.my.cnf']],
  }

  exec { 'grant_privileges':
    path     => '/usr/bin:/usr/sbin:/bin',
    command  => "mysql --defaults-file=/root/.my.cnf -e \"GRANT ALL PRIVILEGES ON \
                ${db_name}.* to ${db_user}@'%' \
                IDENTIFIED BY '${db_password}';\"",
    unless   => "mysql -u${db_user} -p${db_password} \
                -D${db_name} -hlocalhost",
    require  => [Service[$mysqlservice], Exec['set_/root/.my.cnf', 'create_wordpress_db']],
    notify   => Exec['reload_privilege_tables']
  }
}
