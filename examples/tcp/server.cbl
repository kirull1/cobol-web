       identification division.
       program-id. tcp-server.
       
       data division.
       working-storage section.
       01  server.
           05  listener        pic S9(3).
           05  connect         pic S9(3).
           05  buffer          pic X(512).
           05  buffer-size     pic s9(3).
           05  buffer-size-st  pic 9(3).
           05  request-length  pic s9(3).
           
       77  server-address  pic X(21).

       77  exit-message    pic X(5)  value "!exit".
       77  welcome-message pic X(49) value "Print !exit or empty message
      -" to close connection.".
       77  default-message pic X(44) value "This is the default message 
      -"from the server.".
       77  end-message     pic X(19) value "Client disconnected".
      
       procedure division.
           
           start-server.
               set buffer-size-st to 512.

               perform run-listener.
               perform server-listener.
               stop run.

           run-listener.
               move "0.0.0.0:8000" to server-address.

               call "listen_tcp" using by content server-address 
                   returning listener.

               if listener is less than 0 then
                   display "SERVER ERROR: "listener
                   stop run
               end-if.

               display "Server is listening ...".

               exit paragraph.

           server-listener.
               call "accept_tcp" using by value listener
                   returning connect.

               if connect is less than 0 then
                   display "ACCEPT ERROR: "connect
                   stop run
               end-if.

               move spaces to buffer.
               set buffer-size to 1.

               string 
                   function trim(welcome-message)
                   into buffer
                   with pointer buffer-size
               end-string.

               call "send_tcp" using by value connect,
                   by content function trim(buffer), 
                   by value buffer-size.

               perform process-request.

               call "close_tcp" using by value connect.

               perform server-listener.

               exit paragraph.

           process-request.
               move spaces to buffer.

               call "request_tcp" using by value connect, 
                   by reference buffer, by value buffer-size-st 
                   returning request-length.

               if request-length is less than 0 then
                   display end-message
                   exit paragraph
               end-if.

               if request-length is greater than 0 then
                   display "CLIENT MESSAGE: "buffer(1:request-length)

                   if buffer(1:request-length) is equal exit-message
                       perform send-exit-message
                   else
                       move spaces to buffer
                       set buffer-size to 1

                       string 
                           function trim(default-message)
                           into buffer
                           with pointer buffer-size
                       end-string

                       call "send_tcp" using by value connect,
                           by content function trim(buffer), 
                           by value buffer-size

                       perform process-request
                   end-if

                   exit paragraph
               end-if.

               perform send-exit-message.

               exit paragraph.

           send-exit-message.
               move spaces to buffer.
               set buffer-size to 1.

               string 
                   function trim(exit-message)
                   into buffer
                   with pointer buffer-size
               end-string.
               
               call "send_tcp" using by value connect,
                   by content function trim(buffer), 
                   by value buffer-size.

               display end-message.

               exit paragraph.
      
       end program tcp-server.
