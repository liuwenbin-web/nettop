package com.mapbar.nettop.bean;

import java.util.List;

public class ServiceBean {
	private String serverName;
	private List<Provider> providers;
	private List<Consumer> consumers;
	private int providersCount;
	private int consumersCount;
	
	public String getServerName() {
		return serverName;
	}
	public void setServerName(String serverName) {
		this.serverName = serverName;
	}
	public List<Provider> getProviders() {
		return providers;
	}
	public void setProviders(List<Provider> providers) {
		this.providers = providers;
	}
	public List<Consumer> getConsumers() {
		return consumers;
	}
	public void setConsumers(List<Consumer> consumers) {
		this.consumers = consumers;
	}
	public int getProvidersCount() {
		return providersCount;
	}
	public void setProvidersCount(int providersCount) {
		this.providersCount = providersCount;
	}
	public int getConsumersCount() {
		return consumersCount;
	}
	public void setConsumersCount(int consumersCount) {
		this.consumersCount = consumersCount;
	}
}
