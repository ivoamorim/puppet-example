if versioncmp($::puppetversion,'3.6.1') >= 0 {

  $allow_virtual_packages = hiera('allow_virtual_packages',false)

  Package {
    allow_virtual => $allow_virtual_packages,
  }
}

$db_host = 'db'
$db_name = 'wp'
$db_user = 'wptest'
$db_password = 'wppassword'

node 'db.home' {
  class { 'wordpress::db':
    root_password         => 'root_password',
    wordpress_db_name     => $db_name,
    wordpress_db_user     => $db_user,
    wordpress_db_password => $db_password,
  }
}

node 'web.home' {
  class { 'wordpress::app':
    wordpress_db_name     => $db_name,
    wordpress_db_user     => $db_user,
    wordpress_db_password => $db_password,
    wordpress_db_host     => $db_host,
  }
}

node default {
}
