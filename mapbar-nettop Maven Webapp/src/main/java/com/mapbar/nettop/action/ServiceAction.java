package com.mapbar.nettop.action;

import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import com.mapbar.nettop.bean.ServiceBean;
import com.mapbar.nettop.util.ServerTop;

@RequestMapping("/service")
@Controller
public class ServiceAction {
	public static List<ServiceBean> list = null;
	
	@RequestMapping("")
	public ModelAndView service(HttpServletRequest request,HttpServletResponse response){
		ModelAndView mav = new ModelAndView();
		mav.setViewName("service");
		return mav;
	}
	
	@RequestMapping("/getServiceTop")
	public @ResponseBody List<ServiceBean> getServiceTop(HttpServletRequest request,HttpServletResponse response) throws Exception{
		if(null == list || list.size() == 0){
			list = ServerTop.get();
		}
		list = ServerTop.get();
		return list;
	}
}
