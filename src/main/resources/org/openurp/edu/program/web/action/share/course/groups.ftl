[#ftl]
[@b.head/]
[#assign titleName]${plan.fromGrade.code}~${plan.toGrade.code} ${plan.level.name} 课程设置[/#assign]
[@b.toolbar title=titleName]
   bar.addItem("返回列表", "backToList()","action-backward");
   function backToList() {
     bg.form.submit(document.searchForm);
   }
[/@]
[@b.nav class="nav-tabs nav-tabs-compact"]
  [@b.navitem href="plan!edit?id="+plan.id]基本信息[/@]
  [@b.navitem href="!groups?plan.id="+plan.id]课程设置[/@]
[/@]
[#include "../../major/plan/planGroupFunctions.ftl" /]
<link rel="stylesheet" type="text/css" href="${b.base}/static/css/plan.css?v=20230522" />
<script type="text/javascript" charset="utf-8" src="${b.base}/static/edu/program/js/plan.js?v=3"></script>
[@b.messages slash="2"/]
<div class="row">
  <div class="col-3">
  <table id="courseGroupListTable" width="100%" style="font-size: 0.9em;margin-top: 0px;">
    <caption style="caption-side: top;">
    [@b.toolbar title='课程组列表)']
       bar.addItem("新建","addGroup()");
    [/@]
    </caption>
    <tbody>
      [#list plan.groups?sort_by("indexno") as group]
        [#if !(activeGroup??) && group.planCourses?size>0][#assign activeGroup=group/][/#if]
      <tr data-tt-id="node-${group.id}" id="node-${group.id}" [#if group.parent??] data-tt-parent-id='node-${group.parent.id}'[/#if] [#if activeGroup?? && activeGroup==group]class="treeNode-selected"[/#if]>
        <td class='treeNode' style="padding-left:10px;">
          <input type="hidden" name="groupId" value="${group.id}"/>
          [#assign groupName][#if group.givenName??]${group.givenName}[#else]${group.courseType.name}[/#if][/#assign]
          [#if groupName?length>10]
          <span style="font-size:0.8em">${groupName}</span>
          [#else]
          ${groupName}
          [/#if]
          <span style="font-size:0.8em;">[#if group.languange??]${group.languange.name}[/#if] [#if group.courseAbilityRate??]${group.courseAbilityRate.name}[/#if]</span>
        </td>
        <td class='groupButton' width="66px">[@editButton group/][@removeButton group/]</td>
      </tr>
      [/#list]
    </tbody>
  </table>
  </div>
  <div id="group_plan_course_list" class="col-9" ></div>
</div>

[@b.form name="actionForm" action="!groups?plan.id=1"]
    <input type="hidden" name="planId" value="${plan.id}"/>
    <input type="hidden" name="courseGroup.id" value="" />
    <input type="hidden" name="toGroups" value="1" />
[/@]

<div class="modal fade" id="planDialog" tabindex="-1" role="dialog" aria-labelledby="planDialogTitle" aria-hidden="true">
  <div class="modal-dialog modal-lg modal-dialog-centered" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="planDialogTitle"></h5>
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
      <div class="modal-body" id="planDialogBody" style="padding-top:0px;"></div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-dismiss="modal">关闭</button>
        <button type="button" style="display:none" id="planDialogSubmit" class="btn btn-primary">确定</button>
      </div>
    </div>
  </div>
</div>

<!-- PlanCourseFormDiv -->
<div class="modal fade" id="planCourseFormDiv" tabindex="-1" role="dialog" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered" role="document" style="width:900px">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title">设置课程信息 (<span id="planCourse_group_name" class="text-muted" style="font-size:0.8em;"></span>)</h5>
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
      <div class="modal-body">
        <form name="planCourseForm" method="post" action="${b.url('!saveCourse')}">
          <input type="hidden" name="planId" value="${plan.id}"/>
          <input type="hidden" name="planCourse.group.id" value=""/>
          <input type="hidden" name="stage" value=""/>
          <input type="hidden" name="planCourse.id" value=""/>
          <input type="hidden" name="planCourse.course.id" id="planCourse_course_id" value=""/>
          <table width="100%" valign="top" class="grid-table">
            <tr>
             <td class="grayStyle" width="25%">&nbsp;课程代码<font color="red">*</font></td>
             <td class="brightStyle" colspan="3">
                  <input type="text" name="planCourse.course.code" id="planCourse_course_code" value="" readonly size="20" maxlength="20"/>
                  <input type="button" value="选择课程" onclick="openCourseListDialog();"  class="buttonStyle"/>
             </td>
            </tr>
            <tr>
              <td class="grayStyle" width="25%">&nbsp;课程名称<font color="red">*</font></td>
              <td class="brightStyle" colspan="3">
               <span id='planCourse_course_name'></span>&nbsp;
               <span id='planCourse_course_defaultCredits'></span>学分
               <span id='planCourse_course_creditHours'></span>学时
              </td>
            </tr>
            <tr>
              <td class="grayStyle" width="25%">&nbsp;开课院系</td>
              <td class="brightStyle" colspan="3"><span id='planCourse_department_name'></span></td>
            </tr>
            <tr>
             <td class="grayStyle" width="25%">&nbsp;开课学期<font color="red">*</font></td>
             <td class="brightStyle" colspan="3">
                <input type="text" name="planCourse.terms" id="planCourse_terms" size="10" title="开课学期" maxlength="50" value="" onchange="generateTermText(this)"/>
                <span style="font-size:0.8rem;color: #999;">格式为:1或者1,2  *表示不限</span>
             </td>
            </tr>
            <tr>
               <td class="grayStyle" width="25%">&nbsp;是否必修</td>
               <td class="brightStyle" colspan="3">
                 [@b.radios name="planCourse.compulsory" label='' items={'1':'是', '0':'否'} value='0' /]
               </td>
            </tr>
            <tr>
              <td class="grayStyle">&nbsp;备注</td>
              <td class="brightStyle" colspan="3"><textarea name="planCourse.remark" id="planCourse_remark" cols="25" rows="2"></textarea></td>
            </tr>
          </table>
          <input type="hidden" name="planCourse.weekstate" size="10" maxlength="50" value=""/>
          <input type="hidden" name="planCourse.termText" id="planCourse_termText" value=""/>
          <input type="hidden" name="planCourse.idx" style="width:40px" maxlength="3" value=""/>
        </form>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-dismiss="modal">关闭</button>
        <button type="button"  onclick="savePlanCourse();"  class="btn btn-primary">确定</button>
      </div>
    </div>
  </div>
</div>

<script language="javascript">
  var courseGroups = [];
  [#list plan.groups as g]
    courseGroups.push({'id':'${g.id}','name':'${g.courseType.name}','stage':'${(g.stage.name)!}'});
  [/#list]
  jQuery(function() {
    beangle.load(["jquery-treetable","jquery-validity"],function(){
      jQuery('#courseGroupListTable').treetable({initialState : "expanded"});
    });
    jQuery('#courseGroupListTable tbody tr').hover(
      function(event) {
        jQuery('#courseGroupListTable tbody tr').removeClass('treeNode-hover');
        if(this.className.indexOf('treeNode-selected') == -1) {
          jQuery(this).addClass('treeNode-hover');
        }
      },
      function(event) {
        jQuery(this).removeClass('treeNode-hover');
      }
    );
    jQuery('#courseGroupListTable tbody tr').click(function(event) {
      jQuery('#courseGroupListTable tbody tr').removeClass('treeNode-selected');
      jQuery(this).addClass('treeNode-selected');
      arrangeGroupCourses(this.id.substring("node-".length));
    });
  });

  /**保存培养计划中的课程*/
  function savePlanCourse() {
    if(validatePlanCourse()) {
      closePlanCourseDialog();
      bg.form.submit(document.planCourseForm, '${b.url('!saveCourse')}');
    }
  }

  function batchAddPlanCourse(courseGroupId) {
    jQuery("#planCourseFormDiv").modal('hide');
    bg.Go("${b.url("!batchAddForm")}?courseGroup.id="+courseGroupId,"planDialogBody");
    setupPlanDialog("批量添加课程")
    jQuery("#planDialog").modal('show');
  }

  function batchEditPlanCourse(courseGroupId,planCourseIds) {
    jQuery("#planCourseFormDiv").modal('hide');
    bg.Go("${b.url("!batchEditForm")}?courseGroup.id="+courseGroupId+"&planCourseIds="+planCourseIds,"planDialogBody");
    setupPlanDialog("批量修改课程")
    jQuery("#planDialog").modal('show');
  }

  function openCourseListDialog() {
    jQuery("#planCourseFormDiv").modal('hide');
    bg.Go("${b.url("!courses?plan.id=${plan.id}")}","planDialogBody");
    setupPlanDialog("选择课程",chooseCourseToPlanCourse)
    jQuery("#planDialog").modal('show');
  }

  var form = document.actionForm;

  function removeGroup(id) {
    if(false==confirm('确定要删除记录吗?')){
      return;
    }
    form['courseGroup.id'].value = id;
    bg.form.submit(form, '${b.url("!removeGroup?toGroups=1")}');
  }

  function addGroup() {
    bg.form.addInput(form,"courseGroup.id","");
    bg.form.submit(form, '${b.url("!editGroup?toGroups=1")}',"planDialogBody");
    jQuery("#planDialog").modal("show");
  }

  function edit(id) {
    bg.form.addInput(form,"courseGroup.id",id);
    bg.form.submit(form, '${b.url("!editGroup?toGroups=1")}',"planDialogBody");
    jQuery("#planDialog").modal("show");
  }

  function arrangeGroupCourses(id) {
    form['courseGroup.id'].value = id;
    //删除计划课程列表beangle-ui.js增加的隐藏form
    jQuery("#programListFrame>form[action$='ourses']").remove();
    bg.form.submit(form, '${b.url("!groupCourses")}',"group_plan_course_list");
  }
  [#if  activeGroup??]
  arrangeGroupCourses("${activeGroup.id}");
  [/#if]

  function getSelectedId() {
    return jQuery('#courseGroupListTable tbody tr.treeNode-selected :hidden').val() || '';
  }
  function copyCourseGroupSetting() {
    var id = getSelectedId();
    if(id==""||id.indexOf(",")>0||id==null){
      alert("请选择一项");
      return;
    }
    bg.form.addInput(form, "majorPlanCourseGroupId", id);
    bg.form.submit(form, "${b.base}/majorCourseGroup!copyCourseGroupSetting.action");
  }
</script>
[@b.foot/]
