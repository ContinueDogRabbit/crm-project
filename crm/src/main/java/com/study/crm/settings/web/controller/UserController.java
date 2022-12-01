package com.study.crm.settings.web.controller;

import com.study.crm.commons.constants.Constants;
import com.study.crm.commons.domain.ReturnObject;
import com.study.crm.commons.utils.DateUtils;
import com.study.crm.settings.domain.User;
import com.study.crm.settings.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.*;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

@Controller
public class UserController {
    @Autowired
    UserService userService;

    @RequestMapping("/settings/qx/user/toLogin.do")
    public String toLogin() {
        return "settings/qx/user/login";
    }

    /**
     * 登录验证
     *
     * @return
     */
    @RequestMapping("/settings/qx/user/login.do")
    public @ResponseBody
    Object login(String loginAct, String loginPwd, String isRemPwd,
                 HttpServletRequest request, HttpServletResponse response, HttpSession session) {
        Map<String, Object> map = new HashMap<>();
        map.put("loginAct", loginAct);
        map.put("loginPwd", loginPwd);
        User user = userService.queryUserByLoginActAndPwd(map);
        ReturnObject returnObject = new ReturnObject();

        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        String nowStr = sdf.format(new Date());
        if (user == null) {
            //用户名或密码错误
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_FAIL);
            returnObject.setMessage("用户名或密码错误");
        } else if (DateUtils.formatDateTime(new Date()).compareTo(user.getExpireTime()) > 0) {
            //用户过期
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_FAIL);
            returnObject.setMessage("用户已过期");
        } else if (user.getLockState().equals("0")) {
            //状态被锁定
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_FAIL);
            returnObject.setMessage("用户状态被锁定");
        } else if (!user.getAllowIps().contains(request.getRemoteAddr())) {
            //ip受限
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_FAIL);
            returnObject.setMessage("用户ip受限");
        } else {
            //登录成功
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
            returnObject.setMessage("登陆成功");

            //登陆成功后 给session一个user 携带当前登录用户的数据
            session.setAttribute(Constants.SESSION_USER, user);
            //登陆成功后，是否记住密码
            if (isRemPwd.equals("true")) {
                //记住密码，下次自动输入密码
                Cookie c1 = new Cookie("loginAct", loginAct);
                c1.setMaxAge(10 * 24 * 60 * 60);//10天
                response.addCookie(c1);
                Cookie c2 = new Cookie("loginPwd", loginPwd);
                c2.setMaxAge(10 * 24 * 60 * 60);//10天
                response.addCookie(c2);
            } else {
                //不记住密码，删除掉之前设置的cookie 覆盖掉
                Cookie c1 = new Cookie("loginAct", "1");
                c1.setMaxAge(0);
                response.addCookie(c1);
                Cookie c2 = new Cookie("loginPwd", "1");
                c2.setMaxAge(0);
                response.addCookie(c2);
            }
        }
        return returnObject;
    }

    /**
     * 用户退出，清空session和cookie，回到首页
     *
     * @param session
     * @param response
     * @return
     */
    @RequestMapping("/settings/qx/user/logout.do")
    public String logout(HttpSession session, HttpServletRequest request,HttpServletResponse response) {
        /*Cookie[] cookies=request.getCookies();
        for (Cookie cookie:cookies){
            System.out.println("key:"+cookie.getName());
            System.out.println("value:"+cookie.getValue());
        }*/
        //删除掉之前设置的cookie 注意cookie的作用域范围/settings/qx/user/ RequestMapping不能随便写
        Cookie c1 = new Cookie("loginAct", "1");
        c1.setMaxAge(0);
        response.addCookie(c1);
        Cookie c2 = new Cookie("loginPwd", "1");
        c2.setMaxAge(0);
        response.addCookie(c2);
        //销毁session
        session.invalidate();
        //redirect后面是url而不是资源文件 下面相当于response.sendRedirect("/crm/")要加项目名 下面只是框架封装自带了项目名
        return "redirect:/";
    }
}
