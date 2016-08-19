package com.mapbar.nettop.util;

import com.mapbar.nettop.bean.Consumer;
import com.mapbar.nettop.bean.Provider;

public class StringUtil {
	public static Provider getProviderFromString(String string){
		System.out.println(string);
		Provider provider = new Provider();
		String protocol = string.substring(0,string.indexOf(":"));
		string = string.replaceAll(protocol+"://", "");
		String ip = string.substring(0,string.indexOf(":"));
		string = string.replaceAll(ip+":", "");
		String port = string.substring(0,string.indexOf("/"));
		string = string.replaceAll(port+"/", "");
		String[] params = string.split("&");
		String application = "";
		String interfaceName = "";
		String methods = "";
		String owner = "";
		for (String param : params) {
			if(param.startsWith("application")){
				application = param.substring(param.indexOf("=")+1);
			}
			if(param.startsWith("interface")){
				interfaceName = param.substring(param.indexOf("=")+1);
			}
			if(param.startsWith("methods")){
				methods = param.substring(param.indexOf("=")+1);
			}
			if(param.startsWith("owner")){
				owner = param.substring(param.indexOf("=")+1);
			}
		}
		provider.setApplication(application);
		provider.setInterfaceName(interfaceName);
		provider.setIp(ip);
		provider.setMethods(methods);
		provider.setOwner(owner);
		provider.setPort(port);
		provider.setProtocol(protocol);
		return provider;
	}
	
	public static Consumer getConsumerFromString(String string){
		Consumer consumer = new Consumer();
		string = string.replaceAll("consumer://", "");
		String ip = string.substring(0,string.indexOf("/"));
		string = string.substring(string.indexOf("?")+1);
		String[] params = string.split("&");
		String application = "";
		String interfaceName = "";
		String methods = "";
		for (String param : params) {
			if(param.startsWith("application")){
				application = param.substring(param.indexOf("=")+1);
			}
			if(param.startsWith("interface")){
				interfaceName = param.substring(param.indexOf("=")+1);
			}
			if(param.startsWith("methods")){
				methods = param.substring(param.indexOf("=")+1);
			}
		}
		consumer.setApplication(application);
		consumer.setInterfaceName(interfaceName);
		consumer.setIp(ip);
		consumer.setMethods(methods);
		return consumer;
	}
}
