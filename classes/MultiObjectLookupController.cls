/**
* @author Cloud Analogy
* @date 02/08/2021
* @description MultiObjectLookupController class .
*/
public with sharing class MultiObjectLookupController {
    @AuraEnabled
        /**
	 * @author Cloud Analogy
	 * @date 02/08/2021
	 * @description fetchRecords method fetch all the related data to any object.
	 * @param objectName ......
	 * @param filterField ......
	 * @param searchString ......
	 @return List<RecordsData>
	 */
    public static List<RecordsData> fetchRecords( String objectName, String filterField, String searchString ) {
    	List<RecordsData> recordsDataList = new List<RecordsData>();
        try {
    		String query = 'SELECT Id, ' + String.escapeSingleQuotes(filterField)+
                        ' FROM '+String.escapeSingleQuotes(objectName)+
                        ' WHERE '+String.escapeSingleQuotes(filterField)+' LIKE ' + '\'' + String.escapeSingleQuotes(searchString.trim()) + '%\'' + ' LIMIT 50000';

            for(SObject s : Database.query(query)){
                recordsDataList.add( new RecordsData((String)s.get(filterField), (String)s.get('id')) );
            } 
		} catch(Exception err) {
            System.debug(LoggingLevel.ERROR, err.getMessage());
		}
        return recordsDataList;
    }
    /**
	* @author Cloud Analogy
	* @date 02/08/2021
	* @description RecordsData wrapper class .
	*/
    public class RecordsData{
        @AuraEnabled
            /**
	  * @author Cloud Analogy
	  * @date 02/08/2021
	  * @description..
	  */
        public String label;
        @AuraEnabled
            /**
	  * @author Cloud Analogy
	  * @date 02/08/2021
	  * @description..
	  */
        public String value;
        /**
  * @author Cloud Analogy
  * @date 02/08/2021
  * @description constructor of RecordData wrapper class .
  	 * @param label ......
	 * @param value ......
*/
        public RecordsData(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
}