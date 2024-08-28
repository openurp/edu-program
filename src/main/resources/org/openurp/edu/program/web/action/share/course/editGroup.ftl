[#ftl]
[@b.head /]

[#include "../../major/plan/planGroupFunctions.ftl" /]
<style>
    select { width:100px; }
    .credit_term{width:30px;border-color:#FFF;border-style:solid;}
</style>
[#assign parents = [] /]
[#list parentCourseGroupList?sort_by("indexno") as p_group]
    [#assign p_name][@drawTreeLineSimple p_group /]${p_group.courseType.name?html}[#if p_group.givenName??]-${p_group.givenName}[/#if][/#assign]
    [#assign parents = parents + [{'id' : p_group.id , 'name' : p_name, 'enName' : p_name }] /]
[/#list]

[@b.form name='courseGroupForm' action='!saveGroup' theme='list' onsubmit="closeDialog('planDialog')"]
    [@b.select label='上级课程组' name='newParentId' value=(courseGroup.parent.id)! items=parents empty="..."  style="width:300px"/]
    [@b.select label='课程类别' name='courseGroup.courseType.id' items=unusedCourseTypeList?sort_by('name') required="true" value=(courseGroup.courseType.id)! empty="..."  style="width:300px"/]
    [@b.textfield label="顺序号" name="index"  check="match('integer')" value=courseGroup.index required="true"/]
    [@b.select label="外语要求" name="courseGroup.languange.id" items=languanges value=courseGroup.languange!/]
    [@b.select label="能力等级" name="courseGroup.courseAbilityRate.id" items=abilityRates value=courseGroup.courseAbilityRate!/]

    [@b.textfield label='备注' name='courseGroup.remark' maxlength='100' value=courseGroup.remark! style="width:300px"/]
    [@b.formfoot]
        <input type="hidden" name="planId" value="${plan.id}"/>
        <input type="hidden" name="courseGroup.id" value="${(courseGroup.id)!}" />
        [@b.reset/]
        [@b.submit value="action.submit"/]&nbsp;
    [/@]
[/@]

<script type="text/javascript">
  setupPlanDialog("[#if courseGroup.persisted]设置课程组信息[#else]新建课程组[/#if]");
</script>
