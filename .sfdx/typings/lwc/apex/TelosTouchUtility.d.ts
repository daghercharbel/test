declare module "@salesforce/apex/TelosTouchUtility.getTTCampaignId" {
  export default function getTTCampaignId(param: {campId: any, remainingClientIds: any}): Promise<any>;
}
declare module "@salesforce/apex/TelosTouchUtility.getSettingAPI" {
  export default function getSettingAPI(param: {isCallingFrom: any, campId: any}): Promise<any>;
}
declare module "@salesforce/apex/TelosTouchUtility.sendCampaignTouchPoint" {
  export default function sendCampaignTouchPoint(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/TelosTouchUtility.getAdminAccessToken" {
  export default function getAdminAccessToken(param: {apiSetting: any, isCallingFrom: any}): Promise<any>;
}
declare module "@salesforce/apex/TelosTouchUtility.getUserAccessToken" {
  export default function getUserAccessToken(param: {adminCredentials: any, isCallingFrom: any}): Promise<any>;
}
declare module "@salesforce/apex/TelosTouchUtility.sendSFUserToTT" {
  export default function sendSFUserToTT(param: {sfUserList: any, listofUserId: any}): Promise<any>;
}
declare module "@salesforce/apex/TelosTouchUtility.getUserList" {
  export default function getUserList(): Promise<any>;
}
declare module "@salesforce/apex/TelosTouchUtility.scheduleAllJobsFromHere" {
  export default function scheduleAllJobsFromHere(): Promise<any>;
}
declare module "@salesforce/apex/TelosTouchUtility.abortScheduleJob" {
  export default function abortScheduleJob(param: {apiSettingList: any}): Promise<any>;
}
declare module "@salesforce/apex/TelosTouchUtility.shareWithClients" {
  export default function shareWithClients(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/TelosTouchUtility.checkIfPostInstallScriptRunning_APEX" {
  export default function checkIfPostInstallScriptRunning_APEX(): Promise<any>;
}
declare module "@salesforce/apex/TelosTouchUtility.checkClientInvite" {
  export default function checkClientInvite(param: {recordId: any, objectName: any, action: any, userId: any, lastLoginDate: any}): Promise<any>;
}
declare module "@salesforce/apex/TelosTouchUtility.sendUserInvitation" {
  export default function sendUserInvitation(param: {recordObject: any, action: any}): Promise<any>;
}
declare module "@salesforce/apex/TelosTouchUtility.massInvitationToClients" {
  export default function massInvitationToClients(param: {recordIdsList: any, objectName: any}): Promise<any>;
}
declare module "@salesforce/apex/TelosTouchUtility.checkInviteFunctionality" {
  export default function checkInviteFunctionality(): Promise<any>;
}
declare module "@salesforce/apex/TelosTouchUtility.getCampaignDetails" {
  export default function getCampaignDetails(param: {campSfId: any}): Promise<any>;
}
declare module "@salesforce/apex/TelosTouchUtility.addClientsToTouchpoint" {
  export default function addClientsToTouchpoint(param: {campMemListStr: any}): Promise<any>;
}
declare module "@salesforce/apex/TelosTouchUtility.createUpdateMetadata" {
  export default function createUpdateMetadata(param: {isTTActive: any, isSFActive: any, MasterLabel: any}): Promise<any>;
}
declare module "@salesforce/apex/TelosTouchUtility.getInviteFlag" {
  export default function getInviteFlag(): Promise<any>;
}
declare module "@salesforce/apex/TelosTouchUtility.sendRegistrationRequest" {
  export default function sendRegistrationRequest(): Promise<any>;
}
declare module "@salesforce/apex/TelosTouchUtility.checkIfEnterpriseClient" {
  export default function checkIfEnterpriseClient(): Promise<any>;
}
declare module "@salesforce/apex/TelosTouchUtility.revokeUserAccess" {
  export default function revokeUserAccess(param: {userId: any, listOfTTUser: any}): Promise<any>;
}
declare module "@salesforce/apex/TelosTouchUtility.refreshTokenController" {
  export default function refreshTokenController(): Promise<any>;
}
declare module "@salesforce/apex/TelosTouchUtility.getCampaignData" {
  export default function getCampaignData(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/TelosTouchUtility.getTouchPointTemplates" {
  export default function getTouchPointTemplates(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/TelosTouchUtility.setTouchPointTemplateId" {
  export default function setTouchPointTemplateId(param: {campaignRecordId: any, touchPointTemplateId: any}): Promise<any>;
}
declare module "@salesforce/apex/TelosTouchUtility.getCurrentTemplateId" {
  export default function getCurrentTemplateId(param: {campaignRecordId: any}): Promise<any>;
}
declare module "@salesforce/apex/TelosTouchUtility.sendTouchPointFromSF" {
  export default function sendTouchPointFromSF(param: {campaignSFId: any, touchPointTemplateId: any, isSynced: any}): Promise<any>;
}
declare module "@salesforce/apex/TelosTouchUtility.generateCustomizeIFrame" {
  export default function generateCustomizeIFrame(param: {templateId: any, campaignId: any}): Promise<any>;
}
declare module "@salesforce/apex/TelosTouchUtility.fetchSelectedTouchPointTemplate" {
  export default function fetchSelectedTouchPointTemplate(param: {recordId: any}): Promise<any>;
}
