package com.study.crm.workbench.service;

import com.study.crm.workbench.domain.Activity;

import java.util.List;
import java.util.Map;

public interface ActivityService {
    int saveCreatedActivity(Activity activity);

    List<Activity> queryActivityByConditonForPage(Map<String,Object> map);

    int queryCountOfActivityByCondition(Activity activity);

    int deleteActivityByIds(String[] Ids);

    Activity queryActivityById(String id);

    int updateActivityById(Activity activity);

    List<Activity> queryAllActivities();

    int addActivities(List<Activity> list);

    Activity queryActivityByIdForDetail(String id);
}
