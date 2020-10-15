//- common script to enable remote data access via generic function
//- loads in scripts from code/common/dataaccess

\d .dataaccess

isenabled:{[]"b"$0^first first .proc.params`dataaccess};
enabled:@[isenabled;`;0n];

init:{
  .lg.o[`.dataaccess.init;"running .dataaccess.init[]"];
  .dataaccess.tablepropertiespath:first .proc.getconfigfile["tableproperties.csv"];         //- config defining any non standard attribute/primary time columns
  .dataaccess.checkinputspath:first .proc.getconfigfile["checkinputs.csv"];                 //- The name of the input csv to drive what gets done
  additionalscripts:getenv[`KDBCODE],"/common/dataaccess";                                  //- load all q scripts in this path
  .proc.loaddir additionalscripts;
  tablepropertiesconfig:readtableproperties[tablepropertiespath;"sssss"];
  checkinputsconfig:readcheckinputs[checkinputspath;"sbs*"];
  .lg.o[`.dataaccess.init;"running .dataaccess.init[] - finished"];
 };

\d .

if[.dataaccess.enabled;.dataaccess.init[]];
