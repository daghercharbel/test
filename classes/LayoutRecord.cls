/**
* @author Cloud Analogy
* @date 02/08/2021
* @description LayoutRecord ..........
*/
public with sharing class LayoutRecord {
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ..........
*/
    public List<Record> records {get;set;}
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description Layout ..........
*/
    public class Layout {
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description name .........
*/
        public String Name {get;set;}
        /**
  * @author Cloud Analogy
  * @date 02/08/2021
  * @description NamespacePrefix .........
  */
        public String NamespacePrefix {get;set;}
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description Record ..........
*/
    public class Record {
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description Layout ........
*/
        public Layout Layout {get;set;} 
    }
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description parse ..........
* @param json ......
@return LayoutRecord ..
     */
    public static LayoutRecord parse(String json){
        return (LayoutRecord) System.JSON.deserialize(json, LayoutRecord.class);
    }
}