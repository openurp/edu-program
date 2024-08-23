[#ftl]
[@b.head /]

[#include "planGroupFunctions.ftl" /]
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
    [@b.select label='课程类别' name='courseGroup.courseType.id' items=unusedCourseTypeList?sort_by('name') required="true" value=(courseGroup.courseType.id)! empty="..."  style="width:300px" onchange="changeDefaultAutoAddup(this)"/]
    [@b.textfield label="自定义名称" name="courseGroup.givenName"  value=courseGroup.givenName /]
    [@b.textfield label="顺序号" name="index"  check="match('integer')" value=courseGroup.index required="true"/]
    [#if stages?size>0][@b.select label="学期阶段" name="courseGroup.stage.id"  items=stages value=courseGroup.stage! required="false" /][/#if]
    [@b.select label="课程属性" name="courseGroup.rank.id" id="courseGroup_rank_id" items=ranks value=courseGroup.rank! required="true" onchange="displayCredit(this)"/]
    [@b.textfield label="完成子组" name="courseGroup.subCount"  value=courseGroup.subCount required="true"/]
    [@b.textfield label='要求学分' name='courseGroup.credits' maxlength='6' required='true' check="match('number').greaterThanOrEqualTo(0)" value=courseGroup.credits! /]
    [@b.textfield label='要求学时' name='courseGroup.creditHours' maxlength='6' required='true' check="match('number').greaterThanOrEqualTo(0)" value=courseGroup.creditHours! /]
    [@b.field label="学时分布" required="true"]
       [#assign hours={}/]
       [#assign natureHours = courseGroup.getHours(teachingNatures)/]
       [#list natureHours?keys as n]
          [#assign hours=hours+{'${n.id}':natureHours.get(n)} /]
       [/#list]
       [#list teachingNatures as ht]
        <label for="teachingNature${ht.id}_p">${ht_index+1}.${ht.name}</label>
        <input name="creditHour${ht.id}" style="width:30px" id="teachingNature${ht.id}_p" value="${(hours[ht.id?string])!}">学时
       [/#list]
    [/@]
    [@b.field label="学分分布"]
        [#if plan.program.startTerm>1]
          [#list 1..plan.program.startTerm as term]
          <input type="text" title="第${term}学期" name="credit_${term}" style="width:25px" value="--" disabled />[#t/]
          [/#list]
        [/#if]
        [#list plan.program.startTerm..plan.program.endTerm as term]
           <input type="text" title="第${term}学期" name="credit_${term}" onchange="updateTerm(this.value,${term},true)" style="width:25px;padding:2px" value="${termCredits.get(term)!0}" maxlength="4"/>[#t/]
        [/#list]
        <span id='credit_sum_span'></span>
    [/@]
    [@b.field label="开课学期"]
      <div class="btn-group btn-group-toggle" data-toggle="buttons" style="height: 1.5625rem;">
            [#assign termList=courseGroup.terms.termList/]
            [#list plan.program.startTerm..plan.program.endTerm as term]
          <label style="font-size:0.8125rem !important;padding:2px 8px 0px 8px;" class="btn btn-outline-secondary btn-sm [#if termList?seq_contains(term)]active[/#if]">
          <input type="checkbox" name="term_${term}" value="1" [#if termList?seq_contains(term)]checked="true"[/#if]> ${term}
          </label>
            [/#list]
        </label>
      </div>
    [/@]
    [@b.textfield label='备注' name='courseGroup.remark' maxlength='100' value=courseGroup.remark! style="width:300px"/]
    [@b.formfoot]
        <input type="hidden" name="planId" value="${plan.id}"/>
        <input type="hidden" name="courseGroup.id" value="${(courseGroup.id)!}" />
        <input type="hidden" name="toGroups" value="${Parameters['toGroups']!'0'}" />
        [@b.reset/]
        [@b.submit value="action.submit"/]&nbsp;
    [/@]
[/@]

<script type="text/javascript">
  setupPlanDialog("[#if courseGroup.persisted]设置课程组信息[#else]新建课程组[/#if]");
  jQuery(function() {
    for(var i = ${plan.program.startTerm};i <= ${plan.program.endTerm}; i++){
      if(!document.courseGroupForm["credit_"+i])alert(i);
      updateTerm(document.courseGroupForm["credit_"+i].value,i,false);
      jQuery(':text[name=credit_'+i+']').keyup(function(event) {
        updateGroupCredits();
      });
    }
    displayCredit(document.getElementById("courseGroup_rank_id"));
  })
  var courseTypeOptionals={[#list unusedCourseTypeList as t]"${t.id}":${t.optional?c}[#if t_has_next],[/#if][/#list]};
  function changeDefaultAutoAddup(ele){
    if(courseTypeOptionals[ele.value]){
      jQuery("#courseGroup_rank_id").val("1")
    }else{
      jQuery("#courseGroup_rank_id").val("4")
    }
    displayCredit(document.getElementById('courseGroup_rank_id'));
  }

  function displayCredit(ele){
    var hidden=jQuery(ele).val()=='1';
    [#--从完成子组到开课学期--]
    for(var i=5;i<=9;i++){
      if(hidden){
        jQuery(ele).parents("ol").children("li:nth("+i+")").hide();
      }else{
        jQuery(ele).parents("ol").children("li:nth("+i+")").show();
      }
    }
  }
  function updateTerm(value,termIdx,force){
    var termbox=document.courseGroupForm["term_"+termIdx];
    if(value>0){
      jQuery(termbox).prop('checked',true);jQuery(termbox).parent().addClass("active");
    }else if(force){
      jQuery(termbox).prop('checked',false);jQuery(termbox).parent().removeClass("active");
    }
  }
  function updateGroupCredits() {
    var form=document.courseGroupForm;
    var groupCredits = 0;
    [#list plan.program.startTerm..plan.program.endTerm as term]
        groupCredits += parseFloat(form['credit_' + ${term}].value);
    [/#list]
    if(groupCredits == new Number(form['courseGroup.credits'].value)){
      jQuery("#credit_sum_span").html(groupCredits+"分")
    }else{
      jQuery("#credit_sum_span").html("<label style='color:red'>"+groupCredits+"分</label>")
    }
  }
</script>
