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
  [#list courseGroup.termCreditSeq as credit]
    <div title="${credit_index+1}学期" style="display:inline-block;padding-right:3px;margin-right:3px; [#if !courseGroup.terms.contains((credit_index+1)?int) && credit > 0 || courseGroup.terms.contains((credit_index+1)?int) && credit = 0]color:red;[/#if]">${credit}</div>
  [/#list]
  备注:${courseGroup.remark!'--'}
  </caption>
</table>

[@b.grid sortable="false" items=courseGroup.orderedPlanCourses var="planCourse" style="border:0.5px solid #006CB2"]
  [@b.gridbar]
    bar.addItem("添加","addCourse()");
    bar.addItem("${b.text("action.modify")}","editCourse()");
    bar.addItem("${b.text("action.delete")}",action.multi("removeCourse",'删除计划内的课程，确认操作？'));
    bar.addItem("批量添加", "batchAdd()");
    bar.addItem("批量修改", "batchEdit()");
  [/@]
  [@b.row]
    [@b.boxcol /]
    [@b.col width="15%" title="课程代码" property="course.code"/]
    [@b.col title="课程名称" property="course.name"]
      ${planCourse.course.name}
      [#if planCourse.compulsory]<sup>必</sup>[/#if]
      [#if planCourse.stage??]<sup>${planCourse.stage.name}</sup>[/#if]
    [/@]
    [@b.col width="7%" title="学分" property="course.defaultCredits"]
      ${planCourse.course.getCredits(planCourse.group.plan.program.level)}
    [/@]
    [#assign cj = (planCourse.course.getJournal(plan.program.grade))!/]
    [@b.col width="8%" title="学时"]
      [#if cj.weeks??]${cj.weeks}周[#else]
        ${cj.creditHours}
        [#if cj.hours?size>1]<span class="text-muted">([#list cj.hours as h]${h.creditHours}[#sep]+[/#list])</span>[/#if]
      [/#if]
    [/@]
    [@b.col width="11%" title="开课学期"]
        ${termHelper.getTermText(planCourse)}
    [/@]
    [@b.col width="8%" title="考核方式"]
       ${(cj.examMode.name)!}
    [/@]
    [@b.col width="10%" title="开课院系"]
       [#assign cj = planCourse.course.getJournal(plan.program.grade)/]
       ${(cj.department.shortName)!((cj.department.name)!'--')}
    [/@]
  [/@]
[/@]

<script language="text/javascript">
    beangle.load(["jquery-validity"]);
    var planCourses ={};
    [#list courseGroup.planCourses as pc]
      [#assign c=pc.course/]
      planCourses['pc${pc.id}']={'id':'${pc.id}','groupId':'${pc.group.id}','terms':'${pc.terms}','compulsory':${pc.compulsory?c},'course':{'id':'${c.id}','code':'${c.code}','name':'${c.name}','defaultCredits':'${c.defaultCredits}','creditHours':'${c.creditHours}','weekHours':'${c.weekHours}','department':{'id':'${c.department.id}','name':'${c.department.name}'}},'termText':'${(pc.termText!"")?js_string}','remark':'${(pc.remark!"")?js_string}','idx':'${pc.idx}'[#if pc.stage??],'stageId':'${pc.stage.id}'[/#if]}
    [/#list]
    function editCourse(){
      jQuery("#planDialogBody").html("");//否则影响这个选择
      var id = bg.input.getCheckBoxValues('planCourse.id');
      if(id == '' || id.indexOf(',') != -1) {
        alert("请选择一个组内的课程进行操作！");
        return;
      }
      editPlanCourse(id,'${courseGroup.id}');
    }
    function addCourse(){
      addPlanCourse('${courseGroup.id}');
    }
    function batchAdd() {
      batchAddPlanCourse('${courseGroup.id}');
    }
    function batchEdit() {
      jQuery("#planDialogBody").html("");//否则影响这个选择
      var ids = bg.input.getCheckBoxValues('planCourse.id');
      if(ids == '') {
        alert("请选择一个或多个课程进行操作！");
        return;
      }
      batchEditPlanCourse('${courseGroup.id}',ids);
    }
</script>
[@b.foot /]
