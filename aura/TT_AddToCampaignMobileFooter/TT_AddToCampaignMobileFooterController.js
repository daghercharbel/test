({
    onAddButton : function(c, e, h){
        try{
            var myEvent = $A.get("e.c:TT_AddToCampMobile_Evt");
            myEvent.setParams({"isCampaign" : true });
            myEvent.setParams({"isCreateTask" : false });
            myEvent.fire();
        }catch(err){
        }
    }
})