public with sharing class MassCreateTaskCompController {
    @AuraEnabled
    public static Boolean checkNamedCredentials(){
        try {
            if( [SELECT count() FROM NamedCredential WHERE DeveloperName = 'ToolingRest' WITH SECURITY_ENFORCED LIMIT 1] > 0 ){
                return true;
            }
            return false;
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, 'Exception ' + ex.getMessage());
            return null;
        }
    }
    @AuraEnabled
    public static void createTasks(String taskObjStr, String userListStr) {
        if (String.isNotEmpty(taskObjStr)) {
            list<Task> taskList = new List<Task>();
            Task taskObj = new Task();
            taskObj = (Task) JSON.deserialize(taskObjStr, Task.class);
            List<Object> userList = new List<Object>();
            Set<Id> whoIdSet = new Set<Id>();
            if (String.isNotEmpty(userListStr)) {
                userList = (List<Object>) JSON.deserializeUntyped(userListStr);
            }
            if (userList != null && !userList.isEmpty()) {
                for (Object each : userList) {
                    Map<String, Object> userListObj = new Map<String, Object>();
                    userListObj = (Map<String, Object>) each;
                    whoIdSet.add((Id) userListObj.get('ContactOrLeadSFId'));
                }
                for (Id eachId : whoIdSet) {
                    if(Schema.SObjectType.Task.isAccessible() && Schema.SObjectType.Task.isCreateable() &&
                            Schema.SObjectType.Task.fields.WhoId.isAccessible() && Schema.SObjectType.Task.fields.WhoId.isCreateable()){
                        Task taskNewObj = new Task();
                        taskNewObj = taskObj.clone(false, true, false, false);
                        taskNewObj.whoid = eachId;
                        taskList.add(taskNewObj);
                    }
                }
            }
            if (!taskList.isEmpty() && Schema.sObjectType.Task.isAccessible() && Schema.sObjectType.Task.isCreateable()) {
                insert taskList;
            }
        }
    }

    @AuraEnabled
    public static list<TaskFieldsWrapper> getTaskFieldsWrapper() {
        Map<String, Schema.SObjectField> mfields = Schema.getGlobalDescribe()
                .get('Task')
                .getDescribe()
                .fields.getMap();
        List<TaskFieldsWrapper> wrapperList = new List<TaskFieldsWrapper>();
        for (String str : mfields.keySet()) {
            // if(!(str.toLowerCase().contains('recurrence'))){
            TaskFieldsWrapper wrap = new TaskFieldsWrapper();
            String fieldApiName = str.toLowerCase();
            wrap.apiName = fieldApiName;
            wrap.userId = UserInfo.getUserId();
            wrap.userName = UserInfo.getName();
            wrap.isRecurrence = false;
            if (mfields.get(str).getDescribe().isNillable() == false) {
                wrap.isRequired = true;
            } else {
                wrap.isRequired = false;
            }
            wrap.fieldLabel = mfields.get(str).getDescribe().getLabel();
            if (wrap.fieldLabel.contains(' ID')) {
                wrap.fieldLabel = wrap.fieldLabel.remove(' ID');
            }
            String myType = mfields.get(str).getDescribe().getType() + '';
            wrap.fieldType = myType.trim();
            if (wrap.fieldType == 'PICKLIST') {
                wrap.relationshipName = '';
                wrap.isPicklist = true;
                wrap.hasRelation = false;
                wrap.isString = false;
            } else if (wrap.fieldType == 'REFERENCE') {
                wrap.relationshipName = mfields.get(str)
                        .getDescribe()
                        .getRelationshipName();
                wrap.hasRelation = true;
                wrap.isPicklist = false;
                wrap.isString = false;
            } else {
                wrap.relationshipName = '';
                wrap.hasRelation = false;
                wrap.isPicklist = false;
                wrap.isString = true;
            }
            if (str.toLowerCase().contains('recurrence')) {
                if (str.toLowerCase().contains('isrecurrence')) {
                    wrap.isRecurrence = true;
                    wrap.isString = false;
                    wrapperList.add(wrap);
                }
            } else {
                wrapperList.add(wrap);
            }
            // }
        }
        return wrapperList;
    }

    @AuraEnabled
    public static Map<String, list<PickListInfo>> getFieldVsPicklistMap() {
        Map<String, list<PickListInfo>> fieldVsPicklistMap = new Map<String, list<PickListInfo>>();
        Map<String, Schema.SObjectField> mfields = Schema.getGlobalDescribe()
                .get('Task')
                .getDescribe()
                .fields.getMap();
        for (String str : mfields.keySet()) {
            String myType = mfields.get(str).getDescribe().getType() + '';
            myType = myType.trim();
            String fieldApiName = str.toLowerCase();
            if (myType == 'PICKLIST') {
                list<Schema.PicklistEntry> pickListEntryList = mfields.get(str)
                        .getDescribe()
                        .getPicklistValues();
                for (Schema.PicklistEntry pe : pickListEntryList) {
                    PickListInfo pickInfo = new PickListInfo();
                    pickInfo.label = pe.getLabel();
                    pickInfo.value = pe.getValue();
                    if (fieldVsPicklistMap.containskey(fieldApiName)) {
                        fieldVsPicklistMap.get(fieldApiName).add(pickInfo);
                    } else {
                        fieldVsPicklistMap.put(
                                fieldApiName,
                                new List<PickListInfo>{ pickInfo }
                        );
                    }
                }
            } else if (str == 'subject') {
                for (
                        Schema.PicklistEntry pe : mfields.get(str)
                        .getDescribe()
                        .getPicklistValues()
                ) {
                    PickListInfo pickInfo = new PickListInfo();
                    pickInfo.label = pe.getLabel();
                    pickInfo.value = pe.getValue();
                    if (fieldVsPicklistMap.containskey(str)) {
                        fieldVsPicklistMap.get(fieldApiName).add(pickInfo);
                    } else {
                        fieldVsPicklistMap.put(
                                fieldApiName,
                                new List<PickListInfo>{ pickInfo }
                        );
                    }
                }
            }
        }
        return fieldVsPicklistMap;
    }

    @AuraEnabled
    public static Map<String, String> getReferenceObjectstAPIvsLabelMap() {
        Map<String, String> referenceObjectstAPIvsLabelMap = new Map<String, String>();
        Map<String, Schema.SObjectField> mfields = Schema.getGlobalDescribe()
                .get('Task')
                .getDescribe()
                .fields.getMap();
        for (String str : mfields.keySet()) {
            String myType = mfields.get(str).getDescribe().getType() + '';
            myType = myType.trim();
            if (myType == 'REFERENCE') {
                for (
                        Schema.SObjectType reference : mfields.get(str)
                        .getDescribe()
                        .getReferenceTo()
                ) {
                    referenceObjectstAPIvsLabelMap.put(
                            reference.getDescribe().getName(),
                            reference.getDescribe().getLabel()
                    );
                }
            }
        }
        return referenceObjectstAPIvsLabelMap;
    }

    public static Map<String, String> getStandardObjectIconsMap() {
        Map<String, String> standardObjectNameVsIconMap = new Map<String, String>();
        Map<String, String> referenceObjectstAPIvsLabelMap = getReferenceObjectstAPIvsLabelMap();
        for (String sObjectName : referenceObjectstAPIvsLabelMap.keySet()) {
            String iconName = '';
            if (!sObjectName.contains('__c')) {
                if (sObjectName == 'RecordType') {
                    iconName = 'standard:record';
                } else if (sObjectName == 'Asset') {
                    iconName = 'standard:asset_object';
                } else if (sObjectName == 'AssetRelationship') {
                    iconName = 'standard:asset_relationship';
                } else if (sObjectName == 'AssignedResource') {
                    iconName = 'standard:assigned_resource';
                } else if (sObjectName == 'CommSubscriptionConsent') {
                    iconName = 'standard:assigned_resource';
                } else if (sObjectName == 'ContactRequest') {
                    iconName = 'standard:contact_request';
                } else if (sObjectName == 'CreditMemo') {
                    iconName = 'standard:maintenance_plan';
                } else if (sObjectName == 'Goal') {
                    iconName = 'standard:goals';
                } else if (sObjectName == 'Image') {
                    iconName = 'standard:maintenance_plan';
                } else if (sObjectName == 'Invoice') {
                    iconName = 'standard:maintenance_plan';
                } else if (sObjectName == 'LegalEntity') {
                    iconName = 'standard:shift';
                } else if (sObjectName == 'ListEmail') {
                    iconName = 'standard:list_email';
                } else if (sObjectName == 'Metric') {
                    iconName = 'standard:metrics';
                } else if (sObjectName == 'Order') {
                    iconName = 'standard:orders';
                } else if (sObjectName == 'PartyConsent') {
                    iconName = 'standard:employee_job';
                } else if (sObjectName == 'ProcessException') {
                    iconName = 'standard:process_exception';
                } else if (sObjectName == 'Product2') {
                    iconName = 'standard:product';
                } else if (sObjectName == 'ResourceAbsence') {
                    iconName = 'standard:resource_absence';
                } else if (sObjectName == 'ReturnOrder') {
                    iconName = 'standard:return_order';
                } else if (sObjectName == 'ReturnOrderLineItem') {
                    iconName = 'standard:return_order_line_item';
                } else if (sObjectName == 'ServiceAppointment') {
                    iconName = 'standard:service_appointment';
                } else if (sObjectName == 'ServiceResource') {
                    iconName = 'standard:service_resource';
                } else if (sObjectName == 'WorkCoaching') {
                    iconName = 'standard:coaching';
                } else if (sObjectName == 'Group') {
                    iconName = 'standard:groups';
                } else if (sObjectName == 'Campaign') {
                    iconName = 'standard:asset_object';
                } else if (sObjectName == 'Quote') {
                    iconName = 'standard:quotes';
                } else {
                    iconName = 'standard:' + sObjectName.toLowerCase();
                }
                standardObjectNameVsIconMap.put(sObjectName, iconName);
            }
        }
        return standardObjectNameVsIconMap;
    }
    @AuraEnabled
    public static Map<String, String> getCustomObjectIconsMap() {
        Map<String, String> customObjectstAPIvsIconMap = new Map<String, String>();
        List<Schema.DescribeTabSetResult> tabSetDesc = Schema.describeTabs();
        List<Schema.DescribeTabResult> tabDesc = new List<Schema.DescribeTabResult>();
        List<Schema.DescribeIconResult> iconDesc = new List<Schema.DescribeIconResult>();
        for (Schema.DescribeTabSetResult tsr : tabSetDesc) {
            tabDesc.addAll(tsr.getTabs());
        }
        for (Schema.DescribeTabResult tr : tabDesc) {
            if (tr.isCustom() == true) {
                for (Schema.DescribeIconResult ir : tr.getIcons()) {
                    String iconName = '';
                    if (ir.getContentType() == 'image/svg+xml') {
                        iconName =
                                'custom:' +
                                ir.getUrl()
                                        .substringBetween('custom/', '.svg')
                                        .substringBefore('_');
                        customObjectstAPIvsIconMap.put(tr.getSobjectName(), iconName);
                    }
                }
            }
        }
        if (Test.isRunningTest()) {
            Map<String, String> testMap = new Map<String, String>();
            testMap.put('Custom__c', 'custom:custom21');
            return testMap;
        }
        return customObjectstAPIvsIconMap;
    }

    @AuraEnabled
    public static Map<String, String> getReferenceObjectstAPIvsIconMap() {
        Map<String, String> referenceObjectstAPIvsIconMap = new Map<String, String>();
        Map<String, String> referenceObjectstAPIvsLabelMap = getReferenceObjectstAPIvsLabelMap();
        Map<String, String> standardObjectNameVsIconMap = getStandardObjectIconsMap();
        Map<String, String> customObjectstAPIvsIconMap = getCustomObjectIconsMap();
        for (String sObjectName : referenceObjectstAPIvsLabelMap.keySet()) {
            String iconName = '';
            if (sObjectName.contains('__c')) {
                if (customObjectstAPIvsIconMap.containsKey(sObjectName)) {
                    iconName = customObjectstAPIvsIconMap.get(sObjectName);
                }
            } else {
                if (standardObjectNameVsIconMap.containsKey(sObjectName)) {
                    iconName = standardObjectNameVsIconMap.get(sObjectName);
                }
            }
            if (iconName == '') {
                iconName = 'standard:empty';
            }
            referenceObjectstAPIvsIconMap.put(sObjectName, iconName);
        }
        return referenceObjectstAPIvsIconMap;
    }
    @AuraEnabled
    public static Map<String, list<String>> getfieldVsReferenceObjects() {
        Map<String, list<String>> fieldVsReferenceObjects = new Map<String, list<String>>();
        Map<String, Schema.SObjectField> mfields = Schema.getGlobalDescribe()
                .get('Task')
                .getDescribe()
                .fields.getMap();
        for (String str : mfields.keySet()) {
            String myType = mfields.get(str).getDescribe().getType() + '';
            myType = myType.trim();
            if (myType == 'REFERENCE') {
                for (
                        Schema.SObjectType reference : mfields.get(str)
                        .getDescribe()
                        .getReferenceTo()
                ) {
                    if (fieldVsReferenceObjects.containskey(str)) {
                        fieldVsReferenceObjects.get(str)
                                .add(reference.getDescribe().getName());
                    } else {
                        fieldVsReferenceObjects.put(
                                str,
                                new List<String>{ reference.getDescribe().getName() }
                        );
                    }
                }
            }
        }
        return fieldVsReferenceObjects;
    }

    public static String restGet(String endPoint) {
        try {
            Http h = new Http();
            HttpRequest hr = new HttpRequest();
            hr.setTimeout(60000);
            hr.setEndpoint(endPoint);
            hr.setMethod('GET');
            HttpResponse r = h.send(hr);
            return r.getBody();
        } catch (Exception ex) {
            system.debug(LoggingLevel.ERROR,'Exception in tooling API Call:' + ex.getMessage());
            return ex.getMessage();
        }
    }

    @AuraEnabled
    public static Map<String, String> getLayoutNameForObject(
            String recordTypeId
            ) {
        String profileId = UserInfo.getProfileId();
        String query = 'callout:ToolingRest' + '/?q=Select+Layout.Name,Layout.NamespacePrefix+from+ProfileLayout+where+TableEnumOrId=\'Task\'';
        if (String.isNotEmpty(ProfileId)) {
            query += '+and+ProfileId=\'' + ProfileId + '\'';
        }
        if (String.isNotEmpty(RecordTypeId)) {
            query += '+and+RecordTypeId=\'' + RecordTypeId + '\'';
        }
        String body = restGet(query);
        if (string.isNotBlank(body)) {
            TelosTouchSF.LayoutRecord data = TelosTouchSF.LayoutRecord.parse(body);
            Map<String, String> layouts = new Map<String, String>();
            for (TelosTouchSF.LayoutRecord.Record record : data.records) {
                if (!layouts.containsKey('Name')) {
                    layouts.put('Name', string.valueOf(record.Layout.Name));
                    layouts.put(
                            'NamespacePrefix',
                            string.valueOf(record.Layout.NamespacePrefix)
                    );
                }
            }
            return layouts;
        }
        return null;
    }
    @AuraEnabled
    public static Map<String, list<FieldInfo>> getSectionNameVsFieldsMap(
            String recordTypeId
            ) {
        try {
            Map<String, String> allLayouts = getLayoutNameForObject(recordTypeId);
            String namespacePrefix = null;
            String layoutName = '';
            if (
                    allLayouts.containsKey('NamespacePrefix') &&
                            allLayouts.get('NamespacePrefix') != null
            ) {
                layoutName =
                        'Task-' +
                        allLayouts.get('NamespacePrefix') +
                        '__' +
                        allLayouts.get('Name');
                namespacePrefix = allLayouts.get('NamespacePrefix');
            } else if (
                    allLayouts.containsKey('NamespacePrefix') &&
                            allLayouts.get('NamespacePrefix') == null
            ) {
                layoutName = 'Task-' + allLayouts.get('Name');
            }
            List<String> taskLayoutNameList = new List<String>{ layoutName };
            Map<String, list<FieldInfo>> sectionNameVsFieldInfoMap = new Map<String, list<FieldInfo>>();
            List<Metadata.Metadata> layouts = Metadata.Operations.retrieve(
                    Metadata.MetadataType.Layout,
                    taskLayoutNameList
            );
            Map<String, list<Metadata.LayoutColumn>> sectionVsColumnsMap = new Map<String, list<Metadata.LayoutColumn>>();
            Map<String, list<Metadata.LayoutItem>> sectionVsLayoutItemsMap = new Map<String, list<Metadata.LayoutItem>>();

            Metadata.Layout layoutMd = (Metadata.Layout) layouts.get(0);
            for (Metadata.LayoutSection section : layoutMd.layoutSections) {
                if (section.label != 'System Information') {
                    sectionVsColumnsMap.put(section.label, section.layoutColumns);
                }
            }
            for (Metadata.LayoutSection section : layoutMd.layoutSections) {
                if (section.label != 'System Information') {
                    list<Metadata.LayoutColumn> columnList = sectionVsColumnsMap.get(
                            section.label
                    );
                    for (Metadata.LayoutColumn column : columnList) {
                        if (column.layoutItems != null) {
                            if (sectionVsLayoutItemsMap.containsKey(section.label)) {
                                sectionVsLayoutItemsMap.get(section.label)
                                        .addAll(column.layoutItems);
                            } else {
                                sectionVsLayoutItemsMap.put(
                                        section.label,
                                        new List<Metadata.LayoutItem>(column.layoutItems)
                                );
                            }
                        }
                    }
                }
            }
            for (String section : sectionVsLayoutItemsMap.keySet()) {
                if (sectionVsLayoutItemsMap.containsKey(section)) {
                    list<Metadata.LayoutItem> layoutItems = sectionVsLayoutItemsMap.get(
                            section
                    );
                    for (Metadata.LayoutItem item : layoutItems) {
                        String fieldApiName = item.field.toLowerCase();
                        FieldInfo fieldInfoObj = new FieldInfo();
                        fieldInfoObj.field = fieldApiName;
                        fieldInfoObj.isRequired = false;
                        if (string.valueof(item.behavior) == 'Required') {
                            fieldInfoObj.isRequired = true;
                        }
                        if (sectionNameVsFieldInfoMap.containsKey(section)) {
                            sectionNameVsFieldInfoMap.get(section).add(fieldInfoObj);
                        } else {
                            sectionNameVsFieldInfoMap.put(
                                    section,
                                    new List<FieldInfo>{ fieldInfoObj }
                            );
                        }
                    }
                }
            }
            return sectionNameVsFieldInfoMap;
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR,'Exception ' + ex.getMessage());
            return null;
        }
    }

    public class TaskFieldsWrapper {
        @AuraEnabled
        public String fieldLabel { get; set; }
        @AuraEnabled
        public String apiName { get; set; }
        @AuraEnabled
        public String fieldType { get; set; }
        @AuraEnabled
        public String userName { get; set; }
        @AuraEnabled
        public String userId { get; set; }
        @AuraEnabled
        public Boolean hasRelation { get; set; }
        @AuraEnabled
        public Boolean isPicklist { get; set; }
        @AuraEnabled
        public Boolean isString { get; set; }
        @AuraEnabled
        public Boolean isRequired { get; set; }
        @AuraEnabled
        public Boolean isRecurrence { get; set; }
        @AuraEnabled
        public String relationshipName { get; set; }
    }

    public class FieldInfo {
        @AuraEnabled
        public Boolean isRequired { get; set; }
        @AuraEnabled
        public String field { get; set; }
    }
    public class PickListInfo {
        @AuraEnabled
        public String label { get; set; }
        @AuraEnabled
        public String value { get; set; }
    }
}