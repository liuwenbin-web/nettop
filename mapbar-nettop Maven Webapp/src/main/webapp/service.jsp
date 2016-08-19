<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<html>
<head>
<title>dubbo服务拓扑结构_service</title>
<meta http-equiv="pragma" content="no-cache">
<meta http-equiv="cache-control" content="no-cache">
<meta http-equiv="expires" content="0">
<meta http-equiv="keywords" content="keyword1,keyword2,keyword3">
<meta http-equiv="description" content="This is my page">
<script type="text/javascript" src="/js/jquery-2.2.3.min.js"></script>
<script type="text/javascript" src="/js/jtopo-min.js"></script>
<link rel="stylesheet" type="text/css" href="/css/bootstrap.min.css">
<link rel="stylesheet" type="text/css" href="/css/bootstrap-theme.min.css">
<script type="text/javascript" src="/js/bootstrap.min.js"></script>
</head>

<body>
	<jsp:include page="/temp/nav.jsp"></jsp:include>
	<button class="btn btn-default" id="outputImgBtn">导出图像</button>
	<button class="btn btn-default" id="canMoveBtn">启用拖拽</button>
	<hr/>
	<canvas id="canvas"></canvas>
</body>
<script>
	//初始化canvas的大小
	var map = {};
	var linkMap = {};
	var width = $(document).width();
	var height = $(document).height();
	$("#canvas").attr("width", width);
	$("#canvas").attr("height", height);
	//加载canvas
	var canvas = document.getElementById('canvas');
	var stage = new JTopo.Stage(canvas); // 创建一个舞台对象
	stage.eagleEye.visible = true;
	stage.wheelZoom = 0.85;
	var scene = new JTopo.Scene(stage); // 创建一个场景对象
	scene.backgroundColor = '183,183,183';
	stage.add(scene);
	//画provider和consumer的container
	var consumerContainerX = 10;
	var consumerContainerY = 35;
	var consumerContainerW = width - consumerContainerX * 2;
	var consumerContainerH = (height - 120) / 2 - 20;

	var providerContainerX = 10;
	var providerContainerY = (height - 120) / 2 + consumerContainerY + 20;
	var providerContainerW = width - providerContainerX * 2;
	var providerContainerH = height / 2 - 20;
	var providerContainer = newContainer(providerContainerX, providerContainerY, providerContainerW,providerContainerH, "providers",true);
	var consumerContainer = newContainer(consumerContainerX, consumerContainerY, consumerContainerW,consumerContainerH, "consumers",false);
	var applicationToKey = {};
	//画各个node
	function draw(json) {
		var consumerPianyi = 60;
		var consumerNodeSplit = 60;
		var consumerNodeX = "";
		var consumerNodeY = "";
		var consumerNodeW = 100;
		var consumerNodeH = 100;
		var consumerBeginX = consumerContainerX + consumerPianyi;
		var consumerBeginY = consumerContainerY + (consumerContainerH - consumerNodeH) / 2;
		var everyConsumerX = consumerBeginX;

		var providerPianyi = 60;
		var providerNodeSplit = 60;
		var providerNodeX = "";
		var providerNodeY = "";
		var providerNodeW = 100;
		var providerNodeH = 100;
		var providerBeginX = providerContainerX + providerPianyi;
		var providerBeginY = providerContainerY + (providerContainerH - providerNodeH) / 2;
		var everyProviderX = providerBeginX;
		var serverName = "";
		var providerHead = "p_";
		var consumerHead = "c_";
		var providerKey = "";
		var consumerKey = "";
		var endConsumerNode = "";
		var endProviderNode = "";
		var h = false;
		var toArr = {};
		var fromArr = {};
		$.each(json,function(i, n) {
			serverName = n.serverName;
			//遍历providers
			var providers = n.providers;
			$.each(providers, function(p_i, p_n) {
				//如果不存在，画节点
				providerKey = providerHead + p_n.interfaceName +"_"+ p_n.application;
				if (undefined == map[providerKey]) {
					//额为再加5个汉字的大小
					providerNodeW = p_n.interfaceName.length * 7.5+12*5;
					var text = texts(["应用名称："+p_n.application,"接口名称："+p_n.interfaceName,"服务IP："+p_n.ip],providerNodeW,true);
					var afterText = texts(["应用名称："+p_n.application,"接口名称："+p_n.interfaceName,"接口提供者个数："+n.providersCount,"调用方法："+p_n.methods,"服务IP："+p_n.ip,"服务端口："+p_n.port,"协议名称："+p_n.protocol,"开发者："+p_n.owner],providerNodeW,true);
					map[providerKey] = newNode(everyProviderX,providerBeginY, providerNodeW,providerNodeH, text,afterText,true);
					endProviderNode = map[providerKey]; 
					everyProviderX += providerNodeW + providerNodeSplit;
					if(applicationToKey[p_n.application]==undefined){
						applicationToKey[p_n.application] = providerKey;
					}else{
						applicationToKey[p_n.application] = applicationToKey[p_n.application] +","+ providerKey;
					}
				}
				toArr[providerKey] = map[providerKey];
			});
			//遍历消费者
			var consumers = n.consumers;
			$.each(consumers, function(c_i, c_n) {
				//如果不存在，画节点
				consumerKey = consumerHead + c_n.interfaceName +"_"+ c_n.application;
				if (undefined == map[consumerKey]) {
					//额为再加5个汉字的大小
					consumerNodeW = c_n.interfaceName.length * 7.5+12*5;
					var text = texts(["应用名称："+c_n.application,"接口名称："+c_n.interfaceName,"服务IP："+c_n.ip],consumerNodeW,false);
					var afterText = texts(["应用名称："+c_n.application,"服务IP："+c_n.ip,"接口名称："+c_n.interfaceName,"接口消费者个数："+n.consumersCount,"调用方法："+c_n.methods],consumerNodeW,false);
					map[consumerKey] = newNode(everyConsumerX,consumerBeginY, consumerNodeW,consumerNodeH, text,afterText,false);
					endConsumerNode = map[consumerKey];
					everyConsumerX += consumerNodeW + consumerNodeSplit;
					if(applicationToKey[c_n.application]==undefined){
						applicationToKey[c_n.application] = consumerKey;
					}else{
						applicationToKey[c_n.application] = applicationToKey[c_n.application] +","+ consumerKey;
					}
				}
				fromArr[consumerKey] = map[consumerKey];
			});
			//画线
			$.each(fromArr,function(fromService,fromNode){
				$.each(toArr,function(toService,toNode){
					if(linkMap[fromService+"-->"+toService] == undefined){
						linkNode(fromNode, toNode, 2,true);
						linkMap[fromService+"-->"+toService]="";
					}
				});
			});
			fromArr={};
			toArr={};
			/*if (map[providerKey.replace(providerHead,consumerHead)] != undefined) {
				var otherKey = providerKey.replace(providerHead, consumerHead);
				if(linkMap[providerKey+"-->"+otherKey] == undefined){
					linkNode(map[providerKey], map[otherKey],2, false);
					linkNode(map[providerKey], map[otherKey],2, false);
					linkMap[providerKey+"-->"+otherKey]="";
				}
			}*/
		});
		//重新绘制container的边界
		var maxContainerRight = width;
		if("" != endConsumerNode && "" != endProviderNode){
			var maxEndConsumerNodeRight = endConsumerNode.getBound().right+consumerPianyi;
			var maxEndProviderNodeRight = endProviderNode.getBound().right+providerPianyi;
			if(maxEndProviderNodeRight > maxEndConsumerNodeRight){
				maxContainerRight = maxEndProviderNodeRight;
			}else{
				maxContainerRight = maxEndConsumerNodeRight;
			}
		}
		providerContainer.setBound(providerContainerX, providerContainerY, maxContainerRight,providerContainerH);
		consumerContainer.setBound(consumerContainerX, consumerContainerY, maxContainerRight,consumerContainerH);
	}
	function texts(textArr,providerNodeW,isProvider){
		var textStr = "";
		for(var i = 0;i < textArr.length;i++){
			textStr += textArr[i] + textSplit(providerNodeW,i,textArr.length,isProvider);
		}
		return textStr;
	}
	function textSplit(providerNodeW,index,total,isProvider){
		var x = providerNodeW/2 - 20;
		if(isProvider){
			index = 16 * index - 6*total;
		}else{
			index = 16 * index - 5*total;
		}
		return "&-"+x+"&"+index+"@";
	}
	function newContainer(x, y, width, height, text,isProvider) {
		var container = new JTopo.Container(text);
		container.textPosition = 'Top_Left';
		container.fontColor = '42,42,42';
		container.setBound(x, y, width, height);
		container.font = '20pt 微软雅黑';
		container.borderColor = '255,0,0';
		if(isProvider){
			container.fillColor = '252,244,191';
		}else{
			container.fillColor = '252,248,213';
		}
		container.borderRadius = 30; // 圆角
		container.dragable = false;
		scene.add(container);
		return container;
	}
	function newNode(x, y, w, h, text,afterText,isProvider) {
		var node = new JTopo.Node(text);
		node.setBound(x,y,w,h);
		node.dragable = false;
		if(isProvider){
			node.fillColor = "31,139,249";			
		}else{
			node.fillColor = "102,175,249";
		}
		node.textPosition = "Middle_Center";
		scene.add(node);
		var dbl = false;
		node.dbclick(function(event){                
			if(!dbl){
				var size = afterText.split("&-").length;
				node.setBound(x,y-size*5,w,h+size*8);
				node.text=afterText;
				dbl = true;
			}else{
				node.setBound(x,y,w,h);
				node.text=text;
				dbl = false;
			}
        });
		node.click(function(event){
			//先将所有的node的背景色进行修改为原色
			$.each(map,function(key,value){
				if(key.indexOf("p_")!=-1){
					value.fillColor = "31,139,249";	
				}else{
					value.fillColor = "102,175,249";
				}
			});
			//node.fillColor = "251,134,0";
			var nodeText = node.text;
			nodeText = nodeText.substr(nodeText.indexOf("应用程序：")+6,nodeText.length);
			var applicationName = nodeText.substr(0,nodeText.indexOf("&"));
			var keys = applicationToKey[applicationName].split(",");
			for(var i = 0;i < keys.length;i++){
				map[keys[i]].fillColor = "251,134,0";
			}
		});
		return node;
	}
	function linkNode(nodeA, nodeZ, f, showArrow) {
		var link;
		if (f == 1) {
			link = new JTopo.FoldLink(nodeA, nodeZ);
		} else if (f == 2) {
			link = new JTopo.Link(nodeA, nodeZ);
		}
		link.direction = 'vertical';
		if (showArrow) {
			link.arrowsRadius = 10;
		}else{
			link.strokeColor = '88,91,109';
		}
		scene.add(link);
		return link;
	}
	$.ajax({
		url : "/service/getServiceTop",
		type : "POST",
		success : function(json) {
			draw(json);
		}
	});
	$("#outputImgBtn").click(function(){
		stage.saveAsLocalImage();
	});
	$("#canMoveBtn").click(function(){
		if($(this).html()=="启用拖拽"){
			$.each(map,function(key,value){
				value.dragable = true;
			});
			$(this).html("停用拖拽");
		}else{
			$.each(map,function(key,value){
				value.dragable = false;
			});
			$(this).html("启用拖拽");
		}
	});
</script>
</html>
