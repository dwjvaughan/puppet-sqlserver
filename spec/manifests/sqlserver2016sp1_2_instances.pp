Reboot {
  timeout => 10,
}

class { '::sqlserver::v2016::iso':
  source => $::sqlserver2016_iso_url,
}

sqlserver::v2016::instance { 'SQL2016_1':
  install_type   => 'SP1',
  install_params => {
    sapwd => 'sdf347RT!',
  },
  tcp_port       => 1433,
}

sqlserver::v2016::instance { 'SQL2016_2':
  install_type   => 'SP1',
  install_params => {
    sapwd        => 'sdf347RT!',
    sqlcollation => 'Latin1_General_CS_AS_KS_WS',
  },
  tcp_port       => 1434,
}

# Test setting options with the first instance

sqlserver::options::clr_enabled { 'SQL2016_1: clr enabled':
  server  => 'localhost\SQL2016_1',
  require => Sqlserver::V2016::Instance['SQL2016_1'],
  value   => 1,
}
sqlserver::options::max_memory { 'SQL2016_1: Max Memory':
  server  => 'localhost\SQL2016_1',
  require => Sqlserver::V2016::Instance['SQL2016_1'],
  value   => 512,
}
sqlserver::options::xp_cmdshell { 'SQL2016_1: xp_cmdshell':
  server  => 'localhost\SQL2016_1',
  require => Sqlserver::V2016::Instance['SQL2016_1'],
  value   => 1,
}

sqlserver::database::readonly { 'SQL2016_1: Set model readonly':
  server        => 'localhost\SQL2016_1',
  database_name => 'model',
  require       => Sqlserver::V2016::Instance['SQL2016_1'],
}

# Test logins/roles
sqlserver::users::login_windows { 'SQL2016_1: Everyone login':
  server     => 'localhost\SQL2016_1',
  login_name => '\Everyone',
  require    => Sqlserver::V2016::Instance['SQL2016_1'],
}
->
sqlserver::users::login_role { 'SQL2016_1: Everyone is sysadmin':
  server     => 'localhost\SQL2016_1',
  login_name => '\Everyone',
  role_name  => 'sysadmin',
}
-> sqlserver::users::default_database { 'SQL2016_1: Everyone default database is tempdb':
  server                => 'localhost\SQL2016_1',
  login_name            => '\Everyone',
  default_database_name => 'tempdb',
}

$create_database_script = @(SCRIPT)
  use [master]
  GO
  CREATE DATABASE [test_database]
  GO
SCRIPT

file { 'C:/Windows/Temp/create_db.sql':
  content => $create_database_script,
}
->
sqlserver::sqlcmd::sqlscript { 'create test_database on SQL2016_1':
  server  => 'localhost\SQL2016_1',
  require => Sqlserver::V2016::Instance['SQL2016_1'],
  path    => 'C:/Windows/Temp/create_db.sql',
  unless  => "IF NOT EXISTS(SELECT * FROM sys.databases WHERE name = 'test_database') raiserror ('Database does not exist',1,1)",
}

# Test sql logins/roles
sqlserver::users::login_sql { 'SQL2016_1: test_user':
  server         => 'localhost\SQL2016_1',
  login_name     => 'test_user',
  login_password => 'Pa44w0rd!',
  require        => Sqlserver::V2016::Instance['SQL2016_1'],
}
-> sqlserver::users::login_role { 'SQL2016_1: test_user is sysadmin':
  server     => 'localhost\SQL2016_1',
  login_name => 'test_user',
  role_name  => 'sysadmin',
}
-> sqlserver::users::default_database { 'SQL2016_1: test_user default database is tempdb':
  server                => 'localhost\SQL2016_1',
  login_name            => 'test_user',
  default_database_name => 'tempdb'
}