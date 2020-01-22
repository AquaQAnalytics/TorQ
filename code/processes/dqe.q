\d .dqe

configcsv:@[value;`.dqe.configcsv;first .proc.getconfigfile["dqeconfig.csv"]];
dqedbdir:@[value;`dqedbdir;`:dqedb];
detailcsv:@[value;`.dqe.detailcsv;first .proc.getconfigfile["dqedetail.csv"]];
gmttime:@[value;`gmttime;1b];
partitiontype:@[value;`partitiontype;`date];
getpartition:@[value;`getpartition;
	{{@[value;`.dqe.currentpartition;
		(`date^partitiontype)$(.z.D,.z.d)gmttime]}}];                                                   /-function to determine the partition value
detailcsv:@[value;`.dqe.detailcsv;first .proc.getconfigfile["dqedetail.csv"]];

testing:@[value;`.dqe.testing;0b];                                                                             /- testing varible for unit tests

init:{
  .lg.o[`init;"searching for servers"];
  .servers.startup[];                                                                                          /- Open connection to discovery
  .api.add .'value each .dqe.readdqeconfig[.dqe.detailcsv;"SB***"];                                            /- add dqe functions to .api.detail
  }

configtable:([] action:`$(); params:(); proctype:`$(); procname:`$(); mode:`$(); starttime:`timespan$(); endtime:`timespan$(); period:`timespan$())

readdqeconfig:{[file;types]
  .lg.o["reading dqe config from ",string file:hsym file];                                                     /- notify user about reading in config csv
  c:.[0:;((types;enlist",");file);{.lg.e["failed to load dqe configuration file: ",x]}]                        /- read in csv, trap error
 }

gethandles:{exec procname,proctype,w from .servers.SERVERS where (procname in x) | (proctype in x)};

fillprocname:{[rs;h]                                                                                           /- fill procname for results table
  val:rs where not rs in raze a:h`proctype`procname;
  (flip a),val,'`
  }

dupchk:{[runtype;idnum;proc]                                                                                   /- checks for unfinished runs that match the new run
  if[`=proc;:()];
  if[count select from .dqe.results where id=idnum,procschk=proc,chkstatus=`started;
    .dqe.failchk[runtype;idnum;"error:fail to complete before next run";proc]];
  }

initstatusupd:{[runtype;idnum;funct;vars;rs]                                                                   /- set initial values in results table
  .lg.o[`initstatus;"setting up initial record(s) for id ",(string idnum)];
  .dqe.dupchk[runtype;idnum]'[rs];                                                                             /- calls dupchk function to check if last runs chkstatus is still started
  `.dqe.results insert (idnum;funct;`$"," sv string raze (),vars;rs[0];rs[1];.z.p;0Np;0b;"";`started;runtype);
  }

failchk:{[runtype;idnum;error;proc]                                                                            /- general fail function, used to fail a check with inputted error message
  c:count select from .dqe.results where id=idnum, procschk=proc,chkstatus=`started;
  if[c;.lg.o[`failerr;raze "run check id ",(string idnum)," update in results table with a fail, with ",(string error)]];
  `.dqe.results set update chkstatus:`failed,output:0b,descp:c#enlist error,chkruntype:runtype from .dqe.results where id=idnum, procschk=proc,chkstatus=`started;
  }

nullchk:{[t;colslist;thres]                                                                                     /- function to check percentage of nulls in each column from colslist of a table t
  d:({sum$[0h=type x;0=count@'x;null x]}each flip tt)*100%count tt:((),colslist)#t;                             /- dictionary of nulls percentages for each column
  res:([] colsnames:key d; nullspercentage:value d);
  update thresholdfail:nullspercentage>thres from res                                                           /- compare each column's nulls percentage with threshold thres
  }

rangechk:{t;colslist;tlower;tupper;thres]                                                                       /- check that values are within the range defined by tlower and tupper tables
  colslist:((),colslist) except exec c from meta t where t in "csSC ";                                          /- exclude columns that do not have pre-defined limits
  tupper:((),colslist)#tupper;
  tlower:((),colslist)#tlower;
  d:(sum (tt within (tlower;tupper))*100%count tt:((),colslist)#t;                                              /- dictionary with results by columns
  res:([] colsnames:key d; inrangepercentage:value d);
  update thresholdfail:inrangepercentage<thres from res                                                         /- check if within range percentage is higher than threshold
  }
postback:{[runtype;idnum;proc;result]                                                                           /- function that updates the results table with the check result
  $["e"=first result;                                                                                           /- checks if error returned from server side
    .dqe.failchk[runtype;idnum;result;proc];
    `.dqe.results set update endtime:.z.p,output:first result,descp:enlist last result,chkstatus:`complete,chkruntype:runtype from .dqe.results where id=idnum,procschk=proc,chkstatus=`started];
  }

getresult:{[runtype;funct;vars;idnum;proc;hand]
  .lg.o[`getresults;raze"send function over to prcess: ",string proc];
  .async.postback[hand;funct,vars;.dqe.postback[runtype;idnum;proc]];                                           /- send function with variables down handle
  }

runcheck:{[runtype;idnum;fn;vars;rs]                                                                            /- function used to send other function to test processes
  fncheck:` vs fn;
  if[not fncheck[2] in key value .Q.dd[`;fncheck 1];                                                            /- run check to make sure passed in function exists
    .lg.e[`runcheck;"Function ",(string fn)," doesn't exist"];
    :()];

  rs:(),rs;                                                                                                     /- set rs to a list
  h:.dqe.gethandles[rs];                                                                                        /- check if processes exist and are valid

  r:.dqe.fillprocname[rs;h];
  .dqe.initstatusupd[runtype;idnum;fn;vars]'[r];
  
  .dqe.failchk[runtype;idnum;"error:can't connect to process";`];
  procsdown:(h`procname) where 0N = h`w;                                                                        /- checks if any procs didn't get handles
  if[count procsdown;.dqe.failchk[runtype;idnum;"error:process is down or has lost its handle"]'[procsdown]];

  if[0=count h;.lg.e[`handle;"cannot open handle to any given processes"];:()];                                 /- check if any handles exist, if not exit function
  ans:.dqe.getresult[runtype;value fn;(),vars;idnum]'[h[`procname];h[`w]]
  }

results:([]id:`long$();funct:`$();vars:`$();procs:`$();procschk:`$();starttime:`timestamp$();endtime:`timestamp$();output:`boolean$();descp:();chkstatus:`$();chkruntype:`$());

loadtimer:{[DICT]
  DICT[`params]: value DICT[`params];                                                                           /- Accounting for potential multiple parameters
  functiontorun:(`.dqe.runcheck;`scheduled;DICT`checkid;.Q.dd[`.dqe;DICT`action];DICT`params;DICT`procname);           /- function that will be used in timer
  $[DICT[`mode]=`repeat;                                                                                        /- Determine whether the check should be repeated
    .timer.repeat[DICT`starttime;DICT`endtime;DICT`period;functiontorun;"Running check on ",string DICT`proctype];
    .timer.once[DICT`starttime;functiontorun;"Running check once on ",string DICT`proctype]]
  }

reruncheck:{[chkid]                                                                                             /- rerun a check manually
  d:exec action, params, procname from .dqe.configtable where checkid=chkid;
  d[`params]: value d[`params][0];                                                                            
  .dqe.runcheck[`manual;chkid;.Q.dd[`.dqe;d`action];d`params;d`procname];                                       /- input man argument is `manual or `scheduled indicating manul run is on or off
  }


\d .

.dqe.currentpartition:.dqe.getpartition[];                                                                      /- initialize current partition

.servers.CONNECTIONS:`ALL                                                                                       /- set to nothing so that is only connects to discovery

.u.end:{[pt]    /- setting up .u.end for dqe
  .dqe.endofday[.dqe.getpartition[]];
  .dqe.currentpartition:pt+1;
  };

.dqe.init[]

`.dqe.configtable upsert .dqe.readdqeconfig[.dqe.configcsv;"S*SSSNNN"]                                          /- Set up configtable from csv
update checkid:til count .dqe.configtable from `.dqe.configtable
update starttime:.z.d+starttime from `.dqe.configtable                                                          /- from timespan to timestamp
update endtime:?[0W=endtime;0Wp;.z.d+endtime] from `.dqe.configtable

/ Sample runcheck:
/ show .dqe.results
/ Load up timers

/Sample reruncheck
/chkid:3
/.dqe.reruncheck[chkid]
if[not .dqe.testing;.dqe.loadtimer '[.dqe.configtable]]

