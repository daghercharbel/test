/**
* @author Cloud Analogy
* @date 02/08/2021
* @description TTUserConversationScheduler scheduler class....
*/
global with sharing class TTUserConversationScheduler implements Schedulable{
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description execute method..
* @param sx ...
*/
    global void execute(SchedulableContext sx) {
        System.debug(LoggingLevel.DEBUG, 'Execute Method');
    }
}