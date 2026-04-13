function chkpzsaved() {
	var pzval=getCookie("savedpz");	
    if (pzval!="") {
	  var spzinfo=pzval.split("!");	
	  var pzsaved=spzinfo[0];
	  if (pzsaved.length>0) {
		var expdt=0;
		if (spzinfo.length>3) expdt=spzinfo[3].substring(spzinfo[3].indexOf(":")+1)*1; 
		mshwgameno(pzsaved,expdt); 
	  }
    }
}

function rlpuzz() {
	var pzval=getCookie("savedpz");	
	if (pzval!="") {
	  if (pzval.indexOf("Daily Sudoku")>=0) {
		  if (pzval.indexOf("L1")>=0) document.rlpuzz.action="/dailysudoku/kindergarten/";
		  else if (pzval.indexOf("L2")>=0) document.rlpuzz.action="/dailysudoku/elementary/";
		  else if (pzval.indexOf("L3")>=0) document.rlpuzz.action="/dailysudoku/highschool/";
		  else if (pzval.indexOf("L4")>=0) document.rlpuzz.action="/dailysudoku/college/";
		  else if (pzval.indexOf("L5")>=0) document.rlpuzz.action="/dailysudoku/graduate/";
		  else if (pzval.indexOf("L6")>=0) document.rlpuzz.action="/dailysudoku/expert/";
	  }
	  else if (pzval.indexOf("My puzzle")>=0) document.rlpuzz.action="/blankgrid/";
	  else if (pzval.indexOf("Daily Challenge")>=0) document.rlpuzz.action="/dailychallenge/";
	  else if (pzval.indexOf("L1")>=0) document.rlpuzz.action="/kindergarten/";
	  else if (pzval.indexOf("L2")>=0) document.rlpuzz.action="/elementary/";
	  else if (pzval.indexOf("L3")>=0) document.rlpuzz.action="/highschool/";
	  else if (pzval.indexOf("L4")>=0) document.rlpuzz.action="/college/";
	  else if (pzval.indexOf("L5")>=0) document.rlpuzz.action="/graduate/";
	  else if (pzval.indexOf("L6")>=0) document.rlpuzz.action="/expert/";
	  document.rlpuzz.submit();
	}
	else document.getElementById("broadcastmsg").innerHTML="Cannot reload - Puzzle information corrupted";
}

function shwpz() {
	var pzval=getCookie("savedpz");
	
    if (pzval!="") {
	  var spzinfo=pzval.split("!");	
	  curgame=spzinfo[0];
	  ms=spzinfo[1].substring(spzinfo[1].indexOf(":")+1); 
      if (ms>0) {
        min=Math.floor(ms/(60*1000));
        sec=Math.floor((ms%(60*1000))/1000);
        if (sec<10) dsec="0"+sec;
        else dsec=""+sec;
        timeshown=min+":"+dsec;
        document.getElementById("time2").innerHTML = timeshown;
	  }
	  var cellval=spzinfo[2].substring(spzinfo[2].indexOf(":")+1).split(",");
	  for (var i=0;i<81;i++) {
		 if (cellval[i].indexOf("y")>=0) document.getElementById("cell"+i).style.backgroundColor=yellow;
		 else if (cellval[i].indexOf("g")>=0) document.getElementById("cell"+i).style.backgroundColor=green;
		 else if (cellval[i].indexOf("r")>=0) document.getElementById("cell"+i).style.backgroundColor=red;
		 else if (cellval[i].indexOf("b")>=0) document.getElementById("cell"+i).style.backgroundColor=blue;
		 if (cellval[i].indexOf("0")<0) {
			 document.getElementById("c"+i).innerHTML=cellval[i].replace(/[ygrbsc0]/g,"");
			 if (cellval[i].indexOf("s")>=0) setpmarkfont(i);
		 }
	  }
	}
	else document.getElementById("broadcastmsg").innerHTML = "Puzzle Cannot be Reloaded (Cookies were Deleted)";
}

function msavepuzz(spuzzno) {
    createCookie("savedpz","none")
	if (readCookie("savedpz")) {
     var cellv="";
     for(var i=0;i<81;i++) {
	   var dumclr=truecolor(document.getElementById('cell'+i).style.backgroundColor);
       if (dumclr==yellow) cellv=cellv+"y";
       else if (dumclr==red) cellv=cellv+"r";
       else if (dumclr==blue) cellv=cellv+"b";
       else if (dumclr==green) cellv=cellv+"g";
       if (document.getElementById('c'+i).innerHTML!="") {
	     cellv=cellv+document.getElementById('c'+i).innerHTML;
	   }
       else {
	     cellv=cellv+"0";
       }
	   if (pmark[i]==true) cellv=cellv+"s";
	   if (orig[i]!=0) cellv=cellv+"c";
       if (i<80) {
         cellv=cellv+",";
       }		
     }
	 var expdate = new Date(), day=7;
	 expdate=expdate.getTime()+(day*24*60*60*1000);
	 var pzinfo=spuzzno+"!time:"+ms+"!pzinfo:"+cellv+"!expdate:"+expdate;
	 if (spuzzno=="My puzzle") pzinfo=pzinfo+"!sltn:"+sltnstr;
	 createCookie("savedpz",pzinfo,day);
	 mshwgameno(spuzzno,expdate);
    }
	else {
	  alert("Can't save.  Your browser does not allow Cookies.");
	}
}
	
function mdelpuzz() {
    eraseCookie("savedpz");
    document.getElementById("savegame").style.display =""; 
}	

function mshwgameno(spuzzno,expdt) {
  document.getElementById("savedgnum").innerHTML=spuzzno; 
  if (expdt>0) {
    var expdttime=new Date(expdt);
    var mnth=expdttime.getMonth()+1
    document.getElementById("exptime").innerHTML=" (Expiration "+expdttime.getFullYear()+"-"+mnth+"-"+expdttime.getDate()+" "+expdttime.getHours()+":"+expdttime.getMinutes()+":"+expdttime.getSeconds()+")"; 	  
  }
  if (document.getElementById("savegame").style.display=="") document.getElementById("savegame").style.display="block";	
}
