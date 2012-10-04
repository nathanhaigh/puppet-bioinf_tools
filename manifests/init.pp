# Class: puppet_bioinf_tools
#
# This module manages puppet_bioinf_tools
#
# Parameters: none
#
# Actions:
#
# Requires: see Modulefile
#
# Sample Usage:
#
class puppet_bioinf_tools (
  $staging_dir = '/usr/local/src',
  $target_dir = '/usr/local/bioinf',
) {
  Exec {
    path => [
      '/usr/bin',
      '/bin',
    ],
    cwd => $staging_dir,
  }
  # TODO: these file resources do not recursively ensure ALL parent dirs are present,
  # i.e. the immediate parent MUST exist. 
  file { "$staging_dir":
    ensure => directory,
  }
  file { "$target_dir":
    ensure => directory,
  }

  # define a resource - these can be called multiple times unlike class
  # 'get' knows how to retrieve files given a $source and saves it to $target
  # can provide username, password, environment etc for those protocols that need them e.g. https, ftp
  # the file obtained from $source will be placed in $puppet_bioinf_tools::staging 
  define get (
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
        $command = "curl -L --create-dirs -o $puppet_bioinf_tools::staging_dir/$target $source"
      }
      /^https:\/\//: {
        if $username {
          $command = "curl -L --create-dirs -o $puppet_bioinf_tools::staging_dir/$target -u $username:$password $source"
        } elsif $certificate {
          $command = "curl -L --create-dirs -o $puppet_bioinf_tools::staging_dir/$target -E $certificate:$password $source"
        } else {
          $command = "curl -L --create-dirs -o $puppet_bioinf_tools::staging_dir/$target $source"
        }
      }
      /^ftp:\/\//: {
        if $username {
          $command = "curl --create-dirs -o $puppet_bioinf_tools::staging_dir/$target -u $username:$password $source"
        } else {
          $command = "curl --create-dirs -o $puppet_bioinf_tools::staging_dir/$target $source"
        }
      }
      /^git:\/\//: {
        $command = "git clone $source"
      }
      default: {
        fail("puppet_bioinf_tools::get: unsupported protocol ${source}.")
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
      creates => "$puppet_bioinf_tools::staging_dir/$target",
    }
  }
  
  # define a resource - these can be called multiple times unlike class
  # 'extract' knows how to extract archives given a $source
  # The $source is assumed to be in $puppet_bioinf_tools::staging and will be extracted there
  # If $cleanup is true, delete the source if extraction is successful
  define extract (
    $source,
    $creates,
    $cleanup = true,
  ) {
    # Build the command required to extract the archive based on the file extension
	  case $source {
	    /.tar$/: {
	      $command = "tar -xf $puppet_bioinf_tools::staging_dir/${source}"
	    }
	
	    /(.tgz|.tar.gz)$/: {
	      $command = "tar -xzf $puppet_bioinf_tools::staging_dir/${source}"
	    }
	    
	    /.tar.bz2$/: {
	      $command = "tar -xjf $puppet_bioinf_tools::staging_dir/${source}"
	    }
	
	    /.zip$/: {
	      $command = "unzip $puppet_bioinf_tools::staging_dir/${source}"
	    }
	    default: {
	      fail("puppet_bioinf_tools::::extract: unsupported file format ${source}.")
	    }
	  }
	  
	  # Determine if the command needs a package to be installed in order to run.
    # The default will be no such requirements
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
      creates => "$puppet_bioinf_tools::staging_dir/$creates",
    }
    
    # delete the $source if $cleanup is true and extraction was successful
    if ($cleanup) {
      file { "$puppet_bioinf_tools::staging_dir/${source}":
	      ensure  => absent,
	      require => Exec["extract-command"],
        backup  => false
	    }
    }
  }
}

