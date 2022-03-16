({
    onfocus : function(component,event,helper){
        $A.util.addClass(component.find("mySpinner"), "slds-show");
        var forOpen = component.find("searchRes");
        $A.util.addClass(forOpen, 'slds-is-open');
        $A.util.removeClass(forOpen, 'slds-is-close');
    },
    onblur : function(component,event,helper){    
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    },
    selectedEvent : function(c, e, h) {
        var questionList = c.get("v.questionList");
        var count = 0;
        var ansewerList = [];
        for(var obj of questionList){
            if(obj.isSelected == true){
                if(count == 0){
                    c.set("v.values", obj.question);
                }
                count ++;
                ansewerList.push(obj.question);
            }
        }
        if(count == 0){
            c.set("v.values",'');
        }else if(count != 1){
            c.set("v.values", 'Selected ('+count+')');
        }
        c.set("v.answerList", ansewerList);
    },
    fielterEvent : function(c, e, h) {
        c.set("v.fielterDetailsChanges",'EventFire');
    },
})