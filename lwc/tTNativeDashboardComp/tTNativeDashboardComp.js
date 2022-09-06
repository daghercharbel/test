import { api, LightningElement, track } from 'lwc';
import TelosTouch from '@salesforce/resourceUrl/TelosTouch';
import { loadScript } from 'lightning/platformResourceLoader';
import getSentVsCompletedData from '@salesforce/apex/TTNativeHomeController.getSentVsCompletedData';
import getChartData from '@salesforce/apex/TTNativeHomeController.getChartData';
import { NavigationMixin } from 'lightning/navigation';
export default class TTNativeDashboardComp extends NavigationMixin(LightningElement) {
  @track chartConfig;
  @track isChartJsInitialized;
  @track progressData = [];
  @track progressDataPresent = true;
  @track chartData = [];
  @track chartData2 = [];
  @track chartLabels = [];
  connectedCallback() {
    if (this.isChartJsInitialized) {
      return;
    }
    this.getProgressData();
    this.populateChartData();
  }

  goToCampaign(event) {
    this[NavigationMixin.Navigate]({
      type: 'standard__recordPage',
      attributes: {
        recordId: event.currentTarget.dataset.id,
        actionName: 'view',
      }
    });
  }

  getProgressData() {
    getSentVsCompletedData()
      .then(data => {
        this.progressData = JSON.parse(data);
        if (this.progressData.length == 0) {
          this.progressDataPresent = false;
        } else {
          this.progressDataPresent = true;
        }
      }).catch(error => {
        // console.log(error);
      })
  }

  populateChartData() {
    getChartData()
      .then(data => {
        let dataObj = JSON.parse(data);
        // console.log(dataObj);
        // console.log(Object.keys(dataObj));
        let keyList = Object.keys(dataObj);
        // console.log(keyList);
        keyList.forEach(element => {
          // console.log(dataObj[element]);
          // console.log(Math.round((dataObj[element].opened / dataObj[element].sent) * 100));
          // console.log(Math.round((dataObj[element].completed / dataObj[element].sent) * 100));
          // console.log(element);
          this.chartLabels.push(element);
          this.chartData.push(Math.round((dataObj[element].opened / dataObj[element].sent) * 100));
          this.chartData2.push(Math.round((dataObj[element].completed / dataObj[element].sent) * 100));
        });
        this.intializeCharts();
      }).catch(error => {
        // console.log(error);
      });
  }
  intializeCharts() {
    this.chartConfig = {
      type: 'bar',
      data: {
        labels: this.chartLabels,
        datasets: [
          {
            label: 'Opened %',
            barPercentage: 0.5,
            barThickness: 6,
            maxBarThickness: 8,
            minBarLength: 2,
            backgroundColor: "#2ec44f",
            data: this.chartData,
          },
          {
            label: 'Completed %',
            barPercentage: 0.5,
            barThickness: 6,
            maxBarThickness: 8,
            minBarLength: 2,
            backgroundColor: "#3b4b9b",
            data: this.chartData2,
          },
        ],
      },
      options: {
        responsive: true,
        // legend: {
        //   display: true,
        //   labels: {
        //     usePointStyle: true
        //   }
        // }
        maintainAspectRatio: false,
        legend: {
          display: true,
          labels: {
            usePointStyle: true,
          }
        },
        scales: {
          yAxes: [{
            ticks: {
              fontSize: 14,
              beginAtZero: true,
              min: 0,
              max: 100,
              stepSize: 20
            }
          }],
          xAxes: [{
            ticks: {
              fontSize: 14
            },
            gridLines: {
              display: false
            }
          }]
        }
      },
    };

    Promise.all([loadScript(this, TelosTouch + '/campaignBarChart/Chart.bundle.js')])
      .then(() => {
        this.isChartJsInitialized = true;
        Chart.plugins.register({
          beforeDraw: (chart) => {
            const ctx = chart.canvas.getContext('2d');
            ctx.save();
            ctx.fillStyle = 'white';
            ctx.fillRect(0, 0, chart.width, chart.height);
            ctx.restore();
          }
        });
        const ctx = this.template.querySelector('canvas.barChart').getContext('2d');
        this.chart = new window.Chart(ctx, JSON.parse(JSON.stringify(this.chartConfig)));
        //this.chart.canvas.style.height = '292px';
        this.chart.canvas.parentNode.style.width = '100%';
      })
      .catch(error => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: 'Error loading ChartJS',
            message: error.message,
            variant: 'error',
          })
        );
      });
  }
}