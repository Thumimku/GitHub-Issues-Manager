import ballerina/io;
import ballerina/log;
import wso2/gsheets4;
import ballerina/config;
import wso2/github4;
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
endpoint github4:Client githubEP {
    clientConfig: {
        auth:{
            scheme:http:OAUTH2,
            accessToken:config:getAsString("GITHUB_TOKEN")

        }
    }
};






function main(string... args) {
    string[][] issuedetails=getIssueDetailsFromGSheet();
    //Iterate through each customer details and send customized email.
    foreach value in issuedetails {
        //Skip the first row as it contains header values.
            string repoOwnerName = value[0];
            string repoName = value[1];
            string issueTitle = value[2];
            string issueContent=value[3];
            string acceptence=value[4];
            if(acceptence.equalsIgnoreCase("1")){
                boolean status=createIssueInGithub(repoOwnerName,repoName,issueTitle,issueContent);
            }




    }

}

function getIssueDetailsFromGSheet () returns (string[][]) {
    //Read all the values from the sheet.
    string[][] values;
    var spreadsheetRes =  spreadsheetClient->getSheetValues(spreadsheetId, "", "A2", "E5");
    match spreadsheetRes {
        string[][] vals => {
            log:printInfo("Retrieved customer details from spreadsheet id:" + spreadsheetId + " ; sheet name: "
                    + sheetName);
            return vals;
        }
        gsheets4:SpreadsheetError e => {log:printInfo("Error occured customer details from spreadsheet id:" + spreadsheetId + " ; sheet name: "
                    + sheetName+ " ; error: "+e.message);
            return values;}
    }
}

function createIssueInGithub( string repoOwnername, string repoName,string issueTitle,string issueContent) returns(boolean){


    var repo = githubEP->createIssue(untaint repoOwnername,untaint repoName,issueTitle,issueContent,[],[]);
    match repo {
        github4:Issue issue=>{
            log:printInfo("Successfully created issue in repository :" + repoOwnername + "/"+repoName+"issue id: "
                    + issue.id);
            return true;
        }

        github4:GitClientError err => {
            log:printInfo("Failed to created issue in repository :" + repoOwnername + "/"+repoName+" error message : "
                    + err.message);
            return false;
        }
    }


}


