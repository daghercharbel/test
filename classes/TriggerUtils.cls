/**
 *                  ©2022 TelosTouch
 * ==================================================
 * 
 * Description: Class containing auxiliar methods for triggers
 * 
 * Author: vinicius.duarte@telostouch.com
 * Test Class: 
 *  @description ........
***/
public with sharing class TriggerUtils {
  /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
*/
    public static void assertTrigger(){
        system.assert((trigger.isExecuting), 'Method being called outside trigger context.');
    }
 /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
* @param record ...
* @param field ...
* @return Boolean ...
*/
    public static Boolean wasChanged(SObject record, String field){
        assertTrigger();
        if(Trigger.isInsert) return true;
        if(record.get(field) == null){
            return record.get(field) != Trigger.oldMap.get(record.Id).get(field);
        } else {
            return !String.valueOf(record.get(field)).equals((String)Trigger.oldMap.get(record.Id).get(field));
        }
    }

    //COMMENTED TO BE IMPLEMENTED IN THE FUTURE
    /*public static Boolean wasChangedFrom(SObject record, String field, Object expectedValue){
        assertTrigger();
        if(Trigger.isInsert) return false;
        return expectedValue == trigger.oldMap.get(record.Id).get(field);
    }

    public static Boolean wasChangedTo(SObject record, String field, Object expectedValue)
    {
        assertTrigger();
        return expectedValue == record.get(field) && (trigger.isInsert || record.get(field) != trigger.oldMap.get(record.id).get(field));
    }

    public static Boolean wasChangedFromTo(SObject record, String field, Object expectedValue, Object oldExpectedValue){
        return (wasChangedTo(record, field, expectedValue) && wasChangedFrom(record, field, oldExpectedValue));
    }*/

}