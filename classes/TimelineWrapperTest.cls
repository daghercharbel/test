@isTest
private with sharing class TimelineWrapperTest {
    @isTest
    static  void timelineWrapperTest1() {
        TimelineWrapper.FutureTimeline futureTimelineRecord = new TimelineWrapper.FutureTimeline();
        futureTimelineRecord.taskId = 'Test';
        futureTimelineRecord.taskName = 'Test';
        futureTimelineRecord.description = 'Test';
        futureTimelineRecord.sharedWithClient = 'Test';
        futureTimelineRecord.campId = 'Test';
        futureTimelineRecord.campName = 'Test';
        futureTimelineRecord.type = 'Test';
        
        TimelineWrapper.PastTimeline pastTimelineRecord = new TimelineWrapper.PastTimeline();
        pastTimelineRecord.taskId = 'Test';
        pastTimelineRecord.taskName = 'Test';
        pastTimelineRecord.description = 'Test';
        pastTimelineRecord.sharedWithClient = 'Test';
        pastTimelineRecord.campId = 'Test';
        pastTimelineRecord.campName = 'Test';
        pastTimelineRecord.type = 'Test';
        
        TimelineWrapper.past pastRecord = new TimelineWrapper.past();
        pastRecord.status = 'Test';
        pastRecord.name = 'Test';
        pastRecord.description = 'Test';
        pastRecord.shared = 1;
        pastRecord.Id = 'Test';
        pastRecord.name_fr = 'Test';
        pastRecord.type = 'Test';
        pastRecord.dateStart = 'Test';
        pastRecord.completedAt = 'Test';
        pastRecord.createdAt = 'Test';
        pastRecord.openedAt = 'Test';
        pastRecord.assignedUserId = 'Test';
        pastRecord.assignedUserName = 'Test';
        pastRecord.touchpoint_send_id = 'Test';
        pastRecord.image_id = 'Test';
        pastRecord.createdById = 'Test';
        pastRecord.createdByName = 'Test';
        
        TimelineWrapper.future futureRecord = new TimelineWrapper.future();
        futureRecord.createdAt = 'Test';
        futureRecord.completedAt = 'Test';
        futureRecord.dateStart = 'Test';
        futureRecord.shared = 1;
        futureRecord.openedAt = 'Test';
        futureRecord.assignedUserId = 'Test';
        futureRecord.status = 'Test';
        futureRecord.assignedUserName = 'Test';
        futureRecord.description = 'Test';
        futureRecord.createdById = 'Test';
        futureRecord.name_fr = 'Test';
        futureRecord.createdByName = 'Test';
        futureRecord.name = 'Test';
        futureRecord.touchpoint_send_id = 'Test';
        futureRecord.image_id = 'Test';
        futureRecord.type = 'Test';
        futureRecord.id = 'Test';
        system.assert(futureRecord!= null, 'futureRecord should not be NULL');
 }
}