\d .dqe

/- checks if any variable for check function is type symbol
evaluate:{[table]
  if[0=count where(),(11h=abs type table)&(table in .Q.pt);:value table];
  .lg.o[`evaluate;(string table)," has been changed to a functional select with a where clause"];
  ?[table;enlist (=;.Q.pf;last .Q.PV);0b;()]
  } 
