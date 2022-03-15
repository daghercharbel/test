/*
 * @author Cloud Analogy
 * @date 26/08/2021.
 * @description ContactTriggerForSyncing ...
 */

public with sharing class FilterLookUpParentDependentCmpCtrl {
   @AuraEnabled(cacheable=true)
       /**
 * @author Cloud Analogy
 * @date 02/08/2021
 *@description searchDB .....
 * @param objectName ......
 * @param fld_API_Text ......
 * @param fld_API_Val ......
  * @param lim ......
 * @param fld_API_Search ......
 * @param searchText ......
 * @param parentFiledName ......
 * @param parentFiledId ......
 * @param searchTextStartsWithFilter ......
@return string ...
        */
    public static String searchDB(String objectName, String fld_API_Text, String fld_API_Val,
            Integer lim, String fld_API_Search, String searchText, String parentFiledName, String parentFiledId, String searchTextStartsWithFilter) {
        try {
            String query;
            if (searchTextStartsWithFilter != 'none') {
                query = getFirstFilterRecords(objectName, fld_API_Text, fld_API_Val, lim, fld_API_Search, searchText, parentFiledName, parentFiledId, searchTextStartsWithFilter) ;
            } else if (parentFiledName != null && parentFiledId != null && parentFiledName.contains(',') && parentFiledId.contains(',') && searchText == null) {
                query = 'SELECT ' + String.escapeSingleQuotes(fld_API_Text) + ' ,' + String.escapeSingleQuotes(fld_API_Val) +
                        ' FROM ' + String.escapeSingleQuotes(objectName) +
                        ' WHERE ';
                List<String> parentFiledNameList = parentFiledName.split(',');
                List<String> parentFiledIdList = parentFiledId.split(',');
                Integer index = 1;
                for (Integer i = 0; i < parentFiledNameList.size(); i++) {
                    if (index == parentFiledNameList.size()) {
                        query += String.escapeSingleQuotes(parentFiledNameList[i]);
                        query += ' = \'' + String.escapeSingleQuotes(parentFiledIdList[i]) + '\'';
                    } else {
                        query += String.escapeSingleQuotes(parentFiledNameList[i]);
                        query += ' = \'' + String.escapeSingleQuotes(parentFiledIdList[i]) + '\'' + ' AND ';
                    }
                    index++;
                }
                query += ' order by LastModifiedDate desc LIMIT ' + lim;

            } else if (parentFiledName != null && parentFiledId != null && parentFiledName.contains(',') && parentFiledId.contains(',') && searchText != null) {
                searchText = '\'%' + String.escapeSingleQuotes(searchText.trim()) + '%\'';
                query = 'SELECT ' + String.escapeSingleQuotes(fld_API_Text) + ' ,' + String.escapeSingleQuotes(fld_API_Val) +
                        ' FROM ' + String.escapeSingleQuotes(objectName) +
                        ' WHERE ' + String.escapeSingleQuotes(fld_API_Search) + ' LIKE ' + String.escapeSingleQuotes(searchText) + ' AND ';
                List<String> parentFiledNameList = parentFiledName.split(',');
                List<String> parentFiledIdList = parentFiledId.split(',');
                Integer index = 1;
                for (Integer i = 0; i < parentFiledNameList.size(); i++) {
                    if (index == parentFiledNameList.size()) {
                        query += String.escapeSingleQuotes(parentFiledNameList[i]);
                        query += ' = \'' + String.escapeSingleQuotes(parentFiledIdList[i]) + '\'';
                    } else {
                        query += String.escapeSingleQuotes(parentFiledNameList[i]);
                        query += ' = \'' + String.escapeSingleQuotes(parentFiledIdList[i]) + '\'' + ' AND ';
                    }
                    index++;
                }
                query += ' order by LastModifiedDate desc LIMIT ' + lim;
            } else if (parentFiledName != null && parentFiledId != null && searchText != null) {
                searchText = '\'%' + String.escapeSingleQuotes(searchText.trim()) + '%\'';
                query = 'SELECT ' + String.escapeSingleQuotes(fld_API_Text) + ' ,' + fld_API_Val +
                        ' FROM ' + String.escapeSingleQuotes(objectName) +
                        ' WHERE ' + String.escapeSingleQuotes(fld_API_Search) + ' LIKE ' + String.escapeSingleQuotes(searchText) + ' AND ' + String.escapeSingleQuotes(parentFiledName) +
                        ' = \'' + String.escapeSingleQuotes(parentFiledId) + '\'' +
                        ' LIMIT ' + lim;
            } else if (parentFiledName != null && parentFiledId != null && searchText == null) {
                query = 'SELECT ' + String.escapeSingleQuotes(fld_API_Text) + ' ,' + String.escapeSingleQuotes(fld_API_Val) +
                        ' FROM ' + String.escapeSingleQuotes(objectName) +
                        ' WHERE ' + String.escapeSingleQuotes(parentFiledName) +
                        ' = \'' + String.escapeSingleQuotes(parentFiledId) + '\'' + ' order by LastModifiedDate desc' +
                        ' LIMIT ' + lim;
            }else if (searchText == null) {
                query = 'SELECT ' + String.escapeSingleQuotes(fld_API_Text) + ' ,' + String.escapeSingleQuotes(fld_API_Val) +
                        ' FROM ' + String.escapeSingleQuotes(objectName) ;
                if(objectName == 'User'){
                    query += ' Where Id IN (SELECT UserId FROM UserLogin WHERE IsFrozen = false) AND isActive = true';
                }
                query += + ' order by LastModifiedDate desc' +
                        ' LIMIT ' + lim ;
            }else {
                searchText = '\'%' + String.escapeSingleQuotes(searchText.trim()) + '%\'';
                query = 'SELECT ' + String.escapeSingleQuotes(fld_API_Text) + ' ,' + String.escapeSingleQuotes(fld_API_Val) +
                        ' FROM ' + String.escapeSingleQuotes(objectName) +
                        ' WHERE ' ;
                if(objectName == 'User'){
                    query += ' Id IN (SELECT UserId FROM UserLogin WHERE IsFrozen = false) AND isActive = true AND ';
                }
                query+= + String.escapeSingleQuotes(fld_API_Search) + ' LIKE ' + String.escapeSingleQuotes(searchText) +
                        ' LIMIT ' + lim;
            }
            List<sObject> sobjList = Database.query(String.escapeSingleQuotes(query).replace('\\',''));
            List<ResultWrapper> lstRet = new List<ResultWrapper>();
            for (SObject s : sobjList) {
                ResultWrapper obj = new ResultWrapper();
                obj.objName = objectName;
                if (fld_API_Text != null && fld_API_Text.contains(',')) {
                    obj.text = String.valueOf(s.get(fld_API_Text.split(',')[0])) ;
                    if (String.valueOf(s.get(fld_API_Text.split(',')[1])) != null) {
                        obj.text += ' (' + String.valueOf(s.get(fld_API_Text.split(',')[1])) + ')' ;
                    }
                } else {
                    obj.text = String.valueOf(s.get(fld_API_Text)) ;
                }
                obj.Id = String.valueOf(s.get(fld_API_Val)) ;
                lstRet.add(obj);
            }
            return JSON.serialize(lstRet) ;
        } catch (Exception exp) {
            System.debug(LoggingLevel.WARN, 'Exception Message :: ' + exp.getMessage() + ' At line Number :: ' + exp.getLineNumber());
        }
        return null;
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
*@description searchDB .....
* @param objectName ......
* @param fld_API_Text ......
* @param fld_API_Val ......
* @param lim ......
* @param fld_API_Search ......
* @param searchText ......
* @param parentFiledName ......
* @param parentFiledId ......
* @param searchTextStartsWithFilter ......
@return string ...
     */
    public static String getFirstFilterRecords(String objectName, String fld_API_Text, String fld_API_Val,
            Integer lim, String fld_API_Search, String searchText, String parentFiledName, String parentFiledId, String searchTextStartsWithFilter) {

        searchTextStartsWithFilter = searchTextStartsWithFilter.substring(0, 2);

        String startWithString;
        if (searchTextStartsWithFilter == '01' || searchTextStartsWithFilter == '02' || searchTextStartsWithFilter == '03'
                || searchTextStartsWithFilter == '04' || searchTextStartsWithFilter == '05' || searchTextStartsWithFilter == '07'
                || searchTextStartsWithFilter == '08') {
            startWithString = 'R' + searchTextStartsWithFilter;
        } else if (searchTextStartsWithFilter == '00') {
            startWithString = 'R10';
        }
        String query ;
        if (startWithString != null) {

            if (searchText != null) {
                startWithString = '\'' + String.escapeSingleQuotes(startWithString.trim()) + '%\'';
                searchText = '\'%' + String.escapeSingleQuotes(searchText.trim()) + '%\'';
                query = 'SELECT ' + String.escapeSingleQuotes(fld_API_Text) + ' ,' + String.escapeSingleQuotes(fld_API_Val) +
                        ' FROM ' + String.escapeSingleQuotes(objectName) +
                        ' WHERE ' + String.escapeSingleQuotes(fld_API_Text) + ' LIKE ' + String.escapeSingleQuotes(searchText) + ' AND '+ String.escapeSingleQuotes(fld_API_Text) + ' LIKE ' + String.escapeSingleQuotes(startWithString) +
                        ' LIMIT ' + lim;
            } else {
                startWithString = '\'' + String.escapeSingleQuotes(startWithString.trim()) + '%\'';
                query = 'SELECT ' + String.escapeSingleQuotes(fld_API_Text) + ' ,' + String.escapeSingleQuotes(fld_API_Val) +
                        ' FROM ' + String.escapeSingleQuotes(objectName) +
                        ' WHERE ' + String.escapeSingleQuotes(fld_API_Text) + ' LIKE ' + String.escapeSingleQuotes(startWithString) + ' LIMIT ' + lim;
            }
        } else {
            if (searchText != null) {
                searchText = '\'%' + String.escapeSingleQuotes(searchText.trim()) + '%\'';
                query = 'SELECT ' + String.escapeSingleQuotes(fld_API_Text) + ' ,' + String.escapeSingleQuotes(fld_API_Val) +
                        ' FROM ' + String.escapeSingleQuotes(objectName) +
                        ' WHERE ' + String.escapeSingleQuotes(fld_API_Search) + ' LIKE ' + String.escapeSingleQuotes(searchText) +
                        ' LIMIT ' + lim;
            } else {
                query = 'SELECT ' + String.escapeSingleQuotes(fld_API_Text) + ' ,' + String.escapeSingleQuotes(fld_API_Val) +
                        ' FROM ' + String.escapeSingleQuotes(objectName) + ' order by LastModifiedDate desc' +
                        ' LIMIT ' + lim;
            }
        }
        return query;
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ResultWrapper is used to get objName, text,Id..
*/
    public class ResultWrapper {
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        public String objName { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        public String text { get; set; }
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ......
*/
        public String Id { get; set; }
    }
}