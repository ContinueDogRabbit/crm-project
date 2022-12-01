package com.study.crm.workbench.service;

import com.study.crm.workbench.domain.Activity;
import com.study.crm.workbench.mapper.ActivityMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Service
public class ActivityServiceImpl implements ActivityService{
    @Autowired
    ActivityMapper activityMapper;
    @Override
    public int saveCreatedActivity(Activity activity) {
        return activityMapper.insertActivity(activity);
    }

    @Override
    public List<Activity> queryActivityByConditonForPage(Map<String, Object> map) {
        return activityMapper.selectActivityByConditionForPage(map);
    }

    @Override
    public int queryCountOfActivityByCondition(Activity activity) {
        return activityMapper.selectCountOfActivityByCondition(activity);
    }

    @Override
    public int deleteActivityByIds(String[] Ids) {
        return activityMapper.deleteActivityByIds(Ids);
    }

    @Override
    public Activity queryActivityById(String id) {
        return activityMapper.selectActivityById(id);
    }

    @Override
    public int updateActivityById(Activity activity) {
        return activityMapper.updateActivityById(activity);
    }

    @Override
    public List<Activity> queryAllActivities() {
        return activityMapper.selectAllActivities();
    }

    @Override
    public int addActivities(List<Activity> list) {
        return activityMapper.insertActivities(list);
    }

    @Override
    public Activity queryActivityByIdForDetail(String id) {
        return activityMapper.selectActivityByIdForDetail(id);
    }
}
