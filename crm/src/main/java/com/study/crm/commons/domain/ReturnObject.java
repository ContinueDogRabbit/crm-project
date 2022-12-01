package com.study.crm.commons.domain;

public class ReturnObject {
    //状态码
    public String code;
    //消息
    public String message;
    //需要返回的对象
    public Object obj;

    public void setCode(String code) {
        this.code = code;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public void setObj(Object obj) {
        this.obj = obj;
    }
}
