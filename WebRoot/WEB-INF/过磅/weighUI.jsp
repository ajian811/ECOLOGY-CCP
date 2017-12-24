<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page contentType="text/html; charset=UTF-8"%>
<html>
<head>
<style type="text/css">
.x-toolbar table {
	width: 0
}

.x-panel-btns-ct {
	padding: 0px;
}

.x-panel-btns-ct table {
	width: 0
}

#pagemenubar table {
	width: 0
}
</style>
<!--
<script src='/dwr/interface/DataService.js'></script>

<script src='/dwr/engine.js'></script>
<script src='/dwr/util.js'></script>
	-->
<link rel="stylesheet" type="text/css"
	href="/css/bootstrap-4.0.0-beta.2-dist/css/bootstrap.min.css" />
<link rel="stylesheet" type="text/css"
	href="/weightStyle/ext/resources/css/ext-all.css" />
<script language="javascript" src="/weightStyle/ext/adapter/ext-base.js"></script>
<script language="javascript" src="/weightStyle/ext/ext-all.js"></script>
<script language="javascript"
	src="/weightStyle/datapicker/WdatePicker.js"></script>
<script language="javascript" src="/weightStyle/jquery-latest.pack.js"></script>
<script language="javascript" src="/weightStyle/ext/us/toolbar.js"></script>
<script language="javascript" src="/weightStyle/ext/us/iconMgr.js"></script>
<link href="/weightStyle/cchglogi/css/global.css" rel="stylesheet"
	type="text/css">
<script language="javascript" src="/weightStyle/ext/us/miframe.js"></script>
<script language="javascript"
	src="/weightStyle/jquery/jquery-1.7.2.min.js"></script>
<script language="javascript"
	src="/weightStyle/jquery/plugins/hoverIntent/jquery.hoverIntent.js"></script>
<script language="javascript"
	src="/weightStyle/jquery/plugins/qtip/jquery.qtip.min.js"></script>
<link rel="stylesheet" type="text/css"
	href="/weightStyle/jquery/plugins/qtip/jquery.qtip.min.css" />

</head>
<body>
	<script type="text/javascript">
		Ext.LoadMask.prototype.msg = ''; //加载中,请稍后...
		var weighType;
		var store1;
		var store2;
		var sm1;
		var sm2;
		var selected1 = new Array();
		var selected2 = new Array();
		var selectedRow1 = new Array();
		var selectedRow2 = new Array();
		Ext.onReady(function() {
			Ext.QuickTips.init();
			//start store1     
			store1 = new Ext.data.Store({
				proxy : new Ext.data.HttpProxy({
					url : '/weightJsp/gbcz.jsp?action=searchMX1'
				}),
				reader : new Ext.data.JsonReader({
					root : 'result',
					totalProperty : 'totalcount',
					fields : [ 'planNo',
						'trdh',
						'carno',
						'gbrq',
						'gbsj',
						'rz',
						'cz',
						'jz',
						'gh'
					]
				})
			});
			//end store1
	
			store2 = new Ext.data.Store({
				proxy : new Ext.data.HttpProxy({
					url : '/weightJsp/gbcz.jsp?action=searchMX2'
				}),
				reader : new Ext.data.JsonReader({
					root : 'result',
					totalProperty : 'totalcount',
					fields : [ 'cp',
						'shipping',
						'gbm',
						'sl'
					]
				})
			});
			//end store2
	
			sm1 = new Ext.grid.CheckboxSelectionModel({
				disabled : false
			});
			sm2 = new Ext.grid.CheckboxSelectionModel();
	
			//cm1
			var cm1 = new Ext.grid.ColumnModel([ sm1,
				{
					header : '装卸计划号',
					dataIndex : 'planNo',
					hidden : false,
					width : 140,
					sortable : false,
					menuDisabled : true
				},
				{
					header : '提入单号',
					dataIndex : 'trdh',
					hidden : false,
					width : 140,
					sortable : false,
					menuDisabled : true
				},
				{
					header : '车牌',
					dataIndex : 'carno',
					hidden : false,
					width : 70,
					sortable : false,
					menuDisabled : true
				},
				{
					header : '过磅日期',
					dataIndex : 'gbrq',
					hidden : false,
					width : 70,
					sortable : false,
					menuDisabled : true
				},
				{
					header : '过磅时间',
					dataIndex : 'gbsj',
					hidden : false,
					width : 70,
					sortable : false,
					menuDisabled : true
				},
				{
					header : '入重（KG）',
					dataIndex : 'rz',
					hidden : false,
					width : 70,
					sortable : false,
					menuDisabled : true
				},
				{
					header : '出重（KG）',
					dataIndex : 'cz',
					hidden : false,
					width : 70,
					sortable : false,
					menuDisabled : true
				},
				{
					header : '净重（KG）',
					dataIndex : 'jz',
					hidden : false,
					width : 70,
					sortable : false,
					menuDisabled : true
				},
				{
					header : '柜号/ISO',
					dataIndex : 'gh',
					hidden : false,
					width : 70,
					sortable : false,
					menuDisabled : true
				},
			]);
			cm1.defaultSortable = true;
			//end cm1
	
			//start cm2
			var cm2 = new Ext.grid.ColumnModel([ sm2,
				{
					header : '产品名称',
					dataIndex : 'cp',
					hidden : false,
					width : 80,
					sortable : false,
					menuDisabled : true
				},
				{
					header : 'shipping号',
					dataIndex : 'shipping',
					hidden : false,
					width : 80,
					sortable : false,
					menuDisabled : true
				},
				{
					header : '数量',
					dataIndex : 'sl',
					hidden : false,
					width : 80,
					sortable : false,
					menuDisabled : true
				},
				{
					header : '柜编码',
					dataIndex : 'gbm',
					hidden : false,
					width : 80,
					sortable : false,
					menuDisabled : true
				},
			]);
	
			cm2.defaultSortable = true;
			//end cm2
	
			//start grid1  左边表格
			var grid1 = new Ext.grid.GridPanel({
				region : 'center',
				store : store1,
				renderTo : 'mid1',
				cm : cm1,
				sm : sm1,
				trackMouseOver : false,
				width : 910,
				height : 180,
				loadMask : {
					msg : '正在加载数据，请稍侯……'
				}, //加载完成前显示信息，设置为true则显示Loading
				selModel : new Ext.grid.RowSelectionModel({
					singleSelect : true
				}),
				viewConfig : {
					scrollOffset : -3 //去掉右侧空白区域  
				}
			});
			//end grid1
	
			//start grid2  上部表格
			var grid2 = new Ext.grid.GridPanel({
				region : 'center',
				store : store2,
				renderTo : 'mid2',
				cm : cm2,
				sm : sm2,
				trackMouseOver : false,
				width : 910,
				height : 180,
				loadMask : {
					msg : '正在加载数据，请稍侯……'
				}, //加载完成前显示信息，设置为true则显示Loading
				selModel : new Ext.grid.RowSelectionModel({
					singleSelect : true
				}),
				viewConfig : {
					scrollOffset : -3 //去掉右侧空白区域  
				}
			});
			sm1.on('rowselect', function(selMdl, rowIndex, rec) {
				var reqid = rec.get('runningno');
				//if (typeof(reqid)=='undefined'){reqid=rec.get('deliveryno')+rec.get('deliveryitem');}
				for (var i = 0; i < selected1.length; i++) {
					if (reqid == selected1[i]) {
						return;
					}
				}
				selected1.push(reqid);
			});
	
			sm1.on('rowdeselect', function(selMdl, rowIndex, rec) {
				var reqid = rec.get('runningno');
				//if (typeof(reqid)=='undefined'){reqid=rec.get ('deliveryno');}
				for (var i = 0; i < selected1.length; i++) {
					if (reqid == selected1[i]) {
						selected1.remove(reqid);
						return;
					}
				}
			});
		});
	
		Ext.override(Ext.grid.CheckboxSelectionModel, {
			handleMouseDown : function(g, rowIndex, e) {
				if (e.button !== 0 || this.isLocked()) {
					return;
				}
				var view = this.grid.getView();
				if (e.shiftKey && !this.singleSelect && this.last !== false) {
					var last = this.last;
					this.selectRange(last, rowIndex, e.ctrlKey);
					this.last = last; // reset the last     
					view.focusRow(rowIndex);
				} else {
					var isSelected = this.isSelected(rowIndex);
					if (isSelected) {
						this.deselectRow(rowIndex);
					} else if (!isSelected || this.getCount() > 1) {
						this.selectRow(rowIndex, true);
						view.focusRow(rowIndex);
					}
				}
			}
		});

		//磅值修改工具

		function changeWeigh(obj){
			jQuery("#weight").html(obj.value);

		}
	</script>

	<!--页面菜单开始-->
	<p>
		<OBJECT CLASSID="clsid:648A5600-2C6E-101B-82B6-000000000014"
			id="MSComm1" codebase="MSCOMM32.OCX" type="application/x-oleobject"
			style="LEFT: 54px; TOP: 14px;">
			<PARAM NAME="CommPort" VALUE="1">
			<PARAM NAME="DTREnable" VALUE="1">
			<PARAM NAME="Handshaking" VALUE="0">
			<PARAM NAME="InBufferSize" VALUE="256">
			<PARAM NAME="InputLen" VALUE="0">
			<PARAM NAME="NullDiscard" VALUE="0">
			<PARAM NAME="OutBufferSize" VALUE="512">
			<PARAM NAME="ParityReplace" VALUE="?">
			<PARAM NAME="RThreshold" VALUE="1">
			<PARAM NAME="RTSEnable" VALUE="1">
			<PARAM NAME="SThreshold" VALUE="2">
			<PARAM NAME="EOFEnable" VALUE="0">
			<PARAM NAME="InputMode" VALUE="0">
			<PARAM NAME="DataBits" VALUE="8">
			<PARAM NAME="StopBits" VALUE="1">
			<PARAM NAME="BaudRate" VALUE="9600">
			<PARAM NAME="Settings" VALUE="9600,N,8,1">
		</OBJECT>
	</p>
	<div style="width: 100%;height: 140px;">
		<div style="width: 100%;height: 50px;">
			<div id="header" style="width: 100%;">
				<div id="header1" class="header1">
					<h1>METTLER TOLEDO</h1>
				</div>
				<div id="headerzl" class="headerzl">
					<span id="weight" name="weight">0.00</span>
				</div>
				<div id="headerdw" class="headerdw">
					<span>kg</span>

				</div>
				改变磅值
				<input id='inputWeigh' onchange='changeWeigh(this)'>
				</input>
			</div>
		</div>
		<div id="footer" style="width: 100%;height:90px">
			<form id="wForm1" name="wForm1" class="form-row">
				<div class="footer_left" style="width:80%;float:left">

						
								<div class="input-group">
									<span class="input-group-addon">提入单号：</span>
										<input
										class="form-control"
										type="text" id="plate" name="plate" />
								
									&nbsp;&nbsp; <span
										class="input-group-addon">车牌号</span>
										<input
										class="form-control"
										type="text" id="carno1" name="carno1" />
								
									&nbsp;&nbsp; <span
										class="input-group-addon">柜（罐）号</span>
										<input
										class="form-control"type="text" id="ggh" name="ggh" disabled="true" />
								

                </div>
                <br/>
                <div class="input-group input-group-sm">
									&nbsp;&nbsp;&nbsp;&nbsp; <span class="input-group-addon">入重</span> <input
                  class="form-control" type="text" value="0" id="tare" readonly />
									</td>
									&nbsp;&nbsp; <span class="input-group-addon">出重</span> <input
                  class="form-control" type="text" value="0" id="grosswt"
										readonly />
									
								&nbsp;&nbsp; <span class="input-group-addon">净重</span> <input
                class="form-control" type="text" value="0" id="nw" readonly />
								</div>
						</div>
			

					<div style="width:20%;float:right">
              <div class="alert alert-primary" role="alert">
                  This is a primary alert with <a href="#" class="alert-link">an example link</a>. Give it a click if you like.
                </div>
					</div>
				</div>
			</form>
		</div>
		<div id="leftdiv" style="height: 430px;width:88%;float: left">
			<div id="mid1" style="width: 100%;float: left;height:auto"></div>
			<div id="mid2" style="width: 100%;float: left;height:auto"></div>
		</div>
		<div id="right" style="width: 100px;">
			<div class="right_bb"
				style="width: 100px;margin-left:0px;margin-right:0px;">
				<table>
					<!-- 
				<tr>
					<td><input id="weighwg" type="checkbox" onclick="checkweigh(this)"/><span style="font-size:14px">无货柜</span></td>
				</tr>
			 -->
					<tr>
						<td><input id="weighkg" type="checkbox"
							onclick="checkweigh(this)" /><span style="font-size:18px">空柜（罐)</span></td>
					</tr>
					<tr>
						<td><input class="button blue"
							style='background-color:#0095cd' id="inweigh" type="button"
							value="计重" onclick="inweigh();" /></td>
					</tr>
					<tr>
						<!-- <td><input class="button blue" id="outweigh" type="button" value="过磅" onclick="outweigh();onSearch2();"/></td> -->
						<td><input class="button blue"
							style='background-color:#0095cd' id="outweigh" type="button"
							value="过磅" onclick="outweigh();" /></td>
					</tr>
					<tr>
						<td><input class="button blue"
							style='background-color:#0095cd' onclick="getWeight()"
							type="button" value="取磅值" /></td>
					</tr>
					<tr>
						<td><span style="color: red;font-size: 22px;" id="endweight">0</span></td>
					</tr>
					<tr>
						<td><input class="button blue"
							style='background-color:#0095cd' type="button" value="虚拟删除"
							onclick="deleteWeigh()" /></td>
					</tr>
					<tr>
						<td><input class="button blue"
							style='background-color:#0095cd' type="button" value="模拟过磅"
							onclick="virweigh()" /></td>
					</tr>
					<!-- 
				<tr>
					<td><input class="button blue" onclick="getrefobj('plate','','40285a9048f924a70148fd0914770519','','','0');" type="button" value="提暂存单" />
						<input id="zcval" name="zcval" type="hidden" />
					</td>
				</tr>
				-->

				</table>
			</div>
		</div>
	</div>

	</div>
</body>
</html>
<script type="text/javascript">
	function cg(obj) {
		$("#weight").html(obj.value);
	}

	document.onkeydown = function(event) {
		var e = event || window.event || arguments.callee.caller.arguments[0];
		if (e && e.keyCode == 27) { // 按 Esc 
			//要做的事情
		}
		if (e && e.keyCode == 113) { // 按 F2 
			//要做的事情
		}
		if (e && e.keyCode == 13) { // enter 键
			//var weight = $("#plate").val();
			selectedRow1 = new Array();
			selectedRow2 = new Array();
			
			if(weighType!="weighkg"){
				onSearch2();
				var status = checkStatus();
				if (status == "0") {
					return;
				}
			}
			if(weighType=="weighkg"){
				onSearch1();
				
			}
		//	onSearch1();

		}
	};
	//提入单输入校验
	function checkStatus() {
		var status = "0";
		var plate = $("#plate").val();
		var carno = $("#carno1").val();
		if (plate.length == 0) {
			alert("提入单号不能为空");
			return status;
		}
		Ext.Ajax.request({
			url : '/weightJsp/gbcz.jsp',
			params : {
				action : "checkPlate1",
				plate : plate,
				carno : carno

			//配置传到后台的参数
			},
			success : function(response) { //success中用response接受后台的数据
				//alert(response.responseText);
				var result = JSON.parse(response.responseText);
				console.log(result);
				var message = result.message;
				var cp = result.cp;
				if (message.length > 0) {
					alert(message);
				}
				if (cp.length > 0) {
					$("#carno1").val(cp);
				}
				var trdStatus = "";
				(result.trdStatus == "1") ? trdStatus = "存在" : trdStatus = "不存在";
				var ptStatus = "";
				(result.ptStatus == "1") ? ptStatus = "已打印" : ptStatus = "未打印";
				$("#trdStatus").val(trdStatus);
				$("#ptStatus").val(ptStatus);
				status="1";
				onSearch1();


			},
			failure : function() {
				Ext.Msg.show({
					title : '错误提示',
					msg : '访问数据库时发生错误!',
					buttons : Ext.Msg.OK,
					icon : Ext.Msg.ERROR
				});
			}
		});
		return status;

	}




	function noState() {
		if (confirm('是否过磅？')) {
			outweigh();onSearch2();
			return true;
		} else {
			return false;
		}
	}
	function inweigh() {
		var $ = jQuery;
		var plate = $("#plate").val();
		var carno = $("#carno1").val();
		var weight = $("#endweight").html();
		var ggh = $("#ggh").val();

		if (weight == 0) {
			alert("磅值不能为空！");
			return;
		}
		if (weighType == "weighkg") {
			if (carno.length == 0 || ggh.length == 0) {
				alert("空柜（罐）时车牌及柜（罐）号必填！");
				return;
			}
		}else{
			if (plate.length == 0 || carno.length == 0) {
				alert("提入单号、车牌号都为必填！")
				return;
			}
			
		}


		//alert(plate);

		Ext.Ajax.request({
			url : '/weightJsp/gbcz.jsp',
			params : {
				action : "searchJZ",
				plate : plate,
				carno : carno,
				weight : weight,
				ggh : ggh,
				weighType : weighType
			//配置传到后台的参数
			},
			success : function(response) { //success中用response接受后台的数据
				//alert(response.responseText);
				var rt = JSON.parse(response.responseText);
				var message = rt.message;
				if (message.length > 0) {
					alert(message);
				}
				onSearch1();
				reset();

			},
			failure : function() {
				Ext.Msg.show({
					title : '错误提示',
					msg : '访问数据库时发生错误!',
					buttons : Ext.Msg.OK,
					icon : Ext.Msg.ERROR
				});
			}
		});

	}

	function outweigh() {
		var $ = jQuery;
		var plate = $("#plate").val();
		var carno = $("#carno1").val();
		var ggh = $("#ggh").val();
		if (weighType == "weighkg") {
			if (carno.length == 0) {
			alert("车牌不能为空！");
			return;
			}
		}else{
			if (plate.length == 0 || carno.length == 0) {
				alert("提入单号、车牌号都为必填！")
				return;
			}
			
		}


		var weight =$("#endweight").html();

		if (weight == 0) {
			alert("磅值不能为空！");
			return;
		}
	
		//alert(plate);
		Ext.Ajax.request({
			url : '/weightJsp/gbcz.jsp',
			params : {
				action : "insertGB",
				plate : plate,
				carno : carno,
				weight : weight,
				weighType:weighType,
				ggh:ggh
			//配置传到后台的参数
			},
			success : function(response) { //success中用response接受后台的数据
				var rt = JSON.parse(response.responseText);
				var message = rt.message;
				if (message.length > 0) {
					alert(message);
				}
				onSearch1();
				reset();
			},
			failure : function() {
				Ext.Msg.show({
					title : '错误提示',
					msg : '访问数据库时发生错误!',
					buttons : Ext.Msg.OK,
					icon : Ext.Msg.ERROR
				});
			}
		});

	}
	function virweigh() {
		var weight = $("#endweight").html();
		var pla = $("#plate").val();
		var grosswt = '';
		var inweight = '';
		DWREngine.setAsync(false);
		var sql = 'select a.grosswt from uf_lo_spotmanager a where a.ladingno=(select b.requestid from uf_lo_ladingmain b where b.ladingno=\'' + pla + '\')';
		DataService.getValues(sql, {
			callback : function(data) {
				if (data && data.length > 0) {
					grosswt = data[0].grosswt;
				//alert(data[0].grosswt);
				}
			}
		});
		sql = 'select nvl(a.inweight,0) inweight from v_z_pondlog  a  where a.ladingno=\'' + pla + '\'';
		DataService.getValues(sql, {
			callback : function(data) {
				if (data && data.length > 0) {
					inweight = data[0].inweight;
				//alert(data[0].grosswt);
				}
			}
		});
		if (weight == "0") {
			alert("磅值为0，无法过磅！");
		} else if (pla == null || pla == "") {
			alert("过磅失败，请输入提单号！");
		} else {
			if (Math.abs(grosswt * 1 - weight * 1 + inweight * 1) > 100) {
				if (!confirm('本次过磅磅值为' + (weight * 1 - inweight * 1) + '与计划毛重' + grosswt + '两者相差' + (weight * 1 - inweight * 1 - grosswt * 1) + '，请检查差异原因是否继续过磅?')) {
					return;
				}
			}
			try {
				DWREngine.setAsync(false); //设置为同步获取数据
				Ext.Ajax.request({
					url : '/ServiceAction/com.eweaver.app.weight.servlet.Uf_lo_pandAction',
					params : {
						action : "viroutweigh",
						plate : $("#plate").val(),
						weight : weight,
						weighType : weighType
					//配置传到后台的参数
					},
					success : function(response) { //success中用response接受后台的数据
						if ("unable" == response.responseText) {
							alert("过磅失败，请检提入单是否已真实计重或其他原因！");
						}
						if ("noplate" == response.responseText) {
							alert("过磅失败，未完成现场收发货！");
						}
						if ("gbnoplatenum" == response.responseText) {
							alert("过磅失败，过磅数量大于过量上限范围！");
						}
						/*if("roughWeight" == response.responseText){
											alert("过磅失败，磅值不能大于理论毛重！");
										}*/
						/*alert(response.responseText);
						if(parseDouble(response.responseText)>0){
						    	    		var rts = response.responseText;
							alert("过磅失败，磅值不能大于理论毛重差值为["+rts+"]！");
						}*/
						if ("slbj" == response.responseText) {
							alert("请重新填写磅值！");
						} else {
							var arr = response.responseText.split(";;");
							//alert(arr.length);
							//alert(response.responseText);
							if (arr.length = 4) {
								$("#carno").val(arr[0]);
								$("#grosswt").val(arr[1]);
								$("#tare").val(changeTwoDecimal(arr[2]));
								$("#nw").val(changeTwoDecimal(Math.abs(arr[3])));
								//reset();
								var sql1 = 'update uf_lo_ladingmain set ifstatus = \'40288098276fc2120127704884290210\'  where ladingno =\'' + pla + '\'';
								//alert(sql1);
								DataService.executeSql(sql1, {
									callback : function(data) {}
								});
							}
							if (arr[3] < 0 && weighType != "weighwg") {
								alert("过磅失败，请根据单据类型检查出入重差值！");
							}
						}
					},
					failure : function() {
						Ext.Msg.show({
							title : '错误提示',
							msg : '访问数据库时发生错误!',
							buttons : Ext.Msg.OK,
							icon : Ext.Msg.ERROR
						});
					}
				});
				DWREngine.setAsync(true); //设置为同步获取数据
			} catch (e) {
				alert("系统错误，请尽快联系管理员处理！");
			}
		}
		DWREngine.setAsync(true);
	}

	function checksm1() {
		sm1.selectRows(selectedRow1);
	}
	function onDetail(id) {
		var url = "/app/attendance/attendanceDetail.jsp?id=8a8adbb73a632823013a635214e10008";
		onUrl(url, '考勤详细列表', 'tab_8a8adbb73a632823013a635214e10008');
	}

	function onSearch1() {
		var $ = jQuery;
		var o = $('#wForm1').serializeArray();
		var data = {};
		for (var i = 0; i < o.length; i++) {
			if (o[i].value != null && o[i].value != "") {
				data[o[i].name] = o[i].value;
			}
		}
		store1.baseParams = data;
		store1.baseParams.datastatus = '';
		store1.baseParams.isindagate = '';
		store1.load({
			params : {
				plate : $("#plate").val(),
				carno1 : $("#carno1").val(),
				weighType:weighType
			}
		});
		selected1 = [];
		setTimeout(checksm1, 1000);
	}

	function onSearch2() {
		var $ = jQuery;
		var o = $('#wForm1').serializeArray();
		var data = {};
		for (var i = 0; i < o.length; i++) {
			if (o[i].value != null && o[i].value != "") {
				data[o[i].name] = o[i].value;
			}
		}
		store2.baseParams = data;
		store2.baseParams.datastatus = '';
		store2.baseParams.isindagate = '';
		store2.load({
			params : {
				plate : $("#plate").val()
			}
		});
		selected2 = [];
	}
	//磅值清零	
	function reset() {
		$("#endweight").html("0");
	//$("#plate").val("");
	}
	//有柜无柜控制填写
	function checkweigh(obj) {
		
		if (weighType == obj.id) {
			obj.checked = false;
			weighType = "";
		} else {
			obj.checked = true;
			weighType = obj.id;
		}
		if (weighType == "weighkg") {
			$("#plate").val("");
			$("#plate").attr("disabled", true);
			$("#ggh").attr("disabled", false);
		} else {
			$("#ggh").val("");
			$("#plate").attr("disabled", false);
			$("#ggh").attr("disabled", true);
		}
	}
	//取磅值
	function getWeight() {
		$("#endweight").html($("#weight").html());
	}


	//删除原因

	var win = new Ext.Window({
		title : "原因",
		width : 300,
		height : 160,
		closeAction : 'hide',
		plain : true,
		layout : "form",
		defaultType : "textfield",
		labelWidth : 60,
		bodyStyle : "padding-top: 10px; padding-left:10px;",
		modal : true,
		//defaults:{anchor:"100%"},      
		items : [ {
			xtype : "panel", 
			baseCls : "x-plain", 
			layout : "column", 
			html : "<div><textarea style='width:262px;height:75px;' id='reason'></textarea></div>"
		} ],
		buttons : [
			{
				text : "确认",
				handler : function() {
					win.hide();
					try {
						Ext.Ajax.request({
							url : '/ServiceAction/com.eweaver.app.weight.servlet.Uf_lo_pandAction',
							params : {
								action : "deleteweigh",
								plate : $("#plate").val(),
								reason : $("#reason").val()
							},
							success : function(response) { //success中用response接受后台的数据
								//var we = response.responseText;
								if ("unable" == response.responseText) {
									alert("删除失败，已过磅或提单不存在！");
								} else {
									onSearch2();
									var sql1 = 'update uf_lo_ladingmain set ifstatus = \'40288098276fc2120127704884290211\'  where ladingno =\'' + pla + '\'';
									//alert(sql1);
									DataService.executeSql(sql1, {
										callback : function(data) {}
									});
								}
							},
							failure : function() {
								Ext.Msg.show({
									title : '错误提示',
									msg : '访问接口时发生错误!请联系管理员!',
									buttons : Ext.Msg.OK,
									icon : Ext.Msg.ERROR
								});
							}
						});
					} catch (e) {
						alert(e);
					}
				}
			}
		]
	});

	function deleteWeigh() {
		if ($("#plate").val().length < 1) {
			alert("未输入提单号!");
		} else {
			$("#reason").val("");
			win.show();
		}
	}





	function syncWeigh() {
		try {
			Ext.Ajax.request({
				url : '/ServiceAction/com.eweaver.app.sap.iface.WeighSyncAction',
				params : {
					action : "syncWeigh"
				},
				success : function(response) { //success中用response接受后台的数据
					var we = response.responseText;
					if (isnum.test(we)) {
						$("#weight").html(we);
					}
				},
				failure : function() {
					Ext.Msg.show({
						title : '错误提示',
						msg : '访问接口时发生错误!请联系管理员!',
						buttons : Ext.Msg.OK,
						icon : Ext.Msg.ERROR
					});
				}
			});
		} catch (e) {
			alert(e);
		}
	}

	//setInterval(syncWeigh,1000);
</script>


<SCRIPT ID=clientEventHandlersJS LANGUAGE="JScript">
	//重写 mscomm 控件的唯一事件处理代码    
	var wwww = new RegExp("[0-9]");
	var we1 = "";
	var we2 = "";
	var intersize = "",
		intersize1 = "";
	var interobj;
	function checking() {
		if (intersize == intersize1) {
			clearInterval(interobj);
			interobj = null;
			$("#weight").html('0.00');
		} else {
			intersize1 = intersize;
		}
	}

	function MSComm1_OnComm() {
		try {
			if (MSComm1.CommEvent == 1) { //如果是发送事件    
				//window.alert("请读条码");//这句正常，说明发送成功了    
			} else if (MSComm1.CommEvent == 2) { //如果是接收事件  
				intersize = new Date().getTime();
				var we = MSComm1.Input;
				we1 = we2.trim();
				we2 = we.trim();
				if (we2.trim().substr(we2.trim().length - 1) == "0") {
					we = we1 + we2;
					if (we.length > 3) {
						we = we.substring(3).trim();
						var x = we.split("");
						var g = "";
						for (var y in x) {
							var z = x[y];
							if (wwww.test(z)) {
								g += z;
							} else {
								break;
							}
						}
						if (!isNaN(g) && g != "") {

							var _we = parseInt(g);
							//if(_we>0){
							$("#weight").html(_we);
							//}

						}
					}
				}
				if (interobj == null) {
					//interobj = setInterval(checking,500);
				}
			}
		} catch (e) {}
	}

	function changeTwoDecimal(floatvar) {
		var f_x = parseFloat(floatvar);
		if (isNaN(f_x)) {
			//alert('function:changeTwoDecimal->parameter error');
			return "0.00";
		}
		var f_x = Math.round(floatvar * 100) / 100;
		var s_x = f_x.toString();
		var pos_decimal = s_x.indexOf('.');
		if (pos_decimal < 0) {
			pos_decimal = s_x.length;
			s_x += '.';
		}
		while (s_x.length <= pos_decimal + 2) {
			s_x += '0';
		}
		return s_x;
	}

	function printProve() {
		var ladingno = document.getElementById("plate").value;
		$.ajax({
			async : false,
			url : '/cchglogi/weighBridge/printprove.jsp?ladingno=' + ladingno + '&action=checkProve',
			dataType : 'json',
			success : function(response) {
				var p = response.result;
				if (p == '0') {
					alert('没有找到重量证明单和成品交运单!');
				} else {
					if (p == '1') {
						if (confirm('是否打印成品交运单?')) {
							onUrl('/workflow/request/batch_formbaseprintpre.jsp?ladingno=' + ladingno + '&printtype=1', '打印成品交运单', 'batchprint_prove1_' + ladingno);
						}
					} else if (p == '2') {
						if (confirm('是否打印重量证明单?')) {
							onUrl('/workflow/request/batch_formbaseprintpre.jsp?ladingno=' + ladingno + '&printtype=2', '打印重量证明单', 'batchprint_prove2_' + ladingno);
						}
					} else if (p == '12') {
						if (confirm('是否打印成品交运单?')) {
							onUrl('/workflow/request/batch_formbaseprintpre.jsp?ladingno=' + ladingno + '&printtype=1', '打印成品交运单', 'batchprint_prove1_' + ladingno);
						}
						if (confirm('是否打印重量证明单?')) {
							onUrl('/workflow/request/batch_formbaseprintpre.jsp?ladingno=' + ladingno + '&printtype=2', '打印重量证明单', 'batchprint_prove2_' + ladingno);
						}
					}
				}
			},
			failure : function(result) {
				alert(result);
			}
		});
	}
</SCRIPT>


<SCRIPT LANGUAGE="javascript" FOR="MSComm1" EVENT="OnComm">
	// MSComm1控件每遇到 OnComm 事件就调用 MSComm1_OnComm()函数   
	MSComm1_OnComm();
</SCRIPT>
<script language="JavaScript" type="text/JavaScript">  
var isnum =new RegExp("^[0-9]*$");
//打开端口并发送命令程序    
function OpenPort(){
	if(MSComm1.PortOpen==false){  
		MSComm1.PortOpen=true;    
		//MSComm1.Output="R";//发送命令    
	}else{    
	    window.alert ("已经开始接收数据!");    
	}    
}   
function ClosePort(){
	if(MSComm1.PortOpen==true){  
		MSComm1.PortOpen=false;    
	}  
}
OpenPort();
</script>