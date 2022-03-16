/**
* @author Cloud Analogy
* @date 02/08/2021
* @description TT_ScheduleTelosTouchFeatureToggle class is used to schedule TT_FeatureToggle batch.
*/
public with sharing class TT_ScheduleTelosTouchFeatureToggle implements Schedulable {

    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ....
* @param ctx ...
*/
    public void execute(SchedulableContext ctx) {
        TelosTouchSF.TT_FeatureToggle inviteBatch= new 	TelosTouchSF.TT_FeatureToggle();
        Database.executeBatch(inviteBatch, 200);
    }
}