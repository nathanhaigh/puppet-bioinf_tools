# define a resource - these can be called multiple times unlike class
# 'extract' knows how to extract archives given a $source
# The $source is assumed to be in $bioinf_tools::staging and will be extracted there
# If $cleanup is true, delete the source if extraction is successful
define bioinf_tools::extract (
  $source,
  $creates,
  $cleanup = true,
) {
  # Build the command required to extract the archive based on the file extension
  case $source {
    /.tar$/: {
      $command = "tar -xf ${bioinf_tools::staging_dir}/${source}"
    }

    /(.tgz|.tar.gz)$/: {
      $command = "tar -xzf ${bioinf_tools::staging_dir}/${source}"
    }

    /.tar.bz2$/: {
      $command = "tar -xjf ${bioinf_tools::staging_dir}/${source}"
    }

    /.zip$/: {
      $command = "unzip ${bioinf_tools::staging_dir}/${source}"
    }
    default: {
      fail("bioinf_tools::::extract: unsupported file format ${source}.")
    }
  }

  # Determine if the command needs a package to be installed in order to run.
  # The default will be no such requirements.
  case $command {
    /^tar/: {
      package { "tar":
        ensure => installed,
        before => Exec["extract-command"],
      }
    }
    /^unzip/: {
      package { "unzip":
        ensure => installed,
        before => Exec["extract-command"],
      }
    }
  }

  exec { "extract-command":
    command => $command,
    creates => "${bioinf_tools::staging_dir}/$creates",
    cwd     => "${bioinf_tools::staging_dir}",
  }

  # delete the $source if $cleanup is true and extraction was successful
  if ($cleanup) {
    file { "${bioinf_tools::staging_dir}/${source}":
      ensure  => absent,
      require => Exec["extract-command"],
      backup  => false
    }
  }
}
