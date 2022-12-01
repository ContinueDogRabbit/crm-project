package com.study.crm.settings.service;

import com.study.crm.settings.mapper.UserMapper;
import com.study.crm.settings.domain.User;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Service
public class UserServiceImpl implements UserService {
    @Autowired
    UserMapper userMapper;
    @Override
    public User queryUserByLoginActAndPwd(Map<String,Object> map) {
        return userMapper.selectUserByLoginActAndPwd(map);
    }

    @Override
    public List<User> queryUsersStateEqualsOne() {
        return userMapper.selectAllUsersStateEqualsOne();
    }
}
