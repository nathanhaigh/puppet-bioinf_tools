class bioinf_tools::bowtie2 ( $version  = '2.0.0-beta7', $toolname = "bowtie2" ) inherits bioinf_tools {
  # url to get tool from
  $url = "http://downloads.sourceforge.net/project/bowtie-bio/bowtie2/${version}/bowtie2-${version}-linux-x86_64.zip"
  
  #only need to run curl if
  get { "${toolname}-${version}-get":
    source => $url,
    target => "$bioinf_tools::staging_dir/bowtie2-${version}-linux-x86_64.zip",
  }
  exec { "${toolname}-${version}-unpack":
    command => "unzip bowtie2-${version}-linux-x86_64.zip",
    require => [ Package['unzip'], Get["${toolname}-${version}-get"] ],
    creates => "$bioinf_tools::staging_dir/bowtie2-2.0.0-beta7",
  }
  file { "$bioinf_tools::target_dir/$toolname":
    ensure => directory,
  }
  exec { "${toolname}-${version}-move":
    command => "mv $bioinf_tools::staging_dir/bowtie2-2.0.0-beta7 $bioinf_tools::target_dir/$toolname/${toolname}-${version}",
    creates => "$bioinf_tools::target_dir/$toolname/${toolname}-${version}",
    require => [ Exec["${toolname}-${version}-unpack"], File["$bioinf_tools::target_dir/$toolname"] ],
  }
  file { "$bioinf_tools::target_dir/$toolname/$toolname":
    ensure => link,
    target => "${toolname}-${version}",
    require => Exec["${toolname}-${version}-move"],
  }
  package { 'unzip':
    ensure => installed,
  }
  # need to add $tools::target_dir/$toolname/$toolname to $PATH
}