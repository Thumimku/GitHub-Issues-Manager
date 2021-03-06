
import ballerina/http;
import ballerina/io;
import ballerina/log;

endpoint http:Client clientEndpoint {
    url: "http://localhost:9090"
};

function main(string... args) {

    http:Request req = new;

    string RepositoryOwner=io:readln("Enter Repository Owner Name:- ");
    string Repository=io:readln("Enter Repository  Name:- ");
    string IssueTitle=io:readln("Enter Issue Title:- ");
    string IssueContent=io:readln("Enter Issue Content ");

    // Set the JSON payload to the message to be sent to the endpoint.
    json jsonMsg = {repoowner: RepositoryOwner, repo: Repository, issuetitle: IssueTitle,issuecontent: IssueContent };
    req.setJsonPayload(jsonMsg);

    var response = clientEndpoint->post("/gitxcelintegrator/addentry", req);
    match response {
        http:Response resp => {
            var msg = resp.getJsonPayload();
            match msg {
                json jsonPayload => {
                    string resultMessage = "Result " + jsonPayload["result"].toString();
                    io:println(resultMessage);
                }
                error err => {
                    log:printError(err.message, err = err);
                }
            }
        }
        error err => { log:printError(err.message, err = err); }
    }
}