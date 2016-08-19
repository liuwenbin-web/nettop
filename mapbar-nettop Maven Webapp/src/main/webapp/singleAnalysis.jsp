<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<html>
<head>
<title>dubbo服务拓扑结构_单服务</title>
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
	&nbsp;&nbsp;&nbsp;
	<select id="typeSelect" class="form-control" style="width:200px;display:inline">
		<option value="type">类型</option>
		<option value="provider">provider</option>
		<option value="consumer">consumer</option>
	</select>
	<select id="applicationSelect" class="form-control" style="width:300px;display:inline">
		<option value='application'>应用程序</option>
	</select>
	<hr/>
	<canvas id="canvas"></canvas>
</body>
<script>
	var map = {};
	function init(json){
		$("#typeSelect").val("type");
		$("#applicationSelect").val("application");
		//typeSelect修改事件
		var providerMap = {};
		var consumerMap = {};
		$.each(json,function(i,n){
			var providers = n.providers;
			$.each(providers, function(p_i, p_n){
				if(providerMap[p_n.application] == undefined){
					providerMap[p_n.application] = p_n;
				}
			});
			var consumers = n.consumers;
			$.each(consumers, function(c_i, c_n){
				if(consumers[c_n.application] == undefined){
					consumerMap[c_n.application] = c_n;
				}
			});
		});
		//构建
		var providerOptionStr = "";
		$.each(providerMap,function(application,provider){
			providerOptionStr += "<option value='"+application+"'>"+application+"</option>";
		});
		var consumerOptionStr = "";
		$.each(consumerMap,function(application,consumer){
			consumerOptionStr += "<option value='"+application+"'>"+application+"</option>";
		});
		$("#typeSelect").change(function(){
			if($(this).val() == "type"){
				$("#applicationSelect").html("<option value='application'>应用程序</option>");
			}else if($(this).val() == "provider"){
				$("#applicationSelect").html("<option value='application'>应用程序</option>"+providerOptionStr);
			}else if($(this).val() == "consumer"){
				$("#applicationSelect").html("<option value='application'>应用程序</option>"+consumerOptionStr);
			}
		});
		$("#applicationSelect").change(function(){
			if($(this).val()!="application"){
				draw(json,providerMap,consumerMap);
			}
		});
	}
</script>
<script>
	//初始化canvas的大小
	var offsetX = 20;
	var offsetY = 40;
	var nodeJiangeY = 120;
	var nodeJiangeX = 30;
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
	//画各个node
	function draw(json,providerMap,consumerMap) {
		scene.clear();
		var type = $("#typeSelect").val();
		var application = $("#applicationSelect").val();
		//type = "consumer";
		//application = "mapbar-www-tianqi-consumer";
		if("provider" == type){
			map={};
			var provider = providerMap[application];
			var providerWidth = provider.application.length * 7.5+12*5;
			var providerAppNode = newNode(offsetX+offsetX, offsetY+offsetX, providerWidth, 100, provider.application,provider.application,true);
			map["p_"+provider.application]=providerAppNode;
			//获取该提供者所有的接口
			var serverNodeX = offsetX;
			var serverNodeY = providerAppNode.getBound().bottom + nodeJiangeY;
			var serverNode = null;
			//获取接口名称
			var interfaceMap = {};
			var providerContainerHeight = 0;
			var interfaceContainerY = 0;
			var interfaceAlreadyMap = {};
			$.each(json,function(i,n){
				var providers = n.providers;
				$.each(providers, function(p_i, p_n){
					if(p_n.application == application && interfaceAlreadyMap[p_n.interfaceName]==undefined){
						var width = p_n.interfaceName.length * 7.5+12*5;
						serverNode = newNode(serverNodeX+offsetX, serverNodeY, width, 100, p_n.interfaceName,p_n.interfaceName,true);
						providerContainerHeight = serverNode.getBound().bottom;
						interfaceContainerY = serverNode.getBound().top - offsetX;
						map["p_"+p_n.interfaceName]=serverNode;
						interfaceMap[p_n.interfaceName]=serverNode;
						linkNode(serverNode,providerAppNode,2,false);
						serverNodeX = serverNode.getBound().right + nodeJiangeY;
						interfaceAlreadyMap[p_n.interfaceName] = "";
					}
				});
			});
			//画container
			var providerContainer = newContainer(offsetX, offsetY, width, providerContainerHeight, "provider",true);
			var interfaceContainer = newContainer(offsetX, interfaceContainerY, width, providerContainerHeight - interfaceContainerY + offsetX, "interface",true);
			var consumersMap = {};
			var consumerNodeX = offsetX;
			var linkLineMap = {};
			$.each(interfaceMap,function(interfaceName,node){
				serverNodeY = node.getBound().bottom + nodeJiangeY;
				$.each(json,function(i,n){
					var consumers = n.consumers;
					$.each(consumers, function(c_i, c_n){
						if(c_n.interfaceName == interfaceName){
							var nodeToLink = null;
							if(undefined == consumersMap["c_"+c_n.application]){
								var width = c_n.interfaceName.length * 7.5+12*5;
								//alert(consumerNodeX);
								nodeToLink = newNode(consumerNodeX + offsetX, serverNodeY, width, 100, c_n.application,c_n.application,false);
								map["c_"+c_n.interfaceName]=nodeToLink;
								consumersMap["c_"+c_n.application]=nodeToLink;
								consumerNodeX = nodeToLink.getBound().right + nodeJiangeX;
								//alert(consumerNodeX);
							}else{
								nodeToLink = consumersMap["c_"+c_n.application];
							}
							if(linkLineMap[interfaceName+"-->"+c_n.application] == undefined){
								linkNode(nodeToLink,node,2,true);
								linkLineMap[interfaceName+"-->"+c_n.application] = "";
							}
						}
					});
				});
			});
			//画consumer的container
			var consumerContainer = newContainer(offsetX, serverNodeY - offsetX, width, providerContainerHeight - interfaceContainerY + offsetX, "consumer",false);
		}else if("consumer"==type){
			var map = {};
			var consumer = null;
			var consumerNode = null;
			var interfaceMap = {};
			$.each(json,function(i,n){
				var consumers = n.consumers;
				$.each(consumers, function(c_i, c_n){
					if(c_n.application == application){
						//alreadyConsumer[c_n.application] = c_n;
						if(consumer == null){
							consumer = c_n;
						}
						if(interfaceMap[n.serverName] == undefined){
							interfaceMap[n.serverName] = c_n;
						}
					}
				});
			});
			//画消费者
			var serverNodeX = offsetX;
			var consumerNodeWidth = consumer.application.length * 7.5+12*5;
			consumerNode = newNode(serverNodeX+offsetX, offsetY+offsetX, consumerNodeWidth, 100, consumer.application,consumer.application,false);
			map["c_consumer"] = consumerNode;
			//画接口
			var interfaceNode = null;
			serverNodeX = offsetX;
			var serverNodeY = consumerNode.getBound().bottom + nodeJiangeY;
			var interfaceWidth = null;
			var interfaceNodes = {};
			var alreadyLinkLine = [];
			$.each(interfaceMap,function(interfaceName,consumer){
				var lineKey = consumer.interfaceName + "-->" + application;
				if(interfaceNodes[consumer.interfaceName] == undefined){
					interfaceWidth = consumer.interfaceName.length * 7.5+12*5;
					interfaceNode = newNode(serverNodeX+offsetX, offsetY + serverNodeY, interfaceWidth, 100, consumer.interfaceName,consumer.interfaceName,false);
					map["p_"+consumer.interfaceName] = interfaceNode;
					serverNodeX = interfaceNode.getBound().right + nodeJiangeX;
					interfaceNodes[consumer.interfaceName] = interfaceNode;
				}else{
					interfaceNode = interfaceNodes[consumer.interfaceName];
				}
				//连线
				if($.inArray(lineKey,alreadyLinkLine) == -1){
					linkNode(consumerNode,interfaceNode,2,true);
					alreadyLinkLine.push(lineKey);
				}
			});
			var interfaceProviderMap = {};
			var alreadyLinkProviderAndInterface=[];
			var alreadyProviderMap = {};
			var providerNode = null;
			var providerWidth = null;
			var providerNodeY = interfaceNode.getBound().bottom + nodeJiangeY;
			serverNodeX = offsetX;
			$.each(json,function(i,n){
				var providers = n.providers;
				$.each(providers, function(p_i, p_n){
					if(interfaceMap[p_n.interfaceName]!=undefined){
						var lineKey = p_n.interfaceName +"-->"+p_n.application;
						//判断有没有provider的节点
						if(alreadyProviderMap[p_n.application]==undefined){
							providerWidth = p_n.interfaceName.length * 7.5+12*5;
							providerNode = newNode(serverNodeX+offsetX, providerNodeY, providerWidth, 100, p_n.application, p_n.application,true);
							map["p_"+p_n.application] = interfaceNode;
							serverNodeX = providerNode.getBound().right + nodeJiangeX;
							alreadyProviderMap[p_n.application] = providerNode;
						}else{
							providerNode = alreadyProviderMap[p_n.application];
						}
						//画线
						if($.inArray(lineKey,alreadyLinkProviderAndInterface) == -1){
							linkNode(providerNode,interfaceNodes[p_n.interfaceName],2,false);
							alreadyLinkProviderAndInterface.push(lineKey);
						}
					}
				});
			});
			//画container
			var consumerContainer = newContainer(offsetX, offsetY, width, consumerNode.getBound().bottom, "consumer",false);
			var providerContainer = newContainer(consumerContainer.getBound().left, interfaceNode.getBound().top - offsetY - offsetX, width, providerNode.getBound().bottom - interfaceNode.getBound().top+offsetY+offsetY, "provider",true);
			var interfaceContainer = newContainer(consumerContainer.getBound().left, providerContainer.getBound().top + offsetY, width, interfaceNode.getBound().bottom - interfaceNode.getBound().top+offsetY, "interface",true);
		}
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
		}
		scene.add(link);
		return link;
	}
	$.ajax({
		url : "/application/getApplicationTop",
		type : "POST",
		success : function(json) {
			init(json);
			//draw(json);
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
