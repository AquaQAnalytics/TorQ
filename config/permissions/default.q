
.pm.addrole[`systemuser;"communicates between processes]
.pm.grantfunction[`exit;`systemuser;{1b}]
.pm.grantfunction[`reload;`systemuser;{1b}]
.pm.grantfunction[`..register;`systemuser;{1b}]
.pm.grantfunction[`getservices;`systemuser;{1b}]
.pm.grantfunction[`.servers.getdetails;`systemuser;{1b}]
.pm.grantfunction[`.servers.autodiscovery;`systemuser;{1b}]
.pm.grantfunction[`.servers.procupdate;`systemuser;{1b}]
.pm.grantfunction[`.gw.addservererror;`systemuser;{1b}]
.pm.grantfunction[`.gw.addserverresult;`systemuser;{1b}]
.pm.grantfunction[`.u.end;`systemuser;{1b}]
.pm.grantfunction[`.getservices;`systemuser;{1b}]
.pm.grantfunction[`upd;`systemuser;{1b}]

.pm.addgroup[`systemuser;"full access to data"]
.pm.grantaccess[`trade;`systemuser;`read]
.pm.grantaccess[`trade;`systemuser;`write]
.pm.grantaccess[`quote;`systemuser;`read]
.pm.grantaccess[`quote;`systemuser;`write]
.pm.grantaccess[`logmsg;`systemuser;`read]
.pm.grantaccess[`logmsg;`systemuser;`write]
.pm.grantaccess[`heartbeat;`systemuser;`read]
.pm.grantaccess[`heartbeat;`systemuser;`write]

