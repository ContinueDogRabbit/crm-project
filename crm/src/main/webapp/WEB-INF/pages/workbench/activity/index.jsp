<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <meta charset="UTF-8">
    <%
        pageContext.setAttribute("APP_PATH", request.getContextPath());
    %>
    <link href="${APP_PATH}/jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet"/>
    <link href="${APP_PATH}/jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css"
          rel="stylesheet"/>
    <link href="${APP_PATH}/jquery/bs_pagination-master/css/jquery.bs_pagination.min.css" type="text/css"
          rel="stylesheet"/>
    <script type="text/javascript" src="${APP_PATH}/jquery/jquery-1.11.1-min.js"></script>
    <script type="text/javascript" src="${APP_PATH}/jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
    <script type="text/javascript"
            src="${APP_PATH}/jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
    <script type="text/javascript"
            src="${APP_PATH}/jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>
    <script type="text/javascript"
            src="${APP_PATH}/jquery/bs_pagination-master/js/jquery.bs_pagination.min.js"></script>
    <script type="text/javascript" src="${APP_PATH}/jquery/bs_pagination-master/localization/en.js"></script>

    <script type="text/javascript">

        $(function () {
            //给开始日期和结束日期加上日历,并且readonly
            $(".myDate").datetimepicker({
                language: 'zh-CN',//显示中文
                format: 'yyyy-mm-dd',//显示格式
                minView: "month",//设置只显示到月份
                initialDate: new Date(),//初始化当前日期
                autoclose: true,//选中自动关闭
                todayBtn: true,//显示今日按钮
                clearBtn: true //清除按钮
            });
            //创建按钮的单击事件
            $("#createActivityBtn").click(function () {
                //重置原来的表单项
                $("#createActivityForm").get(0).reset();

                //弹出创建市场的模态窗口
                $("#createActivityModal").modal("show");
            });
            //保存按钮的单击事件
            $("#saveActivityBtn").click(function () {
                //获取表单参数
                var owner = $("#create-marketActivityOwner").val();
                var name = $.trim($("#create-marketActivityName").val());
                var startDate = $("#create-startDate").val();
                var endDate = $("#create-endDate").val();
                var cost = $.trim($("#create-cost").val());
                var description = $.trim($("#create-describe").val());
                //表单验证
                if (!validateForm(owner,name,startDate,endDate,cost,description)){
                    return;
                };
                //发送请求
                $.ajax({
                    url: "${APP_PATH}/workbench/activity/saveCreatedActivity.do",
                    data: {
                        owner: owner,
                        name: name,
                        startDate: startDate,
                        endDate: endDate,
                        cost: cost,
                        description: description
                    },
                    type: "post",
                    dataType: "json",
                    success: function (data) {
                        if (data.code == "1") {
                            //保存成功,隐藏模态框
                            $("#createActivityModal").modal("hide");
                            queryActivityByConditionForPage(1, $("#showPage").bs_pagination("getOption", "rowsPerPage"));
                        }else {
                            alert(data.message);
                        }
                    }
                })
            });
            //首页显示活动记录
            queryActivityByConditionForPage(1, 5);
            //给查询按钮绑定单击事件
            $("#query-btn").click(function () {
                queryActivityByConditionForPage(1, $("#showPage").bs_pagination("getOption", "rowsPerPage"));
            });
            //全选和不全选设置
            $("#checkAll").click(function () {
                $("#query-tbody input[type='checkbox']").prop("checked", this.checked);
            });
            //注意这里子标签不能加上#query-tbody
            $("#query-tbody").on("click", "input[type='checkbox']", function () {
                if ($("#query-tbody input[type='checkbox']").size() == $("#query-tbody input[type='checkbox']:checked").size()) {
                    $("#checkAll").prop("checked", true);//这里true不能是字符串
                } else {
                    $("#checkAll").prop("checked", false);
                }
            });
            //删除按钮绑定事件
            $("#deleteActivityBtn").click(function () {
                if ($("#query-tbody input[type='checkbox']:checked").size() == 0) {
                    alert("请选择需要删除的活动");
                    return;
                }
                if (confirm("确认删除吗")) {
                    var deleteCheckboxes = $("#query-tbody input[type='checkbox']:checked");
                    var ids = ""
                    $.each(deleteCheckboxes, function () {
                        ids += "id=" + this.value + "&";
                    });
                    ids = ids.substring(0, ids.length - 1);
                    $.ajax({
                        url: "${APP_PATH}/workbench/activity/deleteActivityByIds.do",
                        data: ids,
                        type: "post",
                        dataType: "json",
                        success: function (data) {
                            if (data.code=="1"){
                                queryActivityByConditionForPage(1, $("#showPage").bs_pagination("getOption", "rowsPerPage"));
                            }else {
                                alert(data.message);
                            }
                        }
                    })
                }
            });
            //修改按钮绑定事件
            $("#editActivityBtn").click(function () {
                //checkbox设置
                if($("#query-tbody input[type='checkbox']:checked").size()==0){
                    alert("请选择要修改的活动");
                    return;
                }
                if($("#query-tbody input[type='checkbox']:checked").size()>1){
                    alert("一次只能修改一个活动");
                    return;
                }
                //回显activity
                var editId=$("#query-tbody input[type='checkbox']:checked").val();
                $.ajax({
                    url:"${APP_PATH}/workbench/activity/queryActivityById.do",
                    data:{
                        id:editId
                    },
                    type:"post",
                    dataType:"json",
                    success:function (data) {
                        //回显
                        $("#edit-id").val(data.id);
                        $("#edit-marketActivityOwner").val(data.owner);
                        $("#edit-marketActivityName").val(data.name);
                        $("#edit-startDate").val(data.startDate);
                        $("#edit-endDate").val(data.endDate);
                        $("#edit-cost").val(data.cost);
                        $("#edit-description").val(data.description);
                        //弹出模态框
                        $("#editActivityModal").modal("show");
                    }
                })

            });
            //更新按钮绑定事件
            $("#updateActivityBtn").click(function () {
                //获取参数
                var id=$("#edit-id").val();
                var owner=$("#edit-marketActivityOwner").val();
                var name=$.trim($("#edit-marketActivityName").val());
                var startDate=$("#edit-startDate").val();
                var endDate=$("#edit-endDate").val();
                var cost=$.trim($("#edit-cost").val());
                var description=$.trim($("#edit-description").val());
                //表单验证
                if (!validateForm(owner,name,startDate,endDate,cost,description)){
                    return;
                };
                //发送请求
                $.ajax({
                    url:"${APP_PATH}/workbench/activity/updateActivityById.do",
                    data:{
                        id:id,
                        owner:owner,
                        name:name,
                        startDate:startDate,
                        endDate:endDate,
                        cost:cost,
                        description:description
                    },
                    type:"post",
                    dataType:"json",
                    success:function (data) {
                        if (data.code=="1"){
                            $("#editActivityModal").modal("hide");
                            queryActivityByConditionForPage($("#showPage").bs_pagination("getOption", "currentPage"), $("#showPage").bs_pagination("getOption", "rowsPerPage"));
                        }else {
                            alert(data.message);
                        }
                    }
                })
            });
            //导出按钮绑定事件
            $("#exportActivityAllBtn").click(function () {
                window.location.href="${APP_PATH}/workbench/activity/exportAllActivities.do"
            });
            //上传按钮绑定事件
            $("#importActivityBtn").click(function () {
                var fileName=$("#activityFile").val();
                var suffixName=fileName.substring(fileName.lastIndexOf(".")+1).toLocaleLowerCase();
                //验证
                if (suffixName!="xls"){
                    alert("仅支持导入xls文件");
                    return;
                }
                //生成二进制data
                var activityFile=$("#activityFile")[0].files[0]; //真正的file
                var formData=new FormData();
                formData.append("activityFile",activityFile);

                $.ajax({
                    url:"${APP_PATH}/workbench/activity/uploadActivities.do",
                    data:formData,
                    processData:false,//默认true
                    contentType:false,//默认true
                    type:"post",
                    dataType:"json",
                    success:function (data) {
                        if (data.code==1){
                            alert("成功导入了"+data.obj+"条数据");
                            $("#importActivityModal").modal("hide");
                            queryActivityByConditionForPage(1,$("#showPage").bs_pagination("getOption", "rowsPerPage"));
                        }else {
                            alert(data.message);
                        }
                    }
                })
            })
        });

        function queryActivityByConditionForPage(pageNo, pageSize) {
            //获取参数
            var name = $("#query-name").val();
            var owner = $("#query-owner").val();
            var startDate = $("#query-startDate").val();
            var endDate = $("#query-endDate").val();
            //发送请求
            $.ajax({
                url: "${APP_PATH}/workbench/activity/showActivityByConditionForPage.do",
                data: {
                    name: name,
                    owner: owner,
                    startDate: startDate,
                    endDate: endDate,
                    pageNo: pageNo,
                    pageSize: pageSize
                },
                dataType: "json",
                type: "post",
                success: function (data) {
                    //将数据插入到表格
                    var html = "";
                    $.each(data.activities, function (index, activity) {
                        html += "<tr class=\"active\">";
                        html += "<td><input type=\"checkbox\" value=\"" + activity.id + "\"/></td>";
                        html += "<td><a style=\"text-decoration: none; cursor: pointer;\" onclick=\"window.location.href='${APP_PATH}/workbench/activity/detail.do?activityId="+activity.id+"'\">" + activity.name + "</a></td>"
                        html += "<td>" + activity.owner + "</td>";
                        html += "<td>" + activity.startDate + "</td>";
                        html += "<td>" + activity.endDate + "</td>";
                        html += "</tr>";
                    })
                    $("#query-tbody").html(html);
                    //手动计算totalPages
                    var totolPages = 1;
                    totolPages = data.count % pageSize == 0 ? data.count / pageSize : parseInt(data.count / pageSize) + 1;
                    $("#showPage").bs_pagination({
                        currentPage: pageNo,//当前页
                        rowsPerPage: pageSize,//
                        maxRowsPerPage: 100,
                        totalPages: totolPages,
                        totalRows: data.count,

                        visiblePageLinks: 5,//显示的最多分页链接数

                        showGoToPage: true,
                        showRowsPerPage: true,
                        showRowsInfo: true,
                        showRowsDefaultInfo: true,

                        onChangePage: function (event, pageObj) { // returns page_num and rows_per_page after a link has clicked
                            queryActivityByConditionForPage(pageObj.currentPage, pageObj.rowsPerPage)
                        },
                    })
                }
            })
        };
        //表单验证
        function validateForm(owner,name,startDate,endDate,cost,description) {
            if (owner == "") {
                alert("所有者不能为空");
                return false;
            }
            if (name == "") {
                alert("活动名称不能为空");
                return false;
            }
            if (startDate != "" && endDate != "") {
                if (startDate > endDate) {
                    alert("结束日期不能早于开始日期");
                    return false;
                }
            } else {
                alert("日期不能为空");
                return false;
            }
            var costReg = /^(([1-9]\d*)|0)$/;
            if (!costReg.test(cost)) {
                alert("成本必须为非负整数");
                return false;
            }
            if (description == "") {
                alert("描述不能为空");
                return false;
            }
            return true;
        }
    </script>
</head>
<body>

<!-- 创建市场活动的模态窗口 -->
<div class="modal fade" id="createActivityModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 85%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title" id="myModalLabel1">创建市场活动</h4>
            </div>
            <div class="modal-body">

                <form class="form-horizontal" role="form" id="createActivityForm">

                    <div class="form-group">
                        <label for="create-marketActivityOwner" class="col-sm-2 control-label">所有者<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="create-marketActivityOwner">
                                <c:forEach items="${userList}" var="u">
                                    <option value="${u.id}">${u.name}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <label for="create-marketActivityName" class="col-sm-2 control-label">名称<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="create-marketActivityName">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="create-startDate" class="col-sm-2 control-label">开始日期</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control myDate" id="create-startDate" readonly>
                        </div>
                        <label for="create-endDate" class="col-sm-2 control-label">结束日期</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control myDate" id="create-endDate" readonly>
                        </div>
                    </div>
                    <div class="form-group">

                        <label for="create-cost" class="col-sm-2 control-label">成本</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="create-cost">
                        </div>
                    </div>
                    <div class="form-group">
                        <label for="create-describe" class="col-sm-2 control-label">描述</label>
                        <div class="col-sm-10" style="width: 81%;">
                            <textarea class="form-control" rows="3" id="create-describe"></textarea>
                        </div>
                    </div>

                </form>

            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                <button type="button" class="btn btn-primary" id="saveActivityBtn">保存</button>
            </div>
        </div>
    </div>
</div>

<!-- 修改市场活动的模态窗口 -->
<div class="modal fade" id="editActivityModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 85%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title" id="myModalLabel2">修改市场活动</h4>
            </div>
            <div class="modal-body">

                <form class="form-horizontal" role="form">
                    <input type="hidden" id="edit-id">
                    <div class="form-group">
                        <label for="edit-marketActivityOwner" class="col-sm-2 control-label">所有者<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="edit-marketActivityOwner">
                                <c:forEach items="${userList}" var="u">
                                    <option value="${u.id}">${u.name}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <label for="edit-marketActivityName" class="col-sm-2 control-label">名称<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-marketActivityName">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-startDate" class="col-sm-2 control-label">开始日期</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control myDate" id="edit-startDate" readonly>
                        </div>
                        <label for="edit-endDate" class="col-sm-2 control-label">结束日期</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control myDate" id="edit-endDate" readonly>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-cost" class="col-sm-2 control-label">成本</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-cost">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-description" class="col-sm-2 control-label">描述</label>
                        <div class="col-sm-10" style="width: 81%;">
                            <textarea class="form-control" rows="3" id="edit-description"></textarea>
                        </div>
                    </div>

                </form>

            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                <button type="button" class="btn btn-primary" id="updateActivityBtn">更新</button>
            </div>
        </div>
    </div>
</div>

<!-- 导入市场活动的模态窗口 -->
<div class="modal fade" id="importActivityModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 85%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title" id="myModalLabel">导入市场活动</h4>
            </div>
            <div class="modal-body" style="height: 350px;">
                <div style="position: relative;top: 20px; left: 50px;">
                    请选择要上传的文件：<small style="color: gray;">[仅支持.xls]</small>
                </div>
                <div style="position: relative;top: 40px; left: 50px;">
                    <input type="file" id="activityFile">
                </div>
                <div style="position: relative; width: 400px; height: 320px; left: 45% ; top: -40px;">
                    <h3>重要提示</h3>
                    <ul>
                        <li>操作仅针对Excel，仅支持后缀名为XLS的文件。</li>
                        <li>给定文件的第一行将视为字段名。</li>
                        <li>请确认您的文件大小不超过5MB。</li>
                        <li>日期值以文本形式保存，必须符合yyyy-MM-dd格式。</li>
                        <li>日期时间以文本形式保存，必须符合yyyy-MM-dd HH:mm:ss的格式。</li>
                        <li>默认情况下，字符编码是UTF-8 (统一码)，请确保您导入的文件使用的是正确的字符编码方式。</li>
                        <li>建议您在导入真实数据之前用测试文件测试文件导入功能。</li>
                    </ul>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                <button id="importActivityBtn" type="button" class="btn btn-primary">导入</button>
            </div>
        </div>
    </div>
</div>


<div>
    <div style="position: relative; left: 10px; top: -10px;">
        <div class="page-header">
            <h3>市场活动列表</h3>
        </div>
    </div>
</div>
<div style="position: relative; top: -20px; left: 0px; width: 100%; height: 100%;">
    <div style="width: 100%; position: absolute;top: 5px; left: 10px;">

        <div class="btn-toolbar" role="toolbar" style="height: 80px;">
            <form class="form-inline" role="form" style="position: relative;top: 8%; left: 5px;">

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">名称</div>
                        <input class="form-control" type="text" id="query-name">
                    </div>
                </div>

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">所有者</div>
                        <input class="form-control" type="text" id="query-owner">
                    </div>
                </div>


                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">开始日期</div>
                        <input class="form-control myDate" type="text" id="query-startDate" readonly/>
                    </div>
                </div>
                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">结束日期</div>
                        <input class="form-control myDate" type="text" id="query-endDate" readonly>
                    </div>
                </div>

                <button type="button" class="btn btn-default" id="query-btn">查询</button>

            </form>
        </div>
        <div class="btn-toolbar" role="toolbar"
             style="background-color: #F7F7F7; height: 50px; position: relative;top: 5px;">
            <div class="btn-group" style="position: relative; top: 18%;">
                <button type="button" class="btn btn-primary" id="createActivityBtn"><span
                        class="glyphicon glyphicon-plus"></span> 创建
                </button>
                <button type="button" class="btn btn-default" id="editActivityBtn"><span
                        class="glyphicon glyphicon-pencil"></span> 修改
                </button>
                <button type="button" class="btn btn-danger" id="deleteActivityBtn"><span
                        class="glyphicon glyphicon-minus"></span> 删除
                </button>
            </div>
            <div class="btn-group" style="position: relative; top: 18%;">
                <button type="button" class="btn btn-default" data-toggle="modal" data-target="#importActivityModal">
                    <span class="glyphicon glyphicon-import"></span> 上传列表数据（导入）
                </button>
                <button id="exportActivityAllBtn" type="button" class="btn btn-default"><span
                        class="glyphicon glyphicon-export"></span> 下载列表数据（批量导出）
                </button>
                <button id="exportActivityXzBtn" type="button" class="btn btn-default"><span
                        class="glyphicon glyphicon-export"></span> 下载列表数据（选择导出）
                </button>
            </div>
        </div>
        <div style="position: relative;top: 10px;">
            <table class="table table-hover">
                <thead>
                <tr style="color: #B3B3B3;">
                    <td><input type="checkbox" id="checkAll"/></td>
                    <td>名称</td>
                    <td>所有者</td>
                    <td>开始日期</td>
                    <td>结束日期</td>
                </tr>
                </thead>
                <tbody id="query-tbody">
                </tbody>
            </table>
            <div id="showPage"></div>
        </div>
    </div>

</div>
</body>
</html>