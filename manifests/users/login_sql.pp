# Create a SQL authentication login
define sqlserver::users::login_sql($server, $login_name, $login_password, $query_username = undef, $query_password = undef, $is_sql_2000 = false) {

  $sql_query = $is_sql_2000 ? {
    true  => "exec sp_addlogin '${login_name}', '${login_password}'",
    false => "CREATE LOGIN [${login_name}] WITH PASSWORD='${login_password}'",
  }

  ::sqlserver::sqlcmd::sqlquery { "${server} - Create ${login_name} login":
    server   => $server,
    username => $query_username,
    password => $query_password,
    query    => $sql_query,
    unless   => "IF NOT EXISTS(SELECT * from master.dbo.syslogins WHERE loginname = '${login_name}') raiserror ('Login does not exist',1,1)",
  }
}
