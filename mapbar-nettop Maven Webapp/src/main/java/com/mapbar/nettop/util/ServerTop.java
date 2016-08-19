package com.mapbar.nettop.util;

import java.net.URLDecoder;
import java.util.ArrayList;
import java.util.List;

import com.google.gson.Gson;
import com.mapbar.nettop.bean.Consumer;
import com.mapbar.nettop.bean.Provider;
import com.mapbar.nettop.bean.ServiceBean;
import com.netflix.curator.RetryPolicy;
import com.netflix.curator.framework.CuratorFramework;
import com.netflix.curator.framework.CuratorFrameworkFactory;
import com.netflix.curator.retry.ExponentialBackoffRetry;

public class ServerTop {
	public static List<ServiceBean> get() throws Exception {
		RetryPolicy retryPolicy = new ExponentialBackoffRetry(2000, 3);
		CuratorFramework curatorFramework = CuratorFrameworkFactory.newClient("10.211.55.3:2181,10.211.55.4:2181,10.211.55.5:2181", retryPolicy);
		curatorFramework.start();
		List<String> dubboServices = curatorFramework.getChildren().forPath("/dubbo");
		List<String> consumers = null;
		List<String> providers = null;
		List<ServiceBean> serviceBeans = new ArrayList<ServiceBean>();
		ServiceBean serviceBean = null;
		List<Provider> providerBeans = null;
		List<Consumer> consumerBeans = null;
		for (String string : dubboServices) {
			if("com.alibaba.dubbo.monitor.MonitorService".equals(string)){
				continue;
			}
			serviceBean = new ServiceBean();
			consumerBeans = new ArrayList<Consumer>();
			providerBeans = new ArrayList<Provider>();
			consumers = curatorFramework.getChildren().forPath("/dubbo/"+string+"/consumers");
			providers = curatorFramework.getChildren().forPath("/dubbo/"+string+"/providers");
			System.out.println("provider:");
			for (String provider : providers) {
				providerBeans.add(StringUtil.getProviderFromString(URLDecoder.decode(provider)));
			}
			System.out.println("consumer:");
			for (String consumer : consumers) {
				consumerBeans.add(StringUtil.getConsumerFromString(URLDecoder.decode(consumer)));
			}
			serviceBean.setServerName(string);
			serviceBean.setProviders(providerBeans);
			serviceBean.setConsumers(consumerBeans);
			serviceBean.setProvidersCount(providerBeans.size());
			serviceBean.setConsumersCount(consumerBeans.size());
			serviceBeans.add(serviceBean);
		}
		System.out.println(new Gson().toJson(serviceBeans));
		curatorFramework.close();
		return serviceBeans;
	}
}
