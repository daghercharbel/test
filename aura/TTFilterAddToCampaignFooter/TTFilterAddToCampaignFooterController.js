({
    CloseModal: function(c, e, h) {
        try{
            var myEvent = $A.get("e.c:ModalCloseEvent");
            myEvent.setParams({ CloseModal: true });
            myEvent.fire();
        }catch(e){
            //console.error(e);
        }
    },
    saveCampaign: function(c,e,h){
        var myEvent = $A.get("e.c:TT_AddToCampMobile_Evt");
        myEvent.setParams({ addToExistingCampaign: true });
        myEvent.fire();
    }
})