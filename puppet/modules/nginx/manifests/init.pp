# vagrant/puppet/modules/nginx/manifests/init.pp
class nginx {

  # Symlink /var/www/app on our guest with 
  # host /path/to/vagrant/app on our system
  file { '/var/www/app':
    ensure  => 'link',
    target  => '/vagrant/app',
  }

  # Install the nginx package. This relies on apt-get update
  package { 'nginx':
    ensure => 'present',
    require => Exec['apt-get update'],
  }

  # Make sure that the nginx service is running
  service { 'nginx':
    ensure => running,
    require => Package['nginx'],
  }

  # Add a vhost template
  file { 'vagrant-nginx':
    path => '/etc/nginx/sites-available/csproject',
    ensure => file,
    require => Package['nginx'],
      source => 'puppet:///modules/nginx/csproject',
  }

  # Disable the default nginx vhost
  file { 'default-nginx-disable':
    path => '/etc/nginx/sites-enabled/default',
    ensure => absent,
    require => Package['nginx'],
  }

  # Symlink our vhost in sites-enabled to enable it
  file { 'vagrant-nginx-enable':
    path => '/etc/nginx/sites-enabled/csproject',
    target => '/etc/nginx/sites-available/csproject',
    ensure => link,
    notify => Service['nginx'],
    require => [
      File['vagrant-nginx'],
      File['default-nginx-disable'],
    ],
  }
}
