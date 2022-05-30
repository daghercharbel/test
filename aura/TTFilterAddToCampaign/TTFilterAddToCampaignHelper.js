({
    selectedUserList_Helper: function (c, e, h) {
        var userList = c.get("v.userList");
        for (var i = 0; i < userList.length; i++) {
            if (
                userList[i].ContactCLientId == null &&
                userList[i].LeadCLientId == null
            ) {
                if (userList.length > 1) {
                    h.showSuccess(
                        c,
                        e,
                        h,
                        "Error",
                        "error",
                        "Some selected members does not exist."
                    );
                } else {
                    h.showSuccess(
                        c,
                        e,
                        h,
                        "Error",
                        "error",
                        "Selected member does not exist."
                    );
                }
                return false;
            }
        }
    },
    showSuccess: function (c, e, h, title, type, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            message: message,
            duration: " 2000",
            key: "info_alt",
            type: type
        });
        toastEvent.fire();
    },
})