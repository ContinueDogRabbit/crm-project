package com.study.crm.settings.service;

import com.study.crm.settings.domain.User;

import java.util.List;
import java.util.Map;

public interface UserService {
    User queryUserByLoginActAndPwd(Map<String,Object> map);

    //查找所有lock_state=1的user
    List<User> queryUsersStateEqualsOne();
}
