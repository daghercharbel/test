/**
* @author Cloud Analogy
* @date 26/08/2021.
* @description SessionIDController....
*/
public class SessionIDController {
    /**
* @author Cloud Analogy
* @date 26/08/2021.
* @description getSessionId ....
* @param visualforcePage ......
@return String ...
     */
    public static String getSessionId(PageReference visualforcePage){
        String content;
        if(Test.isRunningTest()){
            content = 'Start_Of_Session_IdTESTEnd_Of_Session_Id';
        }else{
            content = visualforcePage.getContent().toString();
        }
        Integer s = content.indexOf('Start_Of_Session_Id') + 'Start_Of_Session_Id'.length(),
                e = content.indexOf('End_Of_Session_Id');
        return content.substring(s, e);
    }
}