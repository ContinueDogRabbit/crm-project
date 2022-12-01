package com.study.crm.workbench.web.controller;

import com.study.crm.commons.constants.Constants;
import com.study.crm.commons.domain.ReturnObject;
import com.study.crm.commons.utils.DateUtils;
import com.study.crm.commons.utils.HSSFUtils;
import com.study.crm.commons.utils.UUIDUtils;
import com.study.crm.settings.domain.User;
import com.study.crm.settings.service.UserService;
import com.study.crm.workbench.domain.Activity;
import com.study.crm.workbench.service.ActivityService;
import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartResolver;

import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.*;
import java.util.*;

@Controller
public class ActivityController {
    @Autowired
    UserService userService;
    @Autowired
    ActivityService activityService;

    /**
     * 市场活动首页
     *
     * @param request
     * @return
     */
    @RequestMapping("/workbench/activity/index.do")
    public String index(HttpServletRequest request) {
        List<User> userList = userService.queryUsersStateEqualsOne();
        request.setAttribute("userList", userList);
        return "workbench/activity/index";
    }

    /**
     * 保存市场活动
     *
     * @param activity
     * @param session
     * @return
     */
    @RequestMapping("/workbench/activity/saveCreatedActivity.do")
    public @ResponseBody
    Object saveCreatedActivity(Activity activity, HttpSession session) {
        //封装参数
        activity.setId(UUIDUtils.getUUID());
        activity.setCreateTime(DateUtils.formatDateTime(new Date()));
        activity.setCreateBy(((User) session.getAttribute(Constants.SESSION_USER)).getId());
        //调用Service层方法
        ReturnObject returnObject = new ReturnObject();
        try {
            int result = activityService.saveCreatedActivity(activity);
            if (result > 0) {
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
                returnObject.setMessage("保存成功");
            } else {
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_FAIL);
                returnObject.setMessage("系统繁忙,请稍后重试...");
            }
        } catch (Exception e) {
            e.printStackTrace();
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_FAIL);
            returnObject.setMessage("系统繁忙,请稍后重试...");
        }
        return returnObject;
    }

    /**
     * 按照条件分页查询活动
     *
     * @param activity
     * @param pageNo
     * @param pageSize
     * @return
     */
    @RequestMapping("/workbench/activity/showActivityByConditionForPage.do")
    public @ResponseBody
    Object queryActivityByConditionForPage(Activity activity, Integer pageNo, Integer pageSize) {
        //封装参数
        Map<String, Object> map = new HashMap<>();
        map.put("name", activity.getName());
        map.put("owner", activity.getOwner());
        map.put("startDate", activity.getStartDate());
        map.put("endDate", activity.getEndDate());
        map.put("beginNo", (pageNo - 1) * pageSize);
        map.put("pageSize", pageSize);
        //调用Service方法
        List<Activity> activities = activityService.queryActivityByConditonForPage(map);
        int count = activityService.queryCountOfActivityByCondition(activity);
        //返回参数
        Map<String, Object> retMap = new HashMap<>();
        retMap.put("activities", activities);
        retMap.put("count", count);
        return retMap;
    }

    /**
     * 根据多个id删除activity
     *
     * @param id
     * @return
     */
    @RequestMapping("/workbench/activity/deleteActivityByIds.do")
    public @ResponseBody
    Object deleteActivityByIds(String[] id) {
        ReturnObject returnObject = new ReturnObject();
        //调用service方法
        try {
            int ret = activityService.deleteActivityByIds(id);
            if (ret > 0) {
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
            } else {
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_FAIL);
                returnObject.setMessage("服务器忙,请稍后重试");
            }
        } catch (Exception e) {
            e.printStackTrace();
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_FAIL);
            returnObject.setMessage("服务器忙,请稍后重试");
        }
        //返回对象
        return returnObject;
    }

    /**
     * 根据id查询activity
     *
     * @param id
     * @return
     */
    @RequestMapping("/workbench/activity/queryActivityById.do")
    public @ResponseBody
    Object queryActivityById(String id) {
        Activity activity = activityService.queryActivityById(id);
        return activity;
    }

    /**
     * 根据id更新activity
     *
     * @param activity
     * @return
     */
    @RequestMapping("/workbench/activity/updateActivityById.do")
    public @ResponseBody
    Object updateActivityById(Activity activity, HttpSession session) {
        User user = (User) session.getAttribute(Constants.SESSION_USER);
        //封装参数
        activity.setEditTime(DateUtils.formatDateTime(new Date()));
        activity.setEditBy(user.getId());
        //调用service方法
        ReturnObject returnObject = new ReturnObject();
        try {
            int ret = activityService.updateActivityById(activity);
            if (ret > 0) {
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
            } else {
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_FAIL);
                returnObject.setMessage("服务器忙,请稍后重试");
            }
        } catch (Exception e) {
            e.printStackTrace();
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_FAIL);
            returnObject.setMessage("服务器忙,请稍后重试");
        }
        return returnObject;
    }

    /**
     * 导出所有activity的excle表
     *
     * @param response
     * @throws IOException
     */
    @RequestMapping("/workbench/activity/exportAllActivities.do")
    public void exportAllActivities(HttpServletResponse response) throws IOException {
        //调用service方法
        List<Activity> activityList = activityService.queryAllActivities();

        HSSFWorkbook workbook = new HSSFWorkbook();
        HSSFSheet sheet = workbook.createSheet("市场活动列表");
        HSSFRow row = sheet.createRow(0);
        HSSFCell cell = row.createCell(0);
        cell.setCellValue("活动id");
        cell = row.createCell(1);
        cell.setCellValue("所有者");
        cell = row.createCell(2);
        cell.setCellValue("活动名称");
        cell = row.createCell(3);
        cell.setCellValue("开始日期");
        cell = row.createCell(4);
        cell.setCellValue("结束日期");
        cell = row.createCell(5);
        cell.setCellValue("成本");
        cell = row.createCell(6);
        cell.setCellValue("描述");
        cell = row.createCell(7);
        cell.setCellValue("创建时间");
        cell = row.createCell(8);
        cell.setCellValue("创建人");
        cell = row.createCell(9);
        cell.setCellValue("编辑时间");
        cell = row.createCell(10);
        cell.setCellValue("编辑人");
        for (int i = 0; i < activityList.size(); i++) {
            row = sheet.createRow(i + 1);
            Activity activity = activityList.get(i);
            cell = row.createCell(0);
            cell.setCellValue(activity.getId());
            cell = row.createCell(1);
            cell.setCellValue(activity.getOwner());
            cell = row.createCell(2);
            cell.setCellValue(activity.getName());
            cell = row.createCell(3);
            cell.setCellValue(activity.getStartDate());
            cell = row.createCell(4);
            cell.setCellValue(activity.getEndDate());
            cell = row.createCell(5);
            cell.setCellValue(activity.getCost());
            cell = row.createCell(6);
            cell.setCellValue(activity.getDescription());
            cell = row.createCell(7);
            cell.setCellValue(activity.getCreateTime());
            cell = row.createCell(8);
            cell.setCellValue(activity.getCreateBy());
            cell = row.createCell(9);
            cell.setCellValue(activity.getEditTime());
            cell = row.createCell(10);
            cell.setCellValue(activity.getEditBy());
        }
        /*FileOutputStream out=new FileOutputStream("D:\\JAVAWORK\\crm-project\\crm\\test.xls");
        workbook.write(out);
        out.close();
        workbook.close();

        //将本地文件写入到浏览器
        FileInputStream is=new FileInputStream("D:\\JAVAWORK\\crm-project\\crm\\test.xls");
        byte[] bytes=new byte[1024];
        response.setContentType("application/octet-stream;charset=utf-8");
        response.setHeader("Content-Disposition","attachment;filename=test.xls");
        ServletOutputStream outputStream = response.getOutputStream();
        int len=0;
        while ((len=is.read(bytes))!=-1){
            outputStream.write(bytes,0,len);
        }
        //只关闭自己new的
        is.close();
        outputStream.flush();*/

        //优化代码，提高效率
        response.setContentType("application/x-xls;charset=utf-8");
        response.setHeader("Content-Disposition", "attachment;filename=Activities.xls");
        ServletOutputStream outputStream = response.getOutputStream();
        workbook.write(outputStream);
        workbook.close();
        outputStream.flush();
    }

    /**
     * 上传excel文件，导入功能
     * @param activityFile
     * @param session
     * @return
     * @throws IOException
     */
    @RequestMapping("/workbench/activity/uploadActivities.do")
    public @ResponseBody
    Object uploadActivities(MultipartFile activityFile, HttpSession session) throws IOException {
        User user = (User) session.getAttribute(Constants.SESSION_USER);
        InputStream is = activityFile.getInputStream();
        HSSFWorkbook workbook = new HSSFWorkbook(is);
        HSSFSheet sheet = workbook.getSheetAt(0);

        //封装参数
        List<Activity> activityList = new LinkedList<>();
        HSSFRow row = null;
        HSSFCell cell = null;
        String str = null;
        for (int i = 1; i <= sheet.getLastRowNum(); i++) {
            Activity activity = new Activity();
            //实际业务问题解决不了 折中方案
            activity.setId(UUIDUtils.getUUID());
            activity.setOwner(user.getId());
            activity.setCreateBy(user.getId());
            activity.setCreateTime(DateUtils.formatDateTime(new Date()));

            row = sheet.getRow(i);
            cell = row.getCell(0);
            str = HSSFUtils.getCellValueForStr(cell);
            activity.setName(str);
            cell = row.getCell(1);
            str = HSSFUtils.getCellValueForStr(cell);
            activity.setStartDate(str);
            cell = row.getCell(2);
            str = HSSFUtils.getCellValueForStr(cell);
            activity.setEndDate(str);
            cell = row.getCell(3);
            str = HSSFUtils.getCellValueForStr(cell);
            activity.setCost(str);
            cell = row.getCell(4);
            str = HSSFUtils.getCellValueForStr(cell);
            activity.setDescription(str);

            activityList.add(activity);
        }
        workbook.close();
        //调用service方法
        ReturnObject returnObject = new ReturnObject();
        try {
            int ret = activityService.addActivities(activityList);
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
            returnObject.setObj(ret);
        } catch (Exception e) {
            e.printStackTrace();
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_FAIL);
            returnObject.setMessage("服务器忙,请稍后重试");
        }
        return returnObject;
    }

    /**
     * 查看activity明细功能
     */
    @RequestMapping("/workbench/activity/detail.do")
    public String detail(String activityId,HttpServletRequest request){
        //调用service方法
        Activity activity=activityService.queryActivityByIdForDetail(activityId);
        //传递参数到作用域
        request.setAttribute("activity",activity);
        return "/workbench/activity/detail";
    }
}
