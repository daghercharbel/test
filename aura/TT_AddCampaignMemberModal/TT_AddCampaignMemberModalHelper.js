({
    showToast : function(type, message) {
        //console.log('in helper');
        //console.log('message >>'+message);
        //console.log('type >>'+type);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            message: message,
            type: type,
            duration: '4000',
            mode: 'dismissible',
        });
        toastEvent.fire();
    }
})