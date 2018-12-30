class wordpress::app (
  $wordpress_db_name = 'wordpress',
  $wordpress_db_user = 'wordpress',
  $wordpress_db_password = 'wp_password',
  $wordpress_db_host = 'localhost',
) {
  $db_name = $wordpress_db_name
  $db_user = $wordpress_db_user
  $db_password = $wordpress_db_password
  $db_host = $wordpress_db_host

  $apache = $::operatingsystem ? {
    CentOS   => httpd,
    default  => httpd,
  }

 $php = $::operatingsystem ? {
   CentOS   => php,
   default  => php,
 }

  $phpmb = $::operatingsystem ? {
    CentOS   => php-mbstring,
    default  => php-mbstring,
  }

  $phppear = $::operatingsystem ? {
    CentOS   => php-pear,
    default  => php-pear,
  }

  $wordpress = $::operatingsystem ? {
    CentOS   => wordpress,
    default  => wordpress,
  }

  package { [$apache, $php, $phpmb, $phppear, $wordpress]:
    ensure => latest,
  }

  file { '/etc/httpd/conf.d/welcome.conf':
    ensure => absent,
    notify => Service['httpd'],
  }

  file { '/etc/httpd/conf/httpd.conf':
      ensure => file,
      owner  => 'root',
      group  => 'root',
      mode   => 644,
      source => 'puppet://puppet.home/wordpress_app/httpd.conf',
      notify => Service['httpd'],
  }

  service { 'httpd':
      name   => 'httpd',
      ensure => running,
      enable     => true,
      hasrestart => true,
      hasstatus  => true,
      require => Package[$apache, $php, $phpmb, $phppear, $wordpress],
  }

  ini_setting { '/etc/php.ini':
    ensure  => present,
    path    => '/etc/php.ini',
    section => 'Date',
    setting => 'date.timezone',
    value   => 'Europe/London',
    notify  => Service['httpd'],
    require  => Package[$php, $phpmb, $phppear],
  }

  file { '/var/www/html/index.php':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => 644,
    source  => 'puppet://puppet.home/wordpress_app/index.php',
    require  => [Package[$php, $phpmb, $phppear]],
  }

  file {
    '/etc/wordpress/wp-config.php':
      ensure   => file,
      owner    => 'root',
      group    => 'root',
      mode     => 644,
      content  => template('wordpress/wp-config.php'),
      require  => Package[$apache, $php, $wordpress];
    '/etc/httpd/conf.d/wordpress.conf':
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => 644,
      source  => 'puppet://puppet.home/wordpress_app/wordpress.conf',
      require  => Package[$apache, $php, $wordpress],
      notify  => Service['httpd'];
  }

}
