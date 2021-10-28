%macro displaypythonresults(fn=);
	ods escapechar="^"; 
	 
	ods text='^S={preimage=&fn}';
	 
	data temp; 
	 success=" "; 
	run; 
	                                                                                                                                        
	proc report data=temp nowd noheader style(report)={rules=none frame=void outputheight=10% outputwidth=10%}; 
	  column center; 
	  define center / style={just=c}; 
	run; 
	/**/
	ods  _ALL_  close;      
%mend displaypythonresults;
