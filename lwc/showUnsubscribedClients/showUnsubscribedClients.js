import { LightningElement,api, track } from 'lwc';
import getUnsubscribedClientsFromCampaign from '@salesforce/apex/FetchUnsubscribedClients.getUnsubscribedClientsFromCampaign';
import removeClient from '@salesforce/apex/FetchUnsubscribedClients.removeClient';
import resubscribeClient from '@salesforce/apex/FetchUnsubscribedClients.resubscribeClient';
import Name_Text from "@salesforce/label/c.Name_Text";
import Email_Text from "@salesforce/label/c.Email_Text";
import Previous_Button_Label from "@salesforce/label/c.Previous_Button_Label";
import Next_Button_Label from "@salesforce/label/c.Next_Button_Label";
import Search_using_name_email_text from "@salesforce/label/c.Search_using_name_email_text";
import Enter_Search_Term_Text from "@salesforce/label/c.Enter_Search_Term_Text";
import Search_Text from "@salesforce/label/c.Search_Text";
import Phone_text from "@salesforce/label/c.Phone_text";
import Page_no_text from "@salesforce/label/c.Page_no_text";
import of_text from "@salesforce/label/c.of_text";
import No_unsubscribed_client_text from "@salesforce/label/c.No_unsubscribed_client_text";
import Records_were_removed_Text from "@salesforce/label/c.Records_were_removed_Text";
import No_data_is_deleted_Text from "@salesforce/label/c.No_data_is_deleted_Text";
import No_data_is_updated_Text from "@salesforce/label/c.No_data_is_updated_Text";
import Records_were_resubscribed_Text from "@salesforce/label/c.Records_were_resubscribed_Text";
import Remove_Client_Text from "@salesforce/label/c.Remove_Client_Text";
import Resubscribe_Client_Text from "@salesforce/label/c.Resubscribe_Client_Text";
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ShowUnsubscribedClients extends NavigationMixin(LightningElement) {
    label = {
        Name_Text,
        Email_Text,
        Previous_Button_Label,
        Next_Button_Label,
        Search_using_name_email_text,
        Enter_Search_Term_Text,
        Search_Text,
        Phone_text,
        Page_no_text,
        of_text,
        No_unsubscribed_client_text,
        Records_were_removed_Text,
        No_data_is_deleted_Text,
        No_data_is_updated_Text,
        Records_were_resubscribed_Text,
        Remove_Client_Text,
        Resubscribe_Client_Text,
    };
    @api recordId;
    selectAllCheckbox = false
    isDisableBtnFunctionality = true;
    isSpinner = true;
    search = '';
    returnedData = [];
    searchStringList = [];
    @track listData =[];
    pageList; 
    startRecord;
    endRecord;
    currentPage = 1;
    recordPerPage = 10;
    preDisable = false;
    nextDisable = false;
    totalPages = 1; 
    end = false;
    dataExist = false;
    pageNo=1;
    selectedRecordsList = [];

    handleonchange(event){
        this.search = event.target.value;
        // var isEnterKey = false;
        // if(event !== undefined && event["keyCode"] !== undefined && event.keyCode !== undefined && event.keyCode !== null){
        //     isEnterKey = event.keyCode == 13?true:false;
        // }
        if(this.search.trim()){
            this.searchData();
        }else if(!this.search){
            this.returnedData = this.searchStringList;
            this.totalPages = Math.ceil(this.returnedData.length / this.recordPerPage );
            if(this.pageNo == 1){
                this.preDisable = true;
            }
            this.preparePaginationList();
            this.search=''; 
        }
    }
    onclickHandle(){
        if(this.search){
            this.searchData();
        }
    }
    searchData(){
        try {
            this.returnedData = this.searchStringList;
            this.isSpinner = true;
            if(this.isSpinner){
                this.dataExist = true;
            }
            this.isSpinner = true;
            let updateSearchList = [];
            if((this.search)){
                for(var i=0; i<this.returnedData.length; i++){
                    if(this.returnedData[i].Name && this.returnedData[i].Email && this.returnedData[i].Phone){
                        if(this.returnedData[i].Email.toUpperCase().includes(this.search.toUpperCase()) || 
                            this.returnedData[i].Phone.includes(this.search) ||
                            this.returnedData[i].Name.toUpperCase().includes(this.search.toUpperCase())){
                                updateSearchList.push(this.returnedData[i]);
                        }
                    }else if(this.returnedData[i].Name && this.returnedData[i].Email){
                        if(this.returnedData[i].Email.toUpperCase().includes(this.search.toUpperCase()) || 
                            this.returnedData[i].Name.toUpperCase().includes(this.search.toUpperCase())){
                                updateSearchList.push(this.returnedData[i]);
                        }
                    }
                }
                this.returnedData = updateSearchList;
            }
            this.totalPages = Math.ceil(this.returnedData.length / this.recordPerPage );
            if(this.pageNo == 1){
                this.preDisable = true;
            }
            this.preparePaginationList();
            this.isSpinner = false;
        } catch (error) {
            //console.log(error);
        }        
        // this.returnedData = this.searchStringList;
    }
    connectedCallback(){
        if(this.isSpinner){
            this.dataExist = true;
        }
        this.getDataFromApex();
   }  
   getDataFromApex(){
    getUnsubscribedClientsFromCampaign({recId: this.recordId})
    .then(data => {
        if(data){
            this.dataExist = true;
            this.returnedData = data;
            //console.log(this.returnedData.length);
            this.searchStringList = data;
            this.totalPages = Math.ceil(this.returnedData.length / this.recordPerPage );
             if(this.pageNo == 1){
                 this.preDisable = true;
             }
            this.preparePaginationList();
            this.isSpinner = false;
        }else{
            this.dataExist = false;
            this.isSpinner = false;
        }  
    })
    .catch(error => {
        this.error = error;
        this.isSpinner = false;
    });
   }
   handleClick(event) {
        let label = event.target.label;
        if (label === "Previous" || label === "Précédent") {
            this.handlePrevious();
        } else if (label === "Next" || label === "Suivant") {
            this.handleNext();
        }
    }
   handleNext() {
    this.pageNo += 1;
    this.preparePaginationList();
    let flag = 0;
    for(let x of this.listData){
        if(!x.isChecked){
            flag = 1;
            break;
        }
    }
    if(flag){
        this.selectAllCheckbox = false;
    }else{
        this.selectAllCheckbox = true;
    }
    }

    handlePrevious() {
        if(this.pageNo>1){
            this.pageNo -= 1;
        }
        this.preparePaginationList();
        let flag = 0;
        for(let x of this.listData){
        if(!x.isChecked){
            flag = 1;
            break;
        }
        }
        if(flag){
            this.selectAllCheckbox = false;
        }else{
            this.selectAllCheckbox = true;
        }
    }
    preparePaginationList() {
        try{
            if(this.pageNo <= this.totalPages && this.pageNo != 1){
                this.preDisable = false;
            }
            if(this.pageNo == 1){
                this.preDisable = true;
            }
            if(this.totalPages == this.pageNo){
                this.nextDisable = true;
            }else{
                this.nextDisable = false;
            }
            let begin = (this.pageNo - 1) * parseInt(this.recordPerPage);
            let end = parseInt(begin) + parseInt(this.recordPerPage);
            this.listData = this.returnedData.slice(begin, end);
            if(this.listData.length == 0 ){
                this.preDisable = true;
                this.nextDisable = true;
                this.totalPages =1;
                this.pageNo = 1;
            }
            this.startRecord = begin + parseInt(1);
            this.endRecord = end > this.returnedData.length ? this.returnedData.length : end;
            this.end = end > this.returnedData.length ? true : false;
            const event = new CustomEvent('pagination', {
                detail: { 
                    records : this.listData
                }
            });
            this.dispatchEvent(event);  
        }catch(error){
            //console.log('error , pagination :: '+ error);
        } 
    }
    navigateToRecordPage(event) {
        try {
            let recordId ;
            let cmId = event.currentTarget.dataset.id;
            for(let x of this.listData){
                if(x.Id == cmId){
                    if(x.ContactId){
                        recordId = x.ContactId;    
                    }else if(x.LeadId){
                        recordId = x.LeadId;
                    }
                }
            }
            this[NavigationMixin.GenerateUrl]({
                type: "standard__recordPage",
                attributes: {
                    recordId: recordId,
                    actionName: 'view'
                }
            }).then(url => {
                window.open(url, "_blank");
            });
            // this[NavigationMixin.Navigate]({
            //     type: 'standard__recordPage',
            //     attributes: {
            //         recordId: recordId,
            //         actionName: 'view'
            //     }
            // });
        } catch (error) {
            //console.log(error);
        }   
    }
    handleCheckboxChange(event){
        //console.log('handle checkbox');
        try {
            let tempSelectedRecords = [];
            for(var each of this.listData){
                if(each.Id == event.target.value){
                  each.isChecked = !each.isChecked;
                  tempSelectedRecords.push(each);
                }
            }
            let flag = 0;
            for(let x of this.listData){
            if(!x.isChecked){
                flag = 1;
                break;
            }
            }
            if(flag){
                this.selectAllCheckbox = false;
            }else{
                this.selectAllCheckbox = true;
            }
            let tempSelectedRecordsList = this.selectedRecordsList;
            if (tempSelectedRecords.length > 0 && tempSelectedRecords != undefined) {
                let tempFinalList = this.selectedRecordsList;
                for(let i=0; i<tempSelectedRecords.length; i++){
                    if(tempSelectedRecords[i].isChecked == true && !tempSelectedRecordsList.includes(tempSelectedRecords[i])){
                        tempFinalList.push(tempSelectedRecords[i]); 
                    }
                }
                for(let i=0;i<tempFinalList.length; i++){
                    if(tempFinalList[i].isChecked == false){
                        tempFinalList.splice(i, 1);
                    }
                }            
                this.selectedRecordsList =  tempFinalList;
                //console.log(this.selectedRecordsList.length);
                if(this.selectedRecordsList.length >0 ){
                    this.isDisableBtnFunctionality = false;
                }else{
                    this.isDisableBtnFunctionality = true;
                }
            } else {
                this.isDisableBtnFunctionality = true;
            }
            //console.log('final particular check:: '+ JSON.stringify(this.selectedRecordsList));
        } catch (error) {
            //console.log(error);
        }
    }
    handleSelectAllCheckboxChange(event){
        try {
            let updatedWithCheckboxList = [];
            let paginationList = this.listData;
            this.selectAllCheckbox = event.target.checked;
            //console.log(event.target.checked);
            for(var each of paginationList){
                if(event.target.checked){
                    each.isChecked = true;
                    updatedWithCheckboxList.push(each);
                }else {
                    each.isChecked = false;
                    updatedWithCheckboxList.push(each);
                }
            }
            //console.log('updatedWithCheckboxList >> '+ JSON.stringify(updatedWithCheckboxList))
            this.listData = updatedWithCheckboxList;
            let flag = 0;
                for(let x of updatedWithCheckboxList){
                if(!x.isChecked){
                    flag = 1;
                    break;
                }
            }
            //console.log('flag:: '+ flag);
            if(flag){
                this.selectAllCheckbox = false;
            }else{
                this.selectAllCheckbox = true;
            }
            if (updatedWithCheckboxList.length > 0 && updatedWithCheckboxList != undefined) {
                let tempFinalList = this.selectedRecordsList;
                let temp = []
                for(let i=0; i<updatedWithCheckboxList.length; i++){
                    if(updatedWithCheckboxList[i].isChecked == true && !tempFinalList.includes(updatedWithCheckboxList[i])){
                        tempFinalList.push(updatedWithCheckboxList[i]); 
                    }else if(updatedWithCheckboxList[i].isChecked == false){
                    
                    }
                }
                for (let k in tempFinalList){
                    if(tempFinalList[k].isChecked ){
                        temp.push(tempFinalList[k])
                    }
                }         
                this.selectedRecordsList = temp;
                //console.log('selectAll:: '+ this.selectedRecordsList.length);
                //console.log("final selectAll: "+ JSON.stringify(this.selectedRecordsList));
                if(this.selectedRecordsList.length >0 ){
                    this.isDisableBtnFunctionality = false;
                }else{
                    this.isDisableBtnFunctionality = true;

                }
            //   c.set("v.isDisableSendTouchPointBtn", false);
            
            } else {
                this.isDisableBtnFunctionality = true;
            }
            this.onOffSelectAll(event);   
        } catch (error) {
            //console.log(error);
        }
    }
    onOffSelectAll(event){
        let tempList = this.listData;
        //console.log(JSON.stringify(tempList));
        let flag = 0;
        for(let x of tempList){
          x.isChecked? flag = 0 : flag =1;
        }
        try {
          if(flag == 0){
          this.selectAllCheckbox = true;
          }
          else{
            this.selectAllCheckbox = false;
          }
        } catch (error) {
            //console.log(error);
        }
    }
    removeClients(event){
        let ids = [];
        if(this.selectedRecordsList){
            for(let x of this.selectedRecordsList){
                if(x.Id && !ids.includes(x.Id)){
                    ids.push(x.Id); 
                }
            }
        }
        if(ids.length>0){
            //console.log(typeof(ids));
            removeClient({idsData: JSON.stringify(ids)})
            .then(data => {
                if(data == 'success'){
                    this.getDataFromApex();
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success!!', 
                            message: this.selectedRecordsList.length +' '+ this.label.Records_were_removed_Text, 
                            variant: 'success'
                        }),
                    );
                    this.selectedRecordsList = [];
                    this.selectAllCheckbox = false;
                    this.isDisableBtnFunctionality = true;
                }else{
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error!! ', 
                            message: this.label.No_data_is_deleted_Text, 
                            variant: 'error'
                        }),
                    );
                    this.getDataFromApex();
                    this.selectedRecordsList = [];
                    this.selectAllCheckbox = false;
                    this.isDisableBtnFunctionality = true;
                }  
            })
            .catch(error => {
                this.error = error;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error!! ', 
                        message: error.message, 
                        variant: 'error'
                    }),
                );
                this.selectedRecordsList = [];
                this.selectAllCheckbox = false;
                this.isDisableBtnFunctionality = true;
            });
        }
        //this.onOffSelectAll(event);
    }
    resubscribeClients(event){
        let conIds = [];
        let leadIds = [];
        if(this.selectedRecordsList){
            for(let x of this.selectedRecordsList){
                if(x.ContactId && !conIds.includes(x.ContactId) && x.ContactId != null){
                    conIds.push(x.ContactId); 
                }else if(x.LeadId && !leadIds.includes(x.LeadId) && x.LeadId != null){
                    leadIds.push(x.LeadId);
                }
            }
        }
        if(conIds.length>0 || leadIds.length>0){
            //console.log(typeof(conIds));
            resubscribeClient({conIds: JSON.stringify(conIds), leadIds: JSON.stringify(leadIds)})
            .then(data => {
                if(data){
                    this.getDataFromApex();
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success!!', 
                            message: this.selectedRecordsList.length + ' '+ this.label.Records_were_resubscribed_Text, 
                            variant: 'success'
                        }),
                    );
                    this.selectedRecordsList = [];
                    this.selectAllCheckbox = false;
                    this.isDisableBtnFunctionality = true;
                }else{
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error!! ', 
                            message: this.label.No_data_is_updated_Text, 
                            variant: 'error'
                        }),
                    );
                    this.getDataFromApex();
                    this.selectedRecordsList = [];
                    this.selectAllCheckbox = false;
                    this.isDisableBtnFunctionality = true;
                }  
            })
            .catch(error => {
                this.error = error;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error!! ', 
                        message: error.message, 
                        variant: 'error'
                    }),
                );
                this.selectedRecordsList = [];
                this.selectAllCheckbox = false;
                this.isDisableBtnFunctionality = true;
            });
        }
        //this.onOffSelectAll(event);
    }
}