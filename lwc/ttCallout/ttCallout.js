import getCalloutInfo from '@salesforce/apex/TelosTouchUtility.getCalloutInfo';
import generateAndSaveLog from '@salesforce/apex/TelosTouchUtility.generateAndSaveLog';

export async function handleRequest(method, endpoint, body, invoker) {

    let requestHeader = {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
    };
    try {
        const result = await getCalloutInfo();
        if (result.status == 'success') {
            let data = JSON.parse(result.value);
            requestHeader.Authorization = 'Bearer ' + data.token;
            let requestEndpoint = data.domain + endpoint;
            const makeRequestResponse = await makeRequest(requestEndpoint, body, requestHeader, method, null);
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

export async function makeRequest(requestEndpoint, requestBody, requestHeader, requestMethod, invoker) {

    let result = {};

    const response = await fetch(
        requestEndpoint,
        {
            'body': requestBody,
            'headers': requestHeader,
            'method': requestMethod
        }
    );

    result.status = response.ok;
    result.status_code = response.status;
    let responseBody = await response.text();
    try {
        result.body = JSON.parse(responseBody);
    } catch (error) {
        result.body = responseBody;
    }
    if (invoker) {
        generateLog(result, invoker);
    }
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