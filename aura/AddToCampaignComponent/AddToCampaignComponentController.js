({
    doInit : function(c, e, h) {
        h.doInit_helper(c,e,h);
    },
    showAddCampaignMemberDetails: function(c,e,h){
        if(!$A.util.isEmpty(c.get("v.campaignObj"))){
            c.set("v.customErrorMessage",'');
            c.set("v.isNewOrExistCampaign",false);
            c.set("v.isExistCampaign",true);
        }else{
            c.set("v.customErrorMessage",$A.get("$Label.c.Existing_Campaign_Error_Text"));
        }  
    },
    closeModal: function(c,e,h){
        $A.get("e.force:closeQuickAction").fire();  
    },
    saveCampaign : function(c,e,h){
        h.saveCampaign_helper(c,e,h);
    }
})