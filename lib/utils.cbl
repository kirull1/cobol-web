       identification division.
       program-id. get-func.
       
       environment division.
       configuration section.
       
       data division.

       working-storage section.
       77 parse-path pic x(2048).

       linkage section.
       01 http-tbl.
           05 http-host pic x(50).
           05 http-len  pic 9(5).
           05 http-cap  pic 9(5).
           05 http-func occurs 256 times.
              10 func usage procedure-pointer.
           05 http-tab  occurs 256 times.
              10 tab-path   pic x(2048).
              10 tab-method pic x(16).

       77 request-path     pic x(2048).
       77 request-method   pic x(16).
       77 status-func      pic 9.
       77 idx-func         pic s9(5).
       
       procedure division using http-tbl, request-path, request-method, 
                           status-func, idx-func.
        
           unstring
               request-path delimited by "?"
               into parse-path
           end-unstring.

           set status-func to 0.

           perform varying idx-func from 1 
           until idx-func is greater than http-len
               if tab-path(idx-func) is equal parse-path 
               and tab-method(idx-func) is equal request-method then
                   set status-func to 1
                   exit program
               end-if
           end-perform.

           exit program.
       
       end program get-func.

      ********************************

       identification division.
       program-id. date-utc.
       
       data division.

       working-storage section.
       01 DATETIME pic 9(8).
       01 DT.
           05 YEAR         pic 9(4).
           05 MONTH        pic 9(2).
           05 MONTH-NAME   pic x(3).
           05 DY           pic 9(2).
           05 DY-NAME      pic x(3).
      
       01  WS-TODAY         pic 9(8).
       01  WS-FUTURE-DATE   pic 9(8).

       77 result  pic 9(8).
       77 residue pic 9(8).

       linkage section.
       77 result-string pic x(29).
       77 days pic 9(4).

       procedure division using result-string, days.
        
           move function CURRENT-DATE(1:8) to WS-TODAY.
           compute WS-FUTURE-DATE = 
                       function INTEGER-OF-DATE(WS-TODAY) + days.

           compute DATETIME = 
                   function DATE-OF-INTEGER(WS-FUTURE-DATE).

           set YEAR to DATETIME(1:4).
           set MONTH to DATETIME(5:2).
           set DY to DATETIME(7:2).

           divide WS-FUTURE-DATE by 7 giving result remainder residue.

           evaluate residue
               when 0
                   move "Sun" to DY-NAME
               when 1
                   move "Mon" to DY-NAME
               when 2
                   move "Tue" to DY-NAME
               when 3
                   move "Wed" to DY-NAME
               when 4
                   move "Thu" to DY-NAME
               when 5
                   move "Fri" to DY-NAME
               when 6
                   move "Sat" to DY-NAME
           end-evaluate.

           evaluate MONTH
               when 1
                   move "Jan" to MONTH-NAME
               when 2
                   move "Feb" to MONTH-NAME
               when 3
                   move "Mar" to MONTH-NAME
               when 4
                   move "Apr" to MONTH-NAME
               when 5
                   move "May" to MONTH-NAME
               when 6
                   move "Jun" to MONTH-NAME
               when 7
                   move "Jul" to MONTH-NAME
               when 8
                   move "Aug" to MONTH-NAME
               when 9
                   move "Sep" to MONTH-NAME
               when 10
                   move "Oct" to MONTH-NAME
               when 11
                   move "Nov" to MONTH-NAME
               when 12
                   move "Dec" to MONTH-NAME
           end-evaluate.

           move spaces to result-string.

           string
               DY-NAME
               X"2C" X"20"
               DY 
               X"20"
               MONTH-NAME
               X"20"
               YEAR 
               X"20"
               "00:00:00" 
               X"20"
               "GMT"
               into result-string
           end-string.

           exit program.
       
       end program date-utc.

      ********************************

       identification division.
       program-id. parse-path.
      
       data division.
       
       working-storage section.
       77 i pic 9(4).
       77 j pic 9(3).
       77 ct pic 9.
       77 request-path-size pic 9(4).

       linkage section.
       01 parse-path.
           05 parse-get occurs 256 times.
               10 get-name     pic x(32).
               10 get-value    pic x(256).
           05 parse-get-size pic 9(3).

       77 request-path pic x(2048).
      
       procedure division using parse-path, request-path.

           set request-path-size to 
               function length(function trim(request-path)).
        
           perform varying i from 1 by 1 
           until i is greater request-path-size
               if request-path(i:1) is equal "?" then
                   exit perform
               end-if
           end-perform.

           if i is greater request-path-size then
               exit program
           end-if.

           move request-path(i + 1:) to request-path.

           call "parse-urlencoded"
           using by reference parse-path,
           by content request-path.

           exit program.
      
       end program parse-path.

      ********************************

       identification division.
       program-id. parse-urlencoded.
       
       data division.

       working-storage section.
       77 i pic 9(4).
       77 j pic 9(3).
       77 ct pic 9.
       77 string-size pic 9(4).

       linkage section.
       01 parse-urlencoded.
           05 parse-data occurs 256 times.
               10 parse-name     pic x(32).
               10 parse-value    pic x(256).
           05 parse-size pic 9(3).

       77 request-string pic x(2048).
       
       procedure division using parse-urlencoded, request-string.

           if request-string is equal spaces then
               exit program
           end-if.
        
           set string-size 
               to function length(function trim(request-string)).

           set ct to 1.
           set j to 1.
           set parse-size to 1.

           add 1 to i.

           perform varying i from 1 by 1
           until i is greater string-size
               evaluate ct
                   when 1
                       if request-string(i:1) is equal "=" then
                           set ct to 2
                           set j to 0
                       else
                           move request-string(i:1)
                               to parse-name(parse-size)(j:1)
                       end-if
                   when 2
                       if request-string(i:1) is equal "&" then
                           set ct to 1
                           set j to 0
                           add 1 to parse-size
                       else
                           move request-string(i:1)
                               to parse-value(parse-size)(j:1)
                       end-if
               end-evaluate

               add 1 to j
           end-perform.

           exit program.
       
       end program parse-urlencoded.
