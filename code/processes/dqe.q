\d .dqe

configcsv:@[value;`.dqe.configcsv;first .proc.getconfigfile["dqeconfig.csv"]];

init:{
  .lg.o[`init;"searching for servers"];
  .servers.startup[];                                                                                           /- Open connection to discovery
  }

configtable:([] action:`symbol$(); params:(); proctype:(); procname:(); mode:(); starttime:`timespan$(); endtime:`timespan$(); period:`timespan$())

readdqeconfig:{[file]
  .lg.o["reading dqe config from ",string file:hsym file];                                                      /- notify user about reading in config csv
  c:.[0:;(("S****NNN";enlist",");file);{.lg.e["failed to load dqe configuration file: ",x]}]                    /- read in csv, trap error
 }

gethandles:{exec procname,proctype,w from .servers.SERVERS where (procname in x) | (proctype in x)};

tableexists:{[tab]                                                                                              /- function to check for table, param is table name as a symbol
  .lg.o[`dqe;"checking if ", (s:string tab), " table exists"];
  $[1=tab in tables[];
    (1b;s," table exists");
    (0b;s," missing from process")]
  };

tableticking:{[tab;timeperiod;timetype]                                                                         /- [table to check;time window to check for records;`minute or `second]
  $[0<a:count select from tab where time within (.z.p-timetype$"J"$string timeperiod;.z.p);
    (1b;"there are ",(string a)," records");
    (0b;"the table is not ticking")]
  }

chkslowsub:{[threshold]                                                                                         /- function to check for slow subscribers
  .lg.o[`dqe;"Checking for slow subscribers"];
  overlimit:(key .z.W) where threshold<sum each value .z.W;
  $[0=count overlimit;
    (1b;"no data queues over the limit, in ",string .proc.procname);
    (0b;raze"handle(s) ",("," sv string overlimit)," have queues")]
  }

fillprocname:{[rs;h]                                                                                            /- fill procname for results table
  val:rs where not rs in raze a:h`proctype`procname;
  (flip a),val,'`
  }

initstatusupd:{[id;funct;vars;rs]                                                                               /- set initial values in results table
  .lg.o[`initstatus;"setting up initial record(s) for id ",(string id)];
  `.dqe.results insert (id;funct;`$"," sv string raze (),vars;rs[0];rs[1];.z.p;0Np;`;"";`started);
  }

failchk:{[idnum;error;proc]
  .lg.o[`failerr;raze "run check id ",(string idnum)," update in results table with a fail, with ",(string error)];
  `.dqe.results set update chkstatus:`failed,output:`0,descp:enlist error from .dqe.results where id=idnum, procschk=proc;
  }

postback:{[idnum;proc;result]
  $["e"=first result;
  .dqe.failchk[idnum;result;proc];
  `.dqe.results set update endtime:.z.p,output:`$ string first result,descp:enlist last result,chkstatus:`complete from .dqe.results where id=idnum,procschk=proc];
  }

getresult:{[funct;vars;id;proc;hand]
  .lg.o[`getresults;raze"send function over to prcess: ",string proc];
  .async.postback[hand;funct,vars;.dqe.postback[id;proc]];                                                      /- send function with variables down handle
  }

runcheck:{[id;fn;vars;rs]                                                                                       /- function used to send other function to test processes
  fncheck:` vs fn;
  if[not fncheck[2] in key value .Q.dd[`;fncheck 1];                                                            /- run check to make sure passed in function exists
    .lg.e[`runcheck;"Function ",(string fn)," doesn't exist"];
    :()];

  rs:(),rs;                                                                                                     /- set rs to a list
  h:.dqe.gethandles[rs];                                                                                        /- check if processes exist and are valid

  r:.dqe.fillprocname[rs;h];
  .dqe.initstatusupd[id;fn;vars]'[r];
  
  .dqe.failchk[id;"error:can't connect to process";`];
  procsdown:(h`procname) where 0N = h`w;
  .dqe.failchk[id;"error:process is down or has lost its handle"]'[procsdown];

  if[0=count h;.lg.e[`handle;"cannot open handle to any given processes"];:()];                                 /- check if any handles exist, if not exit function
  ans:.dqe.getresult[value fn;(),vars;id]'[h[`procname];h[`w]]
  }

results:([]id:`long$();funct:`$();vars:`$();procs:`$();procschk:`$();starttime:`timestamp$();endtime:`timestamp$();output:`$();descp:();chkstatus:`$());

\d .

.servers.CONNECTIONS:`ALL                                                                                       /- set to nothing so that is only connects to discovery

.dqe.init[]

`.dqe.configtable upsert .dqe.readdqeconfig[.dqe.configcsv]
