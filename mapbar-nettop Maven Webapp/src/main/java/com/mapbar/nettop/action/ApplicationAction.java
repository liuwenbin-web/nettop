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

@Controller
@RequestMapping(value="/application")
public class ApplicationAction {
	public static List<ServiceBean> list = null; 
	
	@RequestMapping(value="")
	public ModelAndView application(HttpServletRequest request,HttpServletResponse response) throws Exception{
		System.out.println("application");
		ModelAndView mav = new ModelAndView();
		mav.setViewName("application");
		return mav;
	}
	
	@RequestMapping(value="/single")
	public ModelAndView singleAnalysis(HttpServletRequest request,HttpServletResponse response) throws Exception{
		System.out.println("application");
		ModelAndView mav = new ModelAndView();
		mav.setViewName("singleAnalysis");
		return mav;
	}
	
	@RequestMapping(value="/getApplicationTop")
	public @ResponseBody List<ServiceBean> getApplicationTop(HttpServletRequest request,HttpServletResponse response) throws Exception{
		if(null == list || list.size() == 0){
			list = ServerTop.get();
		}
		//list = ServerTop.get();
		return list;
	}
}
