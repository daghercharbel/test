({
    doInit : function(c, e, h) {
        h.doInit_helper(c,e,h);
    },
    setHeight : function(c, e, h) {
        if($A.get("$Browser.isTablet") == true || $A.get("$Browser.isPhone") == true){
            var Height = screen.availHeight - 305;
            document.getElementById("frame").style.height = Height+"px";
        }else{
            var Height = screen.availHeight - 265;
            document.getElementById("frame").style.height = Height+"px";
        }
    },
})