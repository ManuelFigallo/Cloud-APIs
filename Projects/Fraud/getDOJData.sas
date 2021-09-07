/***********************************************************************************/
/* Program Name: getDOJData                                         			   */
/* Date Created: 8/15/2021                                                         */
/* Author: 	Manuel Figallo                                                         */
/* Purpose: extract  press releases from  DOJ site                      		   */
/*                                                                                 */
/* ------------------------------------------------------------------------------- */
/*                                                                                 */
/* Input(s): remoteURL is the REST Query for justice    .gov                       */
/*           localDataset is the dataset with all comments from the REST query     */
/* Output(s): sas7bdat with all the press releases                                 */
/*                                                                                 */
/* ---------------------THE SECTION BELOW IS FOR FUTURE ENHANCEMENTS-------------- */
/* Date Modified: TBD                                                              */
/* Modified by: TBD                                                                */
/* Reason for Modification: TBD                                                    */
/* Modification Made: TBD                                                          */
/***********************************************************************************/
options noquotelenmax;

%macro getDOJData(remoteURL=, localDataset=);
      %if &remoteURL= %then
            %do;
                  %put ERROR: A null value is not valid.;
                  %put ERROR- Please provide an HTTP location.;
 
                  %return;
            %end;
 
     %if &localDataset= %then
            %do;
                  %put ERROR: A null value is not valid.;
                  %put ERROR- Please provide an destination location on your C: drive, S: drive, etc.;
                  %return;
            %end;
      %let remoteURL2 = %QSYSFUNC(TRANWRD(&remoteURL, %str(%"), %str(%')));
      %put &remoteURL2;
      %put &remoteURL2;
 
      proc ds2;
 
            data &localDataset (overwrite=yes);
                  /* Global package references */
                  dcl package json j();
                  dcl char(32767) BODY;
				  /*DATE is a reserved word:
				  https://go.documentation.sas.com/doc/en/vdmmlcdc/8.11/ds2pg/p1rnsddd78roken1tlwnfk4poavl.htm
				  */
                  dcl nchar(32767) DATE2;
                  dcl char(32767) TITLE;
                  dcl char(32767) UUID;
 
                  dcl varchar(3276700) character set utf8 response;
            
                  dcl int rc;
                  drop response rc;
 
                  method parseMessages();
                        dcl int tokenType parseFlags;
                        dcl nvarchar(3276700) token;
                        rc=0;
 
                        do while (rc=0);
                    		  j.getNextToken( rc, token, tokenType, parseFlags);

                              if (token = 'body') then do;
							  		   j.getNextToken( rc, token, tokenType, parseFlags);
									   put rc= tokenType= token=;
                                       BODY=token;
									   output;
							  end;

                              if (token = 'date') then do;
							  		   j.getNextToken( rc, token, tokenType, parseFlags);
									   put rc= tokenType= token=;
                                       DATE2=token;
									   output;
							  end;

                              if (token = 'title') then do;
							  		   j.getNextToken( rc, token, tokenType, parseFlags);
									   put rc= tokenType= token=;
                                       TITLE=token;
									   output;
							  end;

                              if (token = 'uuid') then do;
							  		   j.getNextToken( rc, token, tokenType, parseFlags);
									   put rc= tokenType= token=;
                                       UUID=token;
									   output;
							  end; 

                          end;
 
                        return;
                  end;
 
                  method init();
                        dcl package http webQuery();
                        dcl int rc tokenType parseFlags;
                        dcl nvarchar(3276700) token;
                        dcl integer i rc;
 
                        /* create a GET call to the API                                         */
                        webQuery.createGetMethod(&remoteURL2);
 
                        /* execute the GET */
                        webQuery.executeMethod();
 
                        /* retrieve the response body as a string */
                        webQuery.getResponseBodyAsString(response, rc);
 
                        *put response;
                        rc = j.createParser( response );
                        do while (rc = 0);
                        /*mf*/
                        j.getNextToken( rc, token, tokenType, parseFlags);
 
                              if (token = 'results') then
                                    parseMessages();
                                    
                        end;
                  end;
 
                  method term();
                        rc = j.destroyParser();
                  end;
 
            enddata;
      run;
 
            quit;
 
%mend getDOJData;
 

%getDOJData(remoteURL=%str("https://www.justice.gov/api/v1/press_releases.json?pagesize=20"), 
localDataset=test10)
