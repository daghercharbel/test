/*
 * Created by swapn on 01-07-2021.
 */
/**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
*/
public class UpdateCustomMetadataQueueable implements Queueable{
	public TelosTouchSF__TT_Admin_Credentials__mdt adminCredentials;
	public TelosTouchSF__TT_Authentication_Credential__mdt authenticationCredential;
    /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
* @param adminCredentials ....
*/
	public UpdateCustomMetadataQueueable(TelosTouchSF__TT_Admin_Credentials__mdt adminCredentials, TelosTouchSF__TT_Authentication_Credential__mdt authenticationCredential){
		this.adminCredentials = adminCredentials;
		this.authenticationCredential = authenticationCredential;
	}
        /**
* @author Cloud Analogy
* @date 02/08/2021
* @description ........
* @param qc ....
*/
	public void execute(QueueableContext qc){
		TelosTouchUtility.updateCustomMetadata(new TelosTouchSF.TelosTouchUtility.AdminCredentialsWrapper(adminCredentials, authenticationCredential));
	}
}