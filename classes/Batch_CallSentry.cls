global with sharing class Batch_CallSentry implements Database.Batchable<sObject>, Database.AllowsCallouts {

    public String packageVersion;

    public Batch_CallSentry(){

        String aPublisher = 'TelosTouchSF';
        list<Publisher> lstPub = [SELECT MajorVersion,MinorVersion FROM Publisher WHERE NamespacePrefix =: aPublisher];
        if(!lstPub.isEmpty()){
            this.packageVersion = aPublisher+'@'+lstPub[0].MajorVersion+'.'+lstPub[0].MajorVersion;
        }

    }

    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(String.escapeSingleQuotes(
            'SELECT Id,CreatedDate,Name,TelosTouchSF__Comments__c,TelosTouchSF__Record_Id__c,TelosTouchSF__Result__c '
            +'FROM TelosTouchSF__TT_Log__c WHERE TelosTouchSF__Synchronized__c = false ORDER BY CreatedDate ASC'));   
    }

    global void execute(Database.BatchableContext bc,List<TelosTouchSF__TT_Log__c> scope){
        try {

            String endpoint = 'https://sentry.telostouch.com/api/4/store/';

            map<String, String> mapHeader = new map<String, String>();
            mapHeader.put('Content-Type', 'application/json');
            mapHeader.put('Accept', 'application/json');
            mapHeader.put('X-Sentry-Auth', 'Sentry sentry_version=7,sentry_key=6cff5fb74951480aa2865945a1ee6c66,sentry_secret=b14b391e652b4e1d880de6f6d81a4788');

            String exceptionStr = '[';

            for(TelosTouchSF__TT_Log__c log : scope){
                exceptionStr += '{"type":"'+log.TelosTouchSF__Result__c+'",';
                exceptionStr += '"value":"'+String.valueOf(log).replace('"','\\"')+'",';
                exceptionStr += '"module":"Salesforce"},';
            }
            exceptionStr +='{"type":"'+System.DomainParser.parse(URL.getOrgDomainUrl().toExternalForm()).getMyDomainName()+'",'
            +'"value":"Salesforce hourly auto generated log",'
            +'"module":"Salesforce"}]';

            String body = '{'+
            '"culprit":"'+UserInfo.getOrganizationId()+'",'+
            '"timestamp":"'+DateTime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss')+'",'+
            '"server_name":"'+URL.getOrgDomainUrl().toExternalForm()+'",'+
            '"platform": "other",'+
            '"level": "info",'+
            '"release": "'+packageVersion+'",'+
            '"exception":{"values":'+exceptionStr+'}'+
            '}';
            
            Map<String, String> mapResponse = TelosTouchUtility.getResponse('POST', endpoint, mapHeader, body);
            String respMessage = 'Response Status Code: '+mapResponse.get('status_code')+' | Response Body: '+mapResponse.get('body');
            String aMessage = 'Batch_CallSentry.execute: '+respMessage;
            TelosTouchSF__TT_Log__c log = SFDataSyncWithTelosTouch.addLogRecordWithRecordId('Success', aMessage, null);
            if(Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__Synchronized__c.isAccessible()  && Schema.sObjectType.TelosTouchSF__TT_Log__c.fields.TelosTouchSF__Synchronized__c.isCreateable()){
                log.TelosTouchSF__Synchronized__c = true;
            }
            Database.insert(log, AccessLevel.USER_MODE);

            if(mapResponse.containsKey('status_code') && mapResponse.get('status_code') == '200'){
                for(TelosTouchSF__TT_Log__c aLog : scope){
                    aLog.TelosTouchSF__Synchronized__c = true;
                }
                Database.update(scope);
            }


        } catch (Exception ex) {
            TelosTouchUtility.generateAndSaveErrorLog(ex, 'Batch_CallSentry', 'execute', null);
        }
    }

    global void finish(Database.BatchableContext bc){
        
    }

}