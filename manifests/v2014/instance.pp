# Install an configure a single SQL Server 2014 Instance.
#
# $install_type:
#   'RTM' (don't patch)
#   or
#   'Patch' (install the latest Service Pack/Patch/CU we are aware of.)
#
define sqlserver::v2014::instance(
  $instance_name  = $title,
  $install_type   = 'Patch',
  $install_params = {},
  $tcp_port       = 0
  ) {

  require ::sqlserver::v2014::iso

  Exec {
    path    => 'C:/Windows/System32',
    timeout => 1800,
  }

  sqlserver::common::install_sqlserver_instance { $instance_name:
    installer_path => $::sqlserver::v2014::iso::installer,
    install_params => $install_params,
  }

  if $install_type == 'Patch' {
    require ::sqlserver::v2014::sp2
    require ::sqlserver::v2014::kb3194714

    sqlserver::common::patch_sqlserver_instance { "${instance_name}:${::sqlserver::v2014::sp2::installer}":
      instance_name      => $instance_name,
      installer_path     => $::sqlserver::v2014::sp2::installer,
      applies_to_version => $::sqlserver::v2014::sp2::applies_to_version,
    }
    ->
    sqlserver::common::patch_sqlserver_instance { "${instance_name}:${::sqlserver::v2014::kb3194714::installer}":
      instance_name      => $instance_name,
      installer_path     => $::sqlserver::v2014::kb3194714::installer,
      applies_to_version => $::sqlserver::v2014::kb3194714::applies_to_version,
    }
  }

  if $tcp_port > 0 {
    sqlserver::common::tcp_port { $instance_name:
      tcp_port          => $tcp_port,
      sqlserver_version => 12,
    }
  }

}