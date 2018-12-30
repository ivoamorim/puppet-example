class wordpress (
  $wordpress_db_name = 'wordpress',
  $wordpress_db_user = 'wordpress',
  $wordpress_db_password = 'wp_password',
  $wordpress_db_host = 'localhost'
) {
  $db_name = $wordpress_db_name
  $db_user = $wordpress_db_user
  $db_password = $wordpress_db_password
  $db_host = $wordpress_db_host

  $db_root_password = 'password'

  include wordpress::db
  include wordpress::app
}
