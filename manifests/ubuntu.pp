# == Class: neo4j::ubuntu
#
# Everything you need to get Neo4j running on Ubuntu.  This first draft is meant to be self-contained for first
# time users, we'll see what we can do to make a module that can be user by the Puppet Forge community.
#
# === Parameters
#
# None.
#
# === Variables
# None.
#
# === Examples
#
#  class { neo4j::ubuntu }
#
# === Authors
#
# Author Name <julian.simpson@neotechnology.com>
#
# === Copyright
#
# Copyright 2012 Neo Technology Inc.
#
class neo4j::ubuntu {
  include linux
  include java

  exec {
    'apt-get update':
      command => '/usr/bin/apt-get update';

    'neotech signing key':
      command => '/usr/bin/wget -O - http://debian.neo4j.org/neotechnology.gpg.key | apt-key add -',
      before  => Exec['apt-get update'],
      unless  => '/usr/bin/apt-key list | grep -q neotechnology.com';
  }

  file {
    'neo4j apt config':
      path    => '/etc/apt/sources.list.d/neo4j.list',
      content => 'deb http://debian.neo4j.org/repo stable/',
      before  => Exec['apt-get update'];

    '/etc/neo4j':
      ensure => directory,
      group  => adm,
      mode   => '0755';

    'neo4j config file':
      path     => '/etc/neo4j/neo4j-server.properties',
      source   => 'puppet:///modules/neo4j/neo4j-server.properties',
      require  => File['/etc/neo4j'],
      before   => Package['neo4j'],
      owner    => neo4j,
      group    => adm;
  }

  package {
    'neo4j':
      ensure  => present,
      require => [Exec['apt-get update'], Class['neo4j::java']];
  }

  service {
    'neo4j-service':
      ensure  => running,
      enable  => true,
      require => [Package['neo4j'], Class['neo4j::linux']];

  }

}