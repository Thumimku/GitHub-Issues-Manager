import ballerina/io;
import ballerina/log;
import wso2/gsheets4;
import ballerina/config;
import ballerina/http;


documentation{A valid access token with gmail and google sheets access.}
string accessToken = config:getAsString("ACCESS_TOKEN");

documentation{The client ID for your application.}
string clientId = config:getAsString("CLIENT_ID");

documentation{The client secret for your application.}
string clientSecret = config:getAsString("CLIENT_SECRET");

documentation{A valid refreshToken with gmail and google sheets access.}
string refreshToken = config:getAsString("REFRESH_TOKEN");

documentation{Spreadsheet id of the reference google sheet.}
string spreadsheetId = config:getAsString("SPREADSHEET_ID");

documentation{Sheet name of the reference googlle sheet.}
string sheetName = config:getAsString("SHEET_NAME");



endpoint http:Listener listener {
    port:9090
};

endpoint gsheets4:Client spreadsheetClient {
    clientConfig: {
        auth: {
            accessToken: accessToken,
            refreshToken: refreshToken,
            clientId: clientId,
            clientSecret: clientSecret
        }
    }
};

// Calculator REST service
@http:ServiceConfig { basePath: "/gitxcelintegrator" }
service<http:Service> Calculator bind listener {
    int rownum=6;
    // Resource that handles the HTTP POST requests that are directed to
    // the path `/operation` to execute a given calculate operation
    // Sample requests for add operation in JSON format
    // `{ "a": 10, "b":  200, "operation": "add"}`
    // `{ "a": 10, "b":  20.0, "operation": "+"}`

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/addentry"
    }
    executeOperation(endpoint client, http:Request req) {
        rownum=rownum+1;
        string RepositoryOwner="";
        string Repository="";
        string IssueTitle="";
        string IssueContent="";
        json operationReq = check req.getJsonPayload();
        var RepoOwner = operationReq.repoowner;
        match RepoOwner {
            string ivalue=> RepositoryOwner=ivalue;

            json other => {} //error
        }
        var Repo = operationReq.repo;
        match Repo {
            string ivalue=> Repository=ivalue;

            json other => {} //error
        }
        var IsTitle = operationReq.issuetitle;
        match IsTitle {
            string ivalue=> IssueTitle=ivalue;

            json other => {} //error
        }
        var IsContent = operationReq.issuecontent;
        match IsContent {
            string ivalue=> IssueContent=ivalue;

            json other => {} //error
        }

        string[][] setdata=[[RepositoryOwner,Repository,IssueTitle,IssueContent]];

        string topleft="A"+rownum;
        string bottomright="D"+rownum;
        var reply= spreadsheetClient->setSheetValues(spreadsheetId,"",topleft,bottomright,setdata);

        match reply {
            boolean bool=> {
                // Create response message.
                json payload = { status: "Result ", result: 0.0 };
                payload["result"] = bool;
                http:Response response;
                response.setJsonPayload(payload);

                // Send response to the client.
                _ = client->respond(response);
            }
            gsheets4:SpreadsheetError er=>{
                // Create response message.
                json payload = { status: "Result ", result: 0.0 };
                payload["result"] = er.message;
                http:Response response;
                response.setJsonPayload(payload);

                // Send response to the client.
                _ = client->respond(response);
            }

        }



    }
}