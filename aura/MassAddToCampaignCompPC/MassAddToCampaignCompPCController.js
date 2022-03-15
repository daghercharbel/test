({
    doInit : function(c, e, h) {
        //console.log('per>>'+c.get("v.isPersonAccount"));
        if(c.get("v.isPersonAccount") == 'true'){
            //console.log('perll');
            if(c.get("v.selectedRecordIds").length >2){
                h.doInit_helper(c,e,h);
            }else{
                h.showToast_Helper(c,'error','Select at least one record and try again.');   
                window.setTimeout(
                    $A.getCallback(function() {
                        window.open(window.location.origin+'/lightning/o/Account/home', '_self');
                    }), 2000);
            }
            
        }else{
            //console.log('no');
            h.showToast_Helper(c,'error','Person Account is not enabled.');
            window.setTimeout(
                $A.getCallback(function() {
                    window.open(window.location.origin+'/lightning/o/Account/home', '_self');
                }), 2000);
        }
        
    },
    showAddCampaignMemberDetails: function(c,e,h){
        //console.log(c.get("v.campaignObj"));
        if(!$A.util.isEmpty(c.get("v.campaignObj"))){
            h.SaveContactIntoCampaign_Helper(c,e,h,c.get("v.campaignObj"));
        }else{
            c.set("v.customErrorMessage",'Enter an existing campaign name, or create a new campaign.');
        }  
    },
    closeModal: function(c,e,h){
        c.set("v.isNewOrExistCampaign",false);
        window.setTimeout(
                            $A.getCallback(function() {
                                window.open(window.location.origin+'/lightning/o/Account/home', '_self');
                            }), 2000);
    },
    closeChildModal: function(c,e,h){
        c.set("v.childlookup",false);
        c.set("v.isNewOrExistCampaign",false);
        window.setTimeout(
                            $A.getCallback(function() {
                                window.open(window.location.origin+'/lightning/o/Account/home', '_self');
                            }), 2000);
    },
    saveCampaign : function(c,e,h){
        h.saveCampaign_helper(c,e,h);
    }
})