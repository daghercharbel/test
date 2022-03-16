({
    closeToast : function(c, e, h) {
        c.set("v.showToast", false);
        var taskmessage = c.get('v.message');
    },
    
    changeToastHandler : function (c, e, h) {
        if (c.get('v.showToast') === true) {
            /*window.setTimeout(
                $A.getCallback(function () {
                    c.set("v.showToast", false);
                }), c.get('v.duration')
            );*/
            window.setTimeout(
                $A.getCallback(function () {
                    c.set("v.showToast", false);
                }), 20000
            );
        }
    }
    
})