# GitHub-Issues-Manager

First run service.bal to initiate the service

Type following command in the terminal:- 
     
***
`$ ballerina run service.bal`

***


If the command succeed you will see following response:- 


* `ballerina: initiating service(s) in 'service.bal' `
* `ballerina: started HTTP/WS endpoint 0.0.0.0:9090`


Type following command in another terminal:- 
* ` $ ballerina run client.bal`

If the command succeed you will see following response:- 
* `Enter Repository Owner Name:- `
* `Enter Repository Name:- `
* `Enter Issue Title:- `
* `Enter Issue Content:-`

You have to fill above credentials.

Then you have to visit certain google sheet and review the issues mark the 5th column 0 or 1.


Finally run weekpro.bal to get sheet details from excel sheet and create issues.
* ` $ ballerina run weekpro.bal`
