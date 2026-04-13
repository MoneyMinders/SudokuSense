var ms = 0, sec=0, min=0, hr=0;
var status = 0;
function strtpause() 
{
 if (status==1)
 {
  status = 0;
  now = new Date();
  ms = now.getTime() - then.getTime();
  min=Math.floor(ms/(60*1000));
  sec=Math.floor((ms%(60*1000))/1000);
  if (sec<10) dsec="0"+sec;
  else dsec=""+sec;
  timeshown=min+":"+dsec;
  document.getElementById('time2').style.color = "";
  document.getElementById('time2').innerHTML = timeshown;
 }
 else
 {
  status=1;
  then = new Date();
  then.setTime(then.getTime() - ms);
  document.getElementById('time2').style.color = "#008800";
  showtimer();
 } 
}

function timerreset() 
{
 status = 0; 
 ms = 0;
 hr=0;
 min=0;
 sec=0;
 document.getElementById('time2').innerHTML = "0:00";
}

function showtimer() 
{
 if (status == 1)  
 {
  setTimeout("showtimer();",500);
  now = new Date();
  ms = now.getTime() - then.getTime();
 }
  min=Math.floor(ms/(60*1000));
  sec=Math.floor((ms%(60*1000))/1000);
 if (sec<10) dsec="0"+sec;
 else dsec=""+sec;
 timeshown=min+":"+dsec;
 document.getElementById('time2').innerHTML = timeshown;
}
