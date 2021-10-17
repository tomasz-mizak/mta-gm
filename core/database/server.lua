--[[

  database
  ~ server

]]

local mysql = {
  host = 'localhost',
  username = 'root',
  password = '',
  dbname = 'mta_db',
  timeout = 10000
}

local dbconn

function mysqlConnect() -- connecting function
  dbconn = Connection("mysql", "dbname="..mysql.dbname..";host="..mysql.host..";multi_statements=true", mysql.username, mysql.password)  
  if(dbconn) then
    return true
  else
    return false
  end
end

function mysqlQuery(sql, ...) -- quering
  if(sql) then
    local q = dbconn:query(sql,...)
    local r = q:poll(mysql.timeout)
    if(not(r)or r==nil) then q:free() return false end
    q:free()
    return r
  else
    outputDebug("mysqlQuery - bad syntax")
    return false
  end
end

function mysqlExec(sql,...) -- executing
  if(sql) then
    return dbconn:exec(sql, ...)
  else
    outputDebug("mysqlExec - bad syntax")
  end
end

addEventHandler('onResourceStart', resourceRoot, function() -- try to connect to database when resource start
  if(mysqlConnect()) then
    local s = string.format("Connected to %s, %s mysql database.", mysql.host, mysql.dbname)
    outputDebug(s)
    outputServerLog(s)
  else
    local s = string.format("Can't connect to %s, %s mysql database.", mysql.host, mysql.dbname)
    outputDebug(s)
    outputServerLog(s)
    Timer(stopResource, 5000, 1) -- stop resource if cannot connect to database
  end
end)