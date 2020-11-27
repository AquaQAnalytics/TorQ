//admin role that has full access to the system
.pm.addrole[`admin;"full system access"]
.pm.grantfunction[.pm.ALL;`admin;{1b}]
.pm.assignrole[`admin;`admin]

// systemuser, role used by each TorQ process, has access to all functions
// TorQ processes need to communicate with each other

.pm.addrole[`systemuser;"communicates between processes"]
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
.pm.grantfunction[`.sub.checksubscriptions;`systemuser;{1b}]
.pm.grantfunction[`.hb.checkheartbeat;`systemuser;{1b}]
.pm.grantfunction[`.hb.publishheartbeat;`systemuser;{1b}]
.pm.grantfunction[`.servers.retrydiscovery;`systemuser;{1b}]
.pm.grantfunction[`.servers.retry;`systemuser;{1b}]
.pm.grantfunction[`checktimeout;`systemuser;{1b}]
.pm.grantfunction[`datecheck;`systemuser;{1b}]
.pm.grantfunction[`send;`systemuser;{1b}]
.pm.grantfunction[`flushquerylogs;`systemuser;{1b}]
.pm.grantfunction[`.ps.subscribe;`systemuser;{1b}]
.pm.grantfunction[`.u.upd;`systemuser;{1b}]
.pm.grantfunction[`.proc.paramcheck;`systemuser;{1b}]
.pm.grantfunction[`.proc.getattributes;`systemuser;{1b}]
.pm.grantfunction[`postback;`systemuser;{1b}]
.pm.grantfunction[`killhandle;`systemuser;{1b}]
.pm.grantfunction[`$string(!:);`systemuser;{1b}]
.pm.grantfunction[`checkresulthandler;`systemuser;{1b}]

.pm.addgroup[`systemuser;"full access to data"]
.pm.grantaccess[`trade;`systemuser;`read]
.pm.grantaccess[`trade;`systemuser;`write]
.pm.grantaccess[`quote;`systemuser;`read]
.pm.grantaccess[`quote;`systemuser;`write]
.pm.grantaccess[`logmsg;`systemuser;`read]
.pm.grantaccess[`logmsg;`systemuser;`write]
.pm.grantaccess[`heartbeat;`systemuser;`read]
.pm.grantaccess[`heartbeat;`systemuser;`write]
.pm.grantaccess[`..register;`systemuser;`read]
.pm.grantaccess[`..register;`systemuser;`write]

// users for every TorQ process plus an admin user
.pm.adduser[`admin;`local;`md5;md5"admin"]
.pm.assignrole[`admin;`systemuser]
.pm.addtogroup[`admin;`systemuser]
.pm.adduser[`feed;`local;`md5;md5"pass"]
.pm.assignrole[`feed;`systemuser]
.pm.addtogroup[`feed;`systemuser]
.pm.adduser[`gateway;`local;`md5;md5"pass"]
.pm.assignrole[`gateway;`systemuser]
.pm.addtogroup[`gateway;`systemuser]
.pm.adduser[`hdb;`local;`md5;md5"pass"]
.pm.assignrole[`hdb;`systemuser]
.pm.addtogroup[`hdb;`systemuser]
.pm.adduser[`housekeeping;`local;`md5;md5"pass"]
.pm.assignrole[`housekeeping;`systemuser]
.pm.addtogroup[`housekeeping;`systemuser]
.pm.adduser[`kill;`local;`md5;md5"pass"]
.pm.assignrole[`kill;`systemuser]
.pm.addtogroup[`kill;`systemuser]
.pm.adduser[`monitor;`local;`md5;md5"pass"]
.pm.assignrole[`monitor;`systemuser]
.pm.addtogroup[`monitor;`systemuser]
.pm.adduser[`rdb;`local;`md5;md5"pass"]
.pm.assignrole[`rdb;`systemuser]
.pm.addtogroup[`rdb;`systemuser]
.pm.adduser[`reporter;`local;`md5;md5"pass"]
.pm.assignrole[`reporter;`systemuser]
.pm.addtogroup[`reporter;`systemuser]
.pm.adduser[`sort;`local;`md5;md5"pass"]
.pm.assignrole[`sort;`systemuser]
.pm.addtogroup[`sort;`systemuser]
.pm.adduser[`tickerplant;`local;`md5;md5"pass"]
.pm.assignrole[`tickerplant;`systemuser]
.pm.addtogroup[`tickerplant;`systemuser]
.pm.adduser[`wdb;`local;`md5;md5"pass"]
.pm.assignrole[`wdb;`systemuser]
.pm.addtogroup[`wdb;`systemuser]
.pm.adduser[`chainedtp;`local;`md5;md5"pass"]
.pm.assignrole[`chainedtp;`systemuser]
.pm.addtogroup[`chainedtp;`systemuser]
.pm.adduser[`sortworker;`local;`md5;md5"pass"]
.pm.assignrole[`sortworker;`systemuser]
.pm.addtogroup[`sortworker;`systemuser]
.pm.adduser[`discovery;`local;`md5;md5"pass"]
.pm.assignrole[`discovery;`systemuser]
.pm.addtogroup[`discovery;`systemuser]
.pm.adduser[`;`local;`md5;md5"pass"]
.pm.assignrole[`;`systemuser]
.pm.addtogroup[`;`systemuser]

//The gateway is made an administrator as it cannot properly permission without total access,
//the user used to login to the gateway will still be permissioned.

.pm.addrole[`administrator;"can do anything"]
.pm.grantfunction[.pm.ALL;`administrator;{1b}] / all functions, no argument validation
.pm.assignrole[`gateway;`administrator]
.pm.addgroup[`administrator;"can do anything"]
.pm.grantaccess[.pm.ALL;`administrator;`read] / all functions, no argument validation
.pm.addtogroup[`gateway;`administrator]
