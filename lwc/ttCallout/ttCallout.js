import getCalloutInfo from '@salesforce/apex/TelosTouchUtility.getCalloutInfo';
import generateAndSaveLog from '@salesforce/apex/TelosTouchUtility.generateAndSaveLog';

var requestBody;
var requestEndpoint;
var requestHeader;
var requestMethod;

export async function handleRequest(method, endpoint, body, invoker) {

    requestBody = body;
    requestEndpoint = endpoint;
    requestHeader = {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
    };
    requestMethod = method;

    try {
        const result = await getCalloutInfo();
        if (result.status == 'success') {
            let data = JSON.parse(result.value);
            requestHeader.Authorization = 'Bearer '+data.token;
            requestEndpoint = data.domain+requestEndpoint;
            const makeRequestResponse = await makeRequest();
            generateLog(makeRequestResponse, invoker);
            return makeRequestResponse;
        } else {
            return 'User has no access token';
        }
    } catch (error) {
        errorStr = JSON.stringify(error);
        console.error(errorStr);
        return errorStr;
    }

}

async function makeRequest() {

    let result = {};
    let request = new Request(
        requestEndpoint,
        {
            'body': requestBody,
            'headers': requestHeader,
            'method': requestMethod
        }
    );

    const response = await fetch(request);
    result.status = response.ok;
    result.status_code = response.status;
    if(response.ok){
        result.body = await response.json();
    } else {
        result.body = await response.text();
    }
    return result;
}

function generateLog(response, invoker) {

    let message = 'Response Status Code: '+response.status_code+' | Response Body: '+response.body;

    generateAndSaveLog({ 
        message: message,
        className: invoker.className,
        classMethod: invoker.classMethod,
        recordId: invoker.recordId,
    })
        .then(result => {})
        .catch(error => {
            console.error(JSON.stringify(error));
        });
}