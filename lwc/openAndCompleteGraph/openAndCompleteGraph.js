import { LightningElement, api } from 'lwc';
import TelosTouch from '@salesforce/resourceUrl/TelosTouch';
import { loadScript } from 'lightning/platformResourceLoader';
import { subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled, } from 'lightning/empApi';
import getConversationRecords from '@salesforce/apex/OpenAtAndCompleteAtGraph_Controller.getConversationRecords';

//Custom Labels
import Campaign_Graph_Campaign_Performance_Text from "@salesforce/label/c.Campaign_Graph_Campaign_Performance_Text";
import Campaign_Graph_Completed_Text from "@salesforce/label/c.Campaign_Graph_Completed_Text";
import Campaign_Graph_Opened_Text from "@salesforce/label/c.Campaign_Graph_Opened_Text";
import Campaign_Graph_Will_Populate_Text from "@salesforce/label/c.Campaign_Graph_Will_Populate_Text";
import Customize_AddClientText from "@salesforce/label/c.Customize_AddClientText";
import Customize_PreviewLabel_Text from "@salesforce/label/c.Customize_PreviewLabel_Text";
import New_Client_Added_Text from "@salesforce/label/c.New_Client_Added_Text";
import SendTP_CustomizeText from "@salesforce/label/c.SendTP_CustomizeText";
import StartByChoosingTP from "@salesforce/label/c.StartByChoosingTP";

export default class OpenAndCompleteGraph extends LightningElement {

    label={
        Campaign_Graph_Campaign_Performance_Text,
        Campaign_Graph_Completed_Text,
        Campaign_Graph_Opened_Text,
        Campaign_Graph_Will_Populate_Text,
        Customize_AddClientText,
        Customize_PreviewLabel_Text,
        New_Client_Added_Text,
        SendTP_CustomizeText,
        StartByChoosingTP
    }

    conversationLoaded = false;
    graphData;
    infoText;
    isLoading = true;
    myChart;
    @api recordId;
    subscribedChannel = '/event/TelosTouchSF__Insight_Creation_Event__e';
    subscription = {};
    telosTouchLoaded = false;

    renderedCallback(){
        if(this.telosTouchLoaded){return;}

        loadScript(this, TelosTouch+'/campaignBarChart/Chart.bundle.js').then(() => {
            this.telosTouchLoaded = true;
            this.handleSubscription();
            this.loadConversations();
        });
    }

    handleSubscription() {
        const callbackFunction = function (eventReceived) {
            if (this.recordId == eventReceived.data.payload.TelosTouchSF__Campaign__c){
                this.isLoading = true;
                this.infoText = undefined;
                this.loadConversations();
            }
        };

        subscribe(this.subscribedChannel, -1, callbackFunction.bind(this)).then((response) => {
            this.subscription = response;
        });
    }

    loadConversations(){
        if(this.myChart) this.myChart.destroy();
        getConversationRecords({recordId : this.recordId})
        .then(result => {
            if(result){
                this.conversationLoaded = true;
                this.graphData = result;
                if(this.conversationLoaded && this.telosTouchLoaded){
                    this.loadGraph();
                }
            }
        })
        .catch(error => {
            console.error('TelosTouch loadConversations Error: ',error);
            this.isLoading = false;
        });
    }

    doRefresh(){
        this.isLoading = true;
        this.infoText = undefined;
        this.loadConversations();
    }

    loadGraph(){
        try{
            var maximumList = 0;
            var datawrapper = JSON.parse(this.graphData);
            var dataObj = datawrapper.OpenedAtCompletedWrapperList;
            var titleName = "";
            let label = this.label

            if (dataObj && dataObj.length > 0) {
                titleName = this.label.Campaign_Graph_Campaign_Performance_Text;
                var xAxisValue = [];
                var data = [];
                var OpenedAndCompletedNameList = datawrapper.OpenedAtCompletedNameList;
                var dataList = [];
                for (let k = 0; k < OpenedAndCompletedNameList.length; k++) {
                    let obj = {};
                    obj.label = OpenedAndCompletedNameList[k];
                    if (obj.label === this.label.Campaign_Graph_Opened_Text) {
                        obj.backgroundColor = "#00bfff";
                    }
                    if (obj.label === this.label.Campaign_Graph_Completed_Text) {
                        obj.backgroundColor = "#3f28a0";
                    }
            
                    obj.data = [];
                    dataList.push(obj);
                }
                let mapObj = new Map();
                let opnendCount = 0;
                let completedCount = 0;
                for (let i = 0; i < dataObj.length; i++) {
                    xAxisValue.push(dataObj[i].name);
                    for (let j = 0; j < dataObj[i].dataWrapperList.length; j++) {
                        let openAndCompleted = dataObj[i].dataWrapperList[j].OpenAtCompletedAtName;
                        if (openAndCompleted == this.label.Campaign_Graph_Opened_Text){
                            opnendCount = opnendCount + dataObj[i].dataWrapperList[j].Data;
                            mapObj.set(openAndCompleted, opnendCount);
                        } else if (openAndCompleted == this.label.Campaign_Graph_Completed_Text){
                            completedCount =completedCount + dataObj[i].dataWrapperList[j].Data;
                            mapObj.set(openAndCompleted, completedCount);
                        }
                    }
                    if (dataObj[i].dataWrapperList.length == 1) {
                        if (dataObj[i].dataWrapperList[0].OpenAtCompletedAtName == this.label.Campaign_Graph_Completed_Text){
                            mapObj.set(this.label.Campaign_Graph_Opened_Text, opnendCount);
                        } else {
                          mapObj.set(this.label.Campaign_Graph_Completed_Text, completedCount);
                        }
                    }
                    for (let j = 0; j < dataList.length; j++) {
                        if (mapObj) {
                            if(mapObj.has(dataList[j].label)) {
                                dataList[j].data.push(mapObj.get(dataList[j].label));
                            } else {
                                dataList[j].data.push(0);
                            }
                        }
                    }
                    mapObj.clear();
                }
                if (completedCount >= opnendCount) {
                  maximumList = completedCount;
                } else {
                  maximumList = opnendCount;
                }
            } else {
                if(datawrapper.userName != null && datawrapper.campaignSynced && !datawrapper.newMemberAdded){
                    this.infoText = label.Campaign_Graph_Will_Populate_Text;
                } else if(datawrapper.userName != null && datawrapper.campaignSynced && datawrapper.campMemberPresent && datawrapper.templatePresent && datawrapper.newMemberAdded){
                    this.infoText = label.New_Client_Added_Text;
                } else if(datawrapper.userName == null && !datawrapper.campaignSynced && datawrapper.campMemberPresent && !datawrapper.templatePresent){
                    this.infoText = label.SendTP_CustomizeText;
                } else if(datawrapper.userName == null && !datawrapper.campaignSynced && !datawrapper.campMemberPresent && datawrapper.templatePresent){
                    this.infoText = label.Customize_AddClientText;
                } else if(datawrapper.userName == null && !datawrapper.campaignSynced && datawrapper.campMemberPresent && datawrapper.templatePresent){
                    this.infoText = label.Customize_PreviewLabel_Text;
                } else{
                    this.infoText = label.StartByChoosingTP;
                }
            }

            
            Chart.plugins.register({});
            var ctx = this.template.querySelector('canvas.chart');
            if(ctx){
                var myChart = new Chart(ctx, {
                    type: "bar",
                    data: {
                        labels: xAxisValue,
                        datasets: dataList
                    },
                    options: {
                        title: {
                            display: true,
                            text: titleName
                        },
                        scales: {
                            yAxes: [{
                                display: true,
                                ticks: {
                                    stepSize: 1,
                                    suggestedMin: 0,
                                    suggestedMax: maximumList
                                },
                                gridLines: {
                                    display: false
                                }
                            }]
                        }
                    }
                });
                this.myChart = myChart;
            }
            this.isLoading = false;

        } catch (ex) {
            console.error('TelosTouch LoadGraph Error: ',ex);
            this.isLoading = false;
        }
    }

}