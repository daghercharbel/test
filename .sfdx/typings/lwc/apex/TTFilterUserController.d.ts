declare module "@salesforce/apex/TTFilterUserController.doinitApex" {
  export default function doinitApex(param: {campainId: any}): Promise<any>;
}
declare module "@salesforce/apex/TTFilterUserController.getCampaignData" {
  export default function getCampaignData(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/TTFilterUserController.requestSync" {
  export default function requestSync(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/TTFilterUserController.getUserDetails" {
  export default function getUserDetails(param: {campainId: any, filterWrapper: any, isFormType: any}): Promise<any>;
}
declare module "@salesforce/apex/TTFilterUserController.insightCallout" {
  export default function insightCallout(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/TTFilterUserController.getUserAnswers" {
  export default function getUserAnswers(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/TTFilterUserController.campaignInsertandSendTouchPoint" {
  export default function campaignInsertandSendTouchPoint(param: {campaignName: any, userList: any}): Promise<any>;
}
declare module "@salesforce/apex/TTFilterUserController.sendReminder" {
  export default function sendReminder(param: {campainId: any, userList: any}): Promise<any>;
}
declare module "@salesforce/apex/TTFilterUserController.getTaskDetails" {
  export default function getTaskDetails(): Promise<any>;
}
declare module "@salesforce/apex/TTFilterUserController.saveNewTask" {
  export default function saveNewTask(param: {tasklist: any}): Promise<any>;
}
declare module "@salesforce/apex/TTFilterUserController.fetchRecordType" {
  export default function fetchRecordType(): Promise<any>;
}
declare module "@salesforce/apex/TTFilterUserController.fetchCampaignRecordType" {
  export default function fetchCampaignRecordType(): Promise<any>;
}
declare module "@salesforce/apex/TTFilterUserController.addClientsToCampaign" {
  export default function addClientsToCampaign(param: {campRecordId: any, userListStr: any}): Promise<any>;
}
declare module "@salesforce/apex/TTFilterUserController.fetchRecords" {
  export default function fetchRecords(param: {objectName: any, filterField: any, searchString: any, campaignRecordId: any}): Promise<any>;
}
declare module "@salesforce/apex/TTFilterUserController.fetchLimitedRecords" {
  export default function fetchLimitedRecords(param: {campaignRecordId: any}): Promise<any>;
}
declare module "@salesforce/apex/TTFilterUserController.isClientTaggingEnabled" {
  export default function isClientTaggingEnabled(): Promise<any>;
}
