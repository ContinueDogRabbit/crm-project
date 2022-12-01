package test;

import com.study.crm.settings.service.UserService;
import com.study.crm.settings.service.UserServiceImpl;
import org.junit.Test;

import java.util.HashMap;
import java.util.Map;

public class testDao {
    UserService userService=new UserServiceImpl();
    @Test
    public void test(){
        Map<String,Object> map=new HashMap<>();
        map.put("loginAct","张三");
        map.put("loginPwd","yf123");
        System.out.println(userService.queryUserByLoginActAndPwd(map));
    }
}
