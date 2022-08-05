({
    //call the Controller function <GetImagesLinksKnowledgebase> and get a map of the custom fields values of 
    // the custom metadata : <TelosTouchSF__Knowledge_base_image__mdt>
    GetImagesLinksKnowledgebaseHelper : function(component, event, helper) {
        try {
            var action = component.get('c.GetImagesLinksKnowledgebase');
            
            action.setCallback(this, function(response){
                var state = response.getState();              
                if(state == "SUCCESS"){
                    var result = response.getReturnValue();
                    component.set('v.listimages',result);
                }
            });
            $A.enqueueAction(action);
        } catch (exp) {
            //console.log(ex);
        }
    },
})