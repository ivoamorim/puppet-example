class { 'wordpress':
  wordpress_db_name     => 'wptest',
  wordpress_db_user     => 'wpuser',
  wordpress_db_password => 'wppassword',
  wordpress_db_host     => 'localhost',
}
