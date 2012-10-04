# define a resource - these can be called multiple times unlike class
# 'get' knows how to retrieve files given a $source and saves it to $target
# can provide username, password, environment etc for those protocols that need them e.g. https, ftp
# the file obtained from $source will be placed in $bioinf_tools::staging 
define bioinf_tools::get (
  $source,
  $target,
  $username    = undef,
  $certificate = undef,
  $password    = undef,
) {
  # Build the command required to get the siource from where ever it is
  # TODO: make $target optional, and default to $staging_dir/basename($source)
  case $source {
    /^http:\/\//: {
      $command = "curl -L --create-dirs -o ${bioinf_tools::staging_dir}/$target $source"
    }
    /^https:\/\//: {
      if $username {
        $command = "curl -L --create-dirs -o ${bioinf_tools::staging_dir}/$target -u $username:$password $source"
      } elsif $certificate {
        $command = "curl -L --create-dirs -o ${bioinf_tools::staging_dir}/$target -E $certificate:$password $source"
      } else {
        $command = "curl -L --create-dirs -o ${bioinf_tools::staging_dir}/$target $source"
      }
    }
    /^ftp:\/\//: {
      if $username {
        $command = "curl --create-dirs -o ${bioinf_tools::staging_dir}/$target -u $username:$password $source"
      } else {
        $command = "curl --create-dirs -o ${bioinf_tools::staging_dir}/$target $source"
      }
    }
    /^git:\/\//: {
      $command = "git clone $source"
    }
    default: {
      fail("bioinf_tools::get: unsupported protocol ${source}.")
    }
  }

  # Determine if the command needs a package to be installed in order to run.
  # The default will be no such requirements
  case $command {
    /^curl/: {
      package { "curl":
        ensure => installed,
        before => Exec["$command"],
      }
    }
    /^wget/: {
      package { "wget":
        ensure => installed,
        before => Exec["$command"],
      }
    }
    /^git/: {
      package { "git":
        ensure => installed,
        before => Exec["$command"],
      }
    }
  }

  exec { $command:
    creates => "${bioinf_tools::staging_dir}/$target",
  }
}
