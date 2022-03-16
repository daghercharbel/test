({
	toggleAcitivity : function(component, event, helper) {
        $A.util.toggleClass(component.find('expId'), 'slds-is-open');
    },
    doInit : function(c, e, h) {
        var type = c.get("v.timelineRecord").type;
        if(type === 'task' || type === 'request'){
            $A.util.addClass(c.find('expId'), 'slds-timeline__item_task');
        }else if(type === 'touchpoint'){
            $A.util.addClass(c.find('expId'), 'slds-timeline__item_campaign');
        }else if(type === 'Answer'){
            $A.util.addClass(c.find('expId'), 'slds-timeline__item_answer');
        }else if(type === 'attachment'){
            $A.util.addClass(c.find('expId'), 'slds-timeline__item_attachment');
        }
    }
})