({
  doinit_Helper: function (c, e, h) {
    try {
      var recordId = c.get("v.recordId");
      var action = c.get("c.getConversationRecords");
      action.setParams({
        recordId: recordId
      });
      action.setCallback(this, function (response) {
        var state = response.getState();
        if (state === "SUCCESS") {
          var resp = response.getReturnValue();
          if (!$A.util.isEmpty(resp) && resp != undefined) {
            h.scriptsLoaded_helper(c, e, h, resp);
          }
        }
      });
      $A.enqueueAction(action);
    } catch (ex) {
      //console.log('error in code'+ex);
    }
  },
  scriptsLoaded_helper: function (c, e, h, resp) {
    try {
      var maximumList = 0;
      var datawrapper = JSON.parse(resp);
      var dataObj = datawrapper.OpenedAtCompletedWrapperList;
      var titleName = "";
      if (!$A.util.isEmpty(dataObj)) {
        titleName = $A.get("$Label.c.Campaign_Graph_Campaign_Performance_Text");
        var xAxisValue = [];
        var data = [];
        var OpenedAndCompletedNameList = datawrapper.OpenedAtCompletedNameList;
        var dataList = [];
        for (let k = 0; k < OpenedAndCompletedNameList.length; k++) {
          let obj = {};
          obj.label = OpenedAndCompletedNameList[k];
          if (obj.label === $A.get("$Label.c.Campaign_Graph_Opened_Text")) {
            obj.backgroundColor = "#00bfff";
          }
          if (obj.label === $A.get("$Label.c.Campaign_Graph_Completed_Text")) {
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
            let openAndCompleted =
              dataObj[i].dataWrapperList[j].OpenAtCompletedAtName;
            if (
              openAndCompleted == $A.get("$Label.c.Campaign_Graph_Opened_Text")
            ) {
              opnendCount = opnendCount + dataObj[i].dataWrapperList[j].Data;
              mapObj.set(openAndCompleted, opnendCount);
            } else if (
              openAndCompleted ==
              $A.get("$Label.c.Campaign_Graph_Completed_Text")
            ) {
              completedCount =
                completedCount + dataObj[i].dataWrapperList[j].Data;
              mapObj.set(openAndCompleted, completedCount);
            }
          }
          if (dataObj[i].dataWrapperList.length == 1) {
            if (
              dataObj[i].dataWrapperList[0].OpenAtCompletedAtName ==
              $A.get("$Label.c.Campaign_Graph_Completed_Text")
            ) {
              mapObj.set(
                $A.get("$Label.c.Campaign_Graph_Opened_Text"),
                opnendCount
              );
            } else {
              mapObj.set(
                $A.get("$Label.c.Campaign_Graph_Completed_Text"),
                completedCount
              );
            }
          }

          for (let j = 0; j < dataList.length; j++) {
            let bool = false;
            if (!$A.util.isEmpty(mapObj)) {
              if (mapObj.has(dataList[j].label)) {
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
      }
      Chart.plugins.register({
        afterDraw: function (chart) {
          if (chart.data.datasets.length === 0) {
            var ctx = chart.chart.ctx;
            var width = chart.chart.width;
            var height = chart.chart.height;
            chart.clear();
            ctx.save();
            ctx.textAlign = "center";
            ctx.textBaseline = "middle";
            ctx.font = "20px Arial";
            if (datawrapper.userName != null && datawrapper.campaignSynced) {
              wrapText(
                ctx,
                $A.get("$Label.c.Campaign_Graph_Will_Populate_Text"),
                width / 2,
                height / 2,
                width,
                20 * 1.618
              );
              //ctx.fillText($A.get("$Label.c.Campaign_Graph_Will_Populate_Text"), width / 2, height / 2);
            } else if(datawrapper.userName == null && datawrapper.campaignSynced && !datawrapper.campMemberPresent){
              wrapText(
                ctx,
                $A.get("$Label.c.TouchPoint_Created"),
                width / 2,
                height / 2,
                width,
                20 * 1.618
              );
            }else if(datawrapper.userName == null && datawrapper.campaignSynced && datawrapper.campMemberPresent){
              wrapText(
                ctx,
                $A.get("$Label.c.New_Camp_Member_Added_Text"),
                width / 2,
                height / 2,
                width,
                20 * 1.618
              );
            }else {
              //ctx.fillText($A.get("$Label.c.Campaign_Graph_Send_Touchpoint_Text"), width / 2, height / 2);
              wrapText(
                ctx,
                $A.get("$Label.c.Campaign_Graph_Send_Touchpoint_Text"),
                width / 2,
                height / 2,
                width,
                20 * 1.618
              );
            }
            ctx.restore();
          }
        }
      });
      function wrapText(context, text, x, y, line_width, line_height) {
        var line = "";
        var paragraphs = text.split("\n");
        for (var i = 0; i < paragraphs.length; i++) {
          var words = paragraphs[i].split(" ");
          for (var n = 0; n < words.length; n++) {
            var testLine = line + words[n] + " ";
            var metrics = context.measureText(testLine);
            var testWidth = metrics.width;
            if (testWidth > line_width && n > 0) {
              context.fillText(line, x, y);
              line = words[n] + " ";
              y += line_height;
            } else {
              line = testLine;
            }
          }
          context.fillText(line, x, y);
          y += line_height;
          line = "";
        }
      }
      var ctx = c.find("chart").getElement();
      var myChart = new Chart(ctx, {
        type: "bar",
        data: {
          labels: xAxisValue,
          datasets: dataList
        },
        options: {
          //responsive: true,
          title: {
            display: true,
            text: titleName
          },
          scales: {
            yAxes: [
              {
                display: true,
                ticks: {
                  stepSize: 1,
                  suggestedMin: 0,
                  suggestedMax: maximumList
                },
                gridLines: {
                  display: false
                }
              }
            ]
          }
        }
      });
    } catch (ex) {
      //console.log(ex);
    }
  }
});