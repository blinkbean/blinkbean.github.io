<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
Object noOne = session.getAttribute("noOne");
Object atLeastOne = session.getAttribute("atLeastOne");
Object onlyOne = session.getAttribute("onlyOne");
Object atLeastTwo = session.getAttribute("atLeastTwo");
Object dateFormat = session.getAttribute("dateFormat");
Object starttime = session.getAttribute("starttime");
Object endtime = session.getAttribute("endtime");
if(starttime==null){
	starttime="";
}
if(endtime==null){
	endtime="";
}
if(dateFormat==null||dateFormat==""){
}else if(dateFormat=="1"){
}else{
	out.print("<script>");
	out.print("alert(\"");
	out.print(dateFormat);
	out.print("\");");
	out.print("</script>");
}
%>  
<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8"/>
    <title>股票分析</title>
    <link rel="stylesheet" href="css/BeatPicker.min.css"/>
    <link rel="stylesheet" href="documents/css/demos.css"/>
	<script src="js/jquery-1.11.0.min.js"></script>
    <script src="js/bootstrap.js"></script>
    <script src="js/BeatPicker.min.js"></script>
</head>
<body>
	<div class="container">
		<h1>股票分析</h1>

		<form  name="date" action="output.jsp" method="get">

						<div class="inputname">请输入起始时间</div>
				        <input id="starttime" type="text" name="starttime" data-beatpicker="true" value="<%=starttime %>"/>

						<div class="inputname">请输入截止时间</div>
				        <input id="endtime" type="text" name="endtime" data-beatpicker="true" value="<%=endtime %>"/>

			<div class="radio-inline">
			  <label>
			    <input type="radio" name="optionsRadios" id="optionsRadios1" value="option1" checked>三亿以上
			  </label>
			</div>
			<div class="radio-inline">
			  <label>
			    <input type="radio" name="optionsRadios" id="optionsRadios1" value="option1" checked>计算全部
			  </label>
			</div>
		        <input type="submit" value="提交" onmouseover="mDown()">
		</form>
<!-- 		开始时间：<div id="start"></div>
		结束时间：<div id="end"></div> -->
		<button id="btn">click</button><br>
		<button id="btn2">click</button><br>
		<button>一个不中</button>
		<input type="text" id="no_one" disabled="true" value=<%=noOne %>><br>
		<button>至少一个</button>
		<input type="text" id="at_least" disabled="true" value=<%=atLeastOne %>><br>
		<button>只中一个</button>
		<input type="text" id="only_one" disabled="true" value=<%=onlyOne %>><br>
		<button>至少两个</button>
		<input type="text" id="least_two" disabled="true" value=<%=atLeastTwo %>><br> 
		</div>
		<div class="skip">
			<a href="add.html">添加数据</a>
		</div>
		
	</div>
</body>
<script>
	var data = [0.1,0.2,0.3,0.4];
	var count0 = 0;
	var count1 = 0;
	var count2 = 0;
	var starttime = document.getElementById("starttime");
	var endtime = document.getElementById("endtime");
	var btn=document.getElementById('btn');
	var btn2=document.getElementById('btn2');
	var no_one=document.getElementById('no_one');
	var at_least=document.getElementById('at_least');
	var only_one=document.getElementById('only_one');
	var least_two=document.getElementById('least_two');
	btn2.onclick=function(){
		no_one_at_least();
		only_one_value();
		at_least_two();
		at_least_three();
	}
	function no_one_at_least(){
		let base = 1;
		data.forEach(function(item){
			base *= (1-item);
		});
		no_one.value = <%=noOne%>;
		count0 = base;
		at_least.value = <%=atLeastOne%>;

	}
	function only_one_value(){
		
		let last = 0;
		for(let i=0;i<data.length;i++){
		let base = 1;
			for(let j=0;j<data.length;j++){
				if(i==j){continue;}
				base*=(1-data[j]);
				
			}alert(base);
			last += (data[i]*base);
		}
		only_one.value = last;
		count1 = last;
	}
	function at_least_two(){
		least_two.value = 1-(count0+count1);
		count2 = 1-(count0+count1);
	}
	 btn.onclick=function(){
		var starttime_val = starttime.value;
		var endtime_val = endtime.value;
			if(starttime_val==""||starttime_val==null)
			{
				alert("请输入起始时间！");
			}
			else if(endtime_val==""||endtime_val==null)
			{
				alert("请输入截止时间！");
			}
			else if(starttime_val>endtime_val)
			{
				alert("起始时间必须大于截止时间！");
			}
		document.getElementById("start").innerHTML = starttime_val;
		document.getElementById("end").innerHTML = endtime_val;
		}
	function mDown(){  
		var starttime_val = starttime.value;
		var endtime_val = endtime.value;
      	document.getElementById("start").innerHTML = starttime_val;
	  	document.getElementById("end").innerHTML = endtime_val; 
    } 
	
</script>
<style>
.skip{
		position: absolute;
		margin-top: 20px;
		z-index: 100;
	}
	.skip a{
		
		padding: 10px;
		background: #fff;
		border: solid 3px #f00;
		border-radius: 10px;
		font-weight: 700;
		color: #f00;
		text-decoration: none;
		transition: 0.2s;
		-webkit-transition: 0.2s;
	}
	.skip a:hover{
		background: rgba(255,0,0,0.5);
		font-weight: 800;
		color: #fff;
		border: solid 3px #fff;
	}
</style>
</html>