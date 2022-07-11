/***
 *                  ©2022 TelosTouch
 * ==================================================
 * 
 * Description: Class containing auxiliar methods for triggers
 * 
 * Author: vinicius.duarte@telostouch.com
 * Test Class: 
***/
public with sharing class TriggerUtils {

    public static void assertTrigger(){
        system.assert((trigger.isExecuting), 'Method being called outside trigger context.');
    }

    public static Boolean wasChanged(SObject record, String field){
        assertTrigger();
        if(Trigger.isInsert) return true;
        return record.get(field) != Trigger.oldMap.get(record.Id).get(field);
    }

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
