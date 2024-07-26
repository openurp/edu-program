[#ftl]
[@b.head /]

[#assign totalCredits=0/]
[#list courseGroup.planCourses as pc]
  [#assign totalCredits=totalCredits+pc.course.defaultCredits/]
[/#list]
<table class="treetable" style="width:100%;margin:0px;">
  <caption>
  ${courseGroup.indexno} ${courseGroup.courseType.name} ${courseGroup.credits}/${totalCredits}分
  &nbsp;分布:
  [#list courseGroup.termCredits[1..courseGroup.termCredits?length-2]?split(",") as credit]
    <div title="${credit_index+1}学期" style="display:inline-block;padding-right:3px;margin-right:3px; [#if courseGroup.terms.contains((credit_index+1)?int)]color:red;[/#if]">${credit}</div>
  [/#list]
  备注:${courseGroup.remark!'--'}
  </catpion>
</table>

<div id='courseGroupFormDiv' style='float:left; width:100%; clear:both;border:0.5px solid #006CB2'>
    [@b.grid sortable="false" items=courseGroup.orderedPlanCourses var="planCourse"]
        [@b.gridbar]
            bar.addItem("${b.text("action.new")}","newPlanCourse()");
            bar.addItem("${b.text("action.modify")}","editPlanCourse()");
            bar.addItem("${b.text("action.delete")}","removePlanCourse()");
            bar.addItem("批量添加", "openBatchAddCourseDialog()");
            bar.addItem("批量修改", "openBatchEditCourseDialog()");
        [/@]
        [@b.row]
            [@b.boxcol /]
            [@b.col width="15%" title="课程代码" property="course.code"/]
            [@b.col title="课程名称" property="course.name"]
              ${planCourse.course.name}
              [#if planCourse.compulsory]<sup>必</sup>[/#if]
            [/@]
            [@b.col width="7%" title="学分" property="course.defaultCredits"]
              ${planCourse.course.getCredits(planCourse.group.plan.program.level)}
            [/@]
            [#assign cj = (planCourse.course.getJournal(plan.program.grade))!/]
            [@b.col width="8%" title="学时"]
              ${cj.creditHours}
              [#if cj.hours?size>1]<span class="text-muted">([#list cj.hours as h]${h.creditHours}[#sep]+[/#list])</span>[/#if]
            [/@]
            [@b.col width="9%" title="开课学期"]
                ${termHelper.getTermText(planCourse)}
            [/@]
            [@b.col width="10%" title="考核方式"]
               ${(cj.examMode.name)!}
            [/@]
            [@b.col width="10%" title="开课院系"]
               [#assign cj = planCourse.course.getJournal(plan.program.grade)/]
               ${(cj.department.shortName)!((cj.department.name)!'--')}
            [/@]
        [/@]
    [/@]
    <form name="courseGroupForm" action="#" method="post">
        <input type="hidden" name="planId" value="${plan.id}"/>
        <input type="hidden" name="planCourse.group.id" value="${courseGroup.id}"/>
        <input type="hidden" name="courseGroup.id" value="${courseGroup.id}"/>
        <input type="hidden" name="toGroups" value="1" />
    </form>
</div>

<!-- batchAddCourseDialog1 -->
<div class="modal fade" id="batchAddCourseDialog1" tabindex="-1" role="dialog" aria-labelledby="exampleModalCenterTitle" aria-hidden="true">
  <div class="modal-dialog modal-lg modal-dialog-centered" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="exampleModalLongTitle">批量添加</h5>
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
      <div class="modal-body">
        [@b.form name="batchAddCoursePromptForm" title="批量添加课程" target="batchAddCourseListDiv"  action="!batchAddCourses"
            theme='list' onsubmit="return openBatchAddCourseDialog2()"]
            <input name="program.id" value="${plan.program.id}" type="hidden"/>
            [@b.textarea label="" name="courseCodes" cols="40" rows="5" required="true" title="课程代码" comment="多个代码可用空格、逗号、分号、回车分割" /]
        [/@]
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-dismiss="modal">关闭</button>
        <button type="button" onclick="bg.form.submit(document.batchAddCoursePromptForm)" class="btn btn-primary">提交</button>
      </div>
    </div>
  </div>
</div>

<!-- batchAddCourseDialog2 -->
<div class="modal fade" id="batchAddCourseDialog2" tabindex="-1" role="dialog" aria-labelledby="exampleModalCenterTitle" aria-hidden="true">
  <div class="modal-dialog modal-lg modal-dialog-centered" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="exampleModalLongTitle">批量添加</h5>
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
      <div class="modal-body">
        [@b.form name="batchAddCourseForm" action='!batchAddCourses']
                <input type="hidden" name="planId" value="${plan.id}"/>
                <input type="hidden" name="planCourse.group.id" value="${courseGroup.id}"/>
            <div id="batchAddCourseListDiv" style="width:100%;"></div>
        [/@]
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-dismiss="modal">关闭</button>
        <button type="button" onclick="batchAddCourses()" class="btn btn-primary">提交</button>
      </div>
    </div>
  </div>
</div>

<!-- batchEditCourseDialog -->
<div class="modal fade" id="batchEditCourseDialog" tabindex="-1" role="dialog" aria-labelledby="exampleModalCenterTitle" aria-hidden="true">
  <div class="modal-dialog modal-lg modal-dialog-centered" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="exampleModalLongTitle">批量修改</h5>
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
      <div class="modal-body">
         <div id="batchEditCourseListDiv" style="width:100%;">...</div>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-dismiss="modal">关闭</button>
        <button type="button" onclick="batchEditCourses()" class="btn btn-primary">提交</button>
      </div>
    </div>
  </div>
</div>

<!-- courseListDialog -->
<div class="modal fade" id="courseListDialog" tabindex="-1" role="dialog" aria-labelledby="exampleModalCenterTitle" aria-hidden="true">
  <div class="modal-dialog modal-lg modal-dialog-centered" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="exampleModalLongTitle">课程信息</h5>
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
      <div class="modal-body">
       [@b.div id='courseListDiv' href="!courses?plan.id=${plan.id}" style="width:100%"/]
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-dismiss="modal">关闭</button>
        <button type="button" onclick="chooseCourseToPlanCourse()" class="btn btn-primary">确定</button>
      </div>
    </div>
  </div>
</div>

<!-- PlanCourseFormDiv -->
<div class="modal fade" id="planCourseFormDiv" tabindex="-1" role="dialog" aria-labelledby="exampleModalCenterTitle" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="exampleModalLongTitle">设置课程信息</h5>
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
      <div class="modal-body">
        [#include "planCourseForm.ftl" /]
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-dismiss="modal">关闭</button>
        <button type="button"  onclick="savePlanCourse();"  class="btn btn-primary">确定</button>
      </div>
    </div>
  </div>
</div>

[@b.form name="batchEditCoursePromptForm" target="batchEditCourseListDiv" action='!batchEditCourses']
    <input type="hidden" name="planId" value="${plan.id}"/>
    <input type="hidden" name="planCourse.group.id" value="${courseGroup.id}"/>
    <input type="hidden" name="toGroups" value="1"/>
    <input type="hidden" name="planCourseIds" value=""/>
[/@]

<script language="text/javascript">
    beangle.load(["jquery-validity"]);
    var planCourses ={};
    [#list courseGroup.planCourses as pc]
      [#assign c=pc.course/]
      planCourses['pc${pc.id}']={'id':'${pc.id}','terms':'${pc.terms}','termText':'${pc.termText!}','compulsory':${pc.compulsory?c},'course':{'id':'${c.id}','code':'${c.code}','name':'${c.name}','defaultCredits':'${c.defaultCredits}','creditHours':'${c.creditHours}','weekHours':'${c.weekHours}','department':{'id':'${c.department.id}'}}}
    [/#list]
    function batchEditCourses() {
        if(validateBatchCourses(document.batchEditCourseForm)){
            var planCourse_Ids = bg.input.getCheckBoxValues("planCourse.id");
            if(planCourse_Ids==""){
                alert("请选择一个或多个课程");
                return;
            }
            jQuery("input[name=planCourse_Ids]").val(planCourse_Ids);
            closeDialect("batchEditCourseDialog");
            bg.form.submit(document.batchEditCourseForm);
        }
    }
    function batchAddCourses() {
        if(validateBatchCourses(document.batchAddCourseForm)) {
            var courseIds = bg.input.getCheckBoxValues("course.id");
            if(courseIds==""){
                alert("请选择一个或多个课程");
                return;
            }
            jQuery("#courseIds").val(courseIds);
            closeDialect("batchAddCourseDialog2");
            bg.form.submit(document.batchAddCourseForm);
        }
    }

    function openBatchAddCourseDialog2(){
        jQuery("#batchAddCourseDialog1").modal("hide");
        jQuery("#batchAddCourseDialog2").modal("show");
        return true;
    }
    function openBatchAddCourseDialog() {
        document.batchAddCoursePromptForm.courseCodes.value = '';
        jQuery("#batchAddCourseDialog1").modal('show');
    }
    function openBatchEditCourseDialog() {
        var id = bg.input.getCheckBoxValues('planCourse.id');
        if(id == '') {
            alert("请选择一个或多个课程进行操作！");
            return;
        }
        var form = document.batchEditCoursePromptForm;
        bg.form.addInput(form, 'planCourseIds', id);
        bg.form.submit(form, '${b.base}/majorCourseGroup!batchEditCourses.action');
        jQuery("#batchEditCourseDialog").modal("show");
    }
    function openCourseListDialog() {
        jQuery("#planCourseFormDiv").modal('hide');
        jQuery("#courseListDialog").modal('show');
    }
    function openPlanCourseDialog() {
        jQuery("#courseListDialog").modal('hide');
        jQuery("#planCourseFormDiv").modal('show');
    }
    function closePlanCourseDialog() {
        closeDialect("planCourseFormDiv");
    }
    function closeDialect(id){
        jQuery("#"+id).modal('hide');
        jQuery("body>div.modal-backdrop").remove();
    }
    /**
     * 删除培养计划中的课程
     */
    function removePlanCourse() {
        var ids = bg.input.getCheckBoxValues('planCourse.id');
        if (ids == "") {
            alert("请选择数据进行操作!");
            return;
        }
        if (confirm("删除计划内的课程，确认操作？")) {
            var form = document.courseGroupForm;
            bg.form.addInput(form, 'planCourseIds', ids);
            bg.form.submit(form, '${b.url("!removeCourse")}');
        }
    }

    function editPlanCourse() {
      var id = bg.input.getCheckBoxValues('planCourse.id');
      if(id == '' || id.indexOf(',') != -1) {
          alert("请选择一个组内的课程进行操作！");
          return;
      }
      var planCourse=planCourses['pc'+id];
      _fillFormCoursePart(planCourse.course);

      var form = document.planCourseForm;
      form['planCourse.id'].value = planCourse.id;
      form['planCourse.terms'].value = planCourse.terms.replace(/^,/, '').replace(/,$/, '');
      form['planCourse.termText'].value = planCourse.termText;
      if(!form['planCourse.terms'].value) form['planCourse.terms'].value="*";
      if(planCourse.weekstate) form['planCourse.weekstate'].value = planCourse.weekstate;
      jQuery(':radio[name=planCourse\\.compulsory]', form).prop('checked',false);
      if(planCourse.compulsory) {
          jQuery(':radio[name=planCourse\\.compulsory][value=1]', form).prop("checked",true);
      } else {
          jQuery(':radio[name=planCourse\\.compulsory][value=0]', form).prop("checked",true);
      }

      if (null != planCourse.department) {
         jQuery(form['planCourse.department.id']).val(planCourse.department.id);
      }
      if(null != planCourse.remark) {
          jQuery(form['planCourse.remark']).html(planCourse.remark);
      } else {
          jQuery(form['planCourse.remark']).html('');
      }
      openPlanCourseDialog();
    }

    function newPlanCourse() {
        document.planCourseForm["planCourse.id"].value = '';
        document.planCourseForm["planCourse.terms"].value = '';
        clearPlanCourseForm();
        openCourseListDialog();
    }

    function validateBatchCourses(form) {
        var courseIds = jQuery("#courseIds").val().split(',');
        for(var i = 0; i < courseIds.length; i++) {
            var termInput = form['course.' + courseIds[i] + '.terms'];
            termInput.value=termInput.value.replace(/，/g, ',');
        }
        var res = null;
        jQuery.validity.start();

        for(var i = 0; i < courseIds.length; i++) {
            jQuery('#courseTerms' + courseIds[i])
                .assert(
                    function(termInput) {
                        return checkTerms(termInput, ${plan.program.startTerm},${plan.program.endTerm});
                    }
                    ,  '开课学期为数字${plan.program.startTerm}-${plan.program.endTerm}和逗号,组成,不指定学期请输入星号*'
                ).require();
            jQuery('#courseDepartmentId' + courseIds[i]).require();
        }
        res = jQuery.validity.end().valid;
        if(false == res) {
            return false;
        }

        return true;
    }
[#if (flash["message"])??]
    alert("${(flash["message"]?js_string)!}");
[/#if]
</script>
[@b.foot /]
