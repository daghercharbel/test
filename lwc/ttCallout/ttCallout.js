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
            requestHeader.Authorization = 'Bearer ' + data.token;
            requestEndpoint = data.domain + requestEndpoint;
            const makeRequestResponse = await makeRequest();
            generateLog(makeRequestResponse, invoker);
            return makeRequestResponse;
        } else {
            return 'User has no access token';
        }
    } catch (error) {
        let errorStr = '';
        if (typeof error == 'object' && error.message) {
            if (error.lineNumber) { errorStr = error.lineNumber + ' - '; }
            errorStr += error.message
        } else {
            errorStr = error;
        }
        console.error('ttCallout 1: ', errorStr);
        return error;
    }

}

async function makeRequest() {

    let result = {};

    const response = await fetch(
        requestEndpoint,
        {
            'body': requestBody,
            'headers': requestHeader,
            'method': requestMethod
        }
    );

    console.log('VOD ----------------------- requestEndpoint ', requestEndpoint);
    console.log('VOD ----------------------- requestMethod ', requestMethod);
    console.log('VOD ----------------------- requestHeader ', requestHeader);
    console.log('VOD ----------------------- requestBody ', requestBody);

    requestHeader = undefined;
    requestBody = undefined;
    requestEndpoint = undefined;

    result.status = response.ok;
    result.status_code = response.status;
    console.log('VOD ----------------------- response.ok ', response.ok);
    console.log('VOD ----------------------- response.status ', response.status);
    let responseBody = await response.text();
    try {
        result.body = JSON.parse(responseBody);
    } catch (error) {
        result.body = responseBody;
    }
    console.log('VOD ----------------------- result.body ', result.body);
    return result;
}

function generateLog(response, invoker) {

    let message = 'Response Status Code: ' + response.status_code + ' | Response Body: ' + response.body;

    generateAndSaveLog({
        message: message,
        className: invoker.className,
        classMethod: invoker.classMethod,
        recordId: invoker.recordId,
    })
        .then(result => { })
        .catch(error => {
            let errorStr = '';
            if (typeof error == 'object' && error.message) {
                if (error.lineNumber) { errorStr = error.lineNumber + ' - '; }
                errorStr += error.message
            } else {
                errorStr = error;
            }
            console.error('ttCallout 2: ', errorStr);
        });
}