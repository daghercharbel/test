import { LightningElement,api } from 'lwc';
import getUnsubscribedClientsFromCampaign from '@salesforce/apex/FetchUnsubscribedClients.getUnsubscribedClientsFromCampaign';
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
import { NavigationMixin } from 'lightning/navigation';

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
        No_unsubscribed_client_text
    };
    @api recordId;
    isSpinner = true;
    search = '';
    returnedData = [];
    searchStringList = [];
    listData =[];
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

    handleonchange(event){
        console.log('handle change');
        this.search = event.target.value;
        console.log('s:: '+ this.search);
        // var isEnterKey = false;
        // if(event !== undefined && event["keyCode"] !== undefined && event.keyCode !== undefined && event.keyCode !== null){
        //     isEnterKey = event.keyCode == 13?true:false;
        // }
        if(this.search.trim()){
            console.log('if');
            this.searchData();
        }else if(!this.search){
            console.log('else');
            this.returnedData = this.searchStringList;
            console.log('data in else:: '+ JSON.stringify(this.returnedData));  
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
    }

    handlePrevious() {
        if(this.pageNo>1){
            this.pageNo -= 1;
        }
        this.preparePaginationList();
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
}