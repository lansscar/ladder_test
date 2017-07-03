/**
 * Created by csn on 6/26/17.
 */
var date = new Date();
var y1;
var y2;
// 设置calendar div中的html部分
renderHtml();

function renderHtml() {
    var headBox = document.getElementById("calendar-head");
    var calendar = document.getElementById("calendar");
    calendar.innerHTML="";
    var bodyBox1 = document.createElement("div");  // 表格区 显示数据
    var bodyBox2 = document.createElement("div");
    var bodyBox3 = document.createElement("div");

    // 设置表格区的html结构

    var headHtml = "<tr>" +
        "<th>日</th>" +
        "<th>一</th>" +
        "<th>二</th>" +
        "<th>三</th>" +
        "<th>四</th>" +
        "<th>五</th>" +
        "<th>六</th>" +
        "</tr>";
    var bodyHtml = "";

    // 一个月最多31天，所以一个月最多占6行表格
    for(var i = 0; i < 6; i++) {
        bodyHtml += "<tr>" +
            "<td onclick='choose(this)'></td>" +
            "<td onclick='choose(this)'></td>" +
            "<td onclick='choose(this)'></td>" +
            "<td onclick='choose(this)'></td>" +
            "<td onclick='choose(this)'></td>" +
            "<td onclick='choose(this)'></td>" +
            "<td onclick='choose(this)'></td>" +
            "</tr>";
    }
    headBox.innerHTML= "<table class='calendar-table'>" +
        headHtml +
        "</table>";
    bodyBox1.innerHTML = "<table id='calendarTable1' class='calendar-table'>" +
        bodyHtml +
        "</table>";
    bodyBox2.innerHTML = "<table id='calendarTable2' class='calendar-table'>" +
        bodyHtml +
        "</table>";
    bodyBox3.innerHTML = "<table id='calendarTable3' class='calendar-table'>" +
        bodyHtml +
        "</table>";
    // 添加到calendar div中

    calendar.appendChild(bodyBox1);
    calendar.appendChild(bodyBox2);
    calendar.appendChild(bodyBox3);


    bodyBox2.ontouchstart=function (e){
        y1 = e.touches[0].clientY;
    }
    bodyBox2.ontouchmove=function (e){
        e.preventDefault()
    }
    bodyBox2.ontouchend=function (e){
        y2 =e.changedTouches[0].clientY;
        if (y1-y2<-50&&y1<150){
            $('#calendarTable1,#calendarTable2,#calendarTable3').animate({top:'0px'},300,'linear');
            setTimeout('callback(-1)',300);
        }
        if (y1-y2>50){
            $('#calendarTable1,#calendarTable2,#calendarTable3').animate({top:'-420px'},300,'linear');
            setTimeout('callback(1)',300);
        }
    }
    showCalendar();
}

function showCalendarData(table_id) {
    var year = date.getFullYear();
    var month = date.getMonth() + 1;
    var day = date.getDate();

    // 设置表格中的日期数据
    var table = document.getElementById(table_id);
    var tds = table.getElementsByTagName("td");
    var firstDay = new Date(year, month - 1, 1);  // 当前月第一天
    for(var i = 0; i < tds.length; i++) {
        var thisDay = new Date(year, month - 1, i + 1 - firstDay.getDay());
        tds[i].innerText = thisDay.getDate();

        if(thisDay.getDate() == day&&thisDay.getMonth() == month - 1) {    // 当前天
            tds[i].className = 'currentDay';
        }else if(thisDay.getMonth() == month - 1) {
            tds[i].className = 'currentMonth';  // 当前月
        }else {    // 其他月
            tds[i].className = 'otherMonth';
        }
    }
}

function showCalendar(){
    showCalendarData("calendarTable2");
    date=new Date(date.getFullYear(),date.getMonth()-1,1);
    showCalendarData("calendarTable1");
    date=new Date(date.getFullYear(),date.getMonth()+2,1);
    showCalendarData("calendarTable3");
    date=new Date(date.getFullYear(),date.getMonth()-1,1);
}

function callback(num){
    date=new Date(date.getFullYear(),date.getMonth()+num,1);
    afterDingtalkInitedInGradePage()
    renderHtml();
}

date = new Date();
