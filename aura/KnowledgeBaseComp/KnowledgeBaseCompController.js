({
	handleCarouselClick : function(c, e, h) {
        c.set('v.showCarousel', false);
        c.set('v.showBackButton', true);
        if(e.currentTarget.id === 'onboard'){
            c.set('v.showOnboard', true);
        }else if(e.currentTarget.id === 'install'){
            c.set('v.showInstallation', true);
        }else if(e.currentTarget.id === 'userGuide'){
            c.set('v.showUserGuide', true);
        }else if(e.currentTarget.id === 'uninstall'){
            c.set('v.showUninstallation', true);
        }
	},
    handleBack : function(c, e, h){
        c.set('v.showBackButton', false);
        c.set('v.showOnboard', false);
        c.set('v.showInstallation', false);
        c.set('v.showUserGuide', false);
        c.set('v.showUninstallation', false);
        c.set('v.showCarousel', true);
    }
})