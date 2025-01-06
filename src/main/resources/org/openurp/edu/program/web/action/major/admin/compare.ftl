[@b.head /]
[@b.toolbar title="对比课程" /]
<div class="container-fluid">
  [@b.form name="compareForm" action="!compare" theme="list"]
    [@b.select items=grades name="grade.id" label="年级" required="true" value=grade/]
    [@b.select items=levels name="level.id" label="层次" required="true" value=level/]
    [@b.select items=allCourseTypes name="courseType.id" label="课程类型" required="true" values=courseTypes! multiple="true"/]
    [@b.formfoot]
      [@b.submit value="对比"/]
    [/@]
  [/@]
  [#if courseTypes?size>0]
  <div>
    <table class="table table-bordered table-striped table-sm" style="text-align: center;">
      <thead style="text-align: center;">
        <tr>
          <th colspan="2" rowspan="2">计划/计划</th>
          [#list departPlans?keys?sort_by('code') as d]
          <th colspan="${departPlans.get(d)?size}">${d.shortName!d.name}</th>
          [/#list]
        </tr>
        <tr>
          [#list plans as plan]
          <th style="min-width: 60px;">${plan.program.major.name} ${(plan.program.direction.name)!}</th>
          [/#list]
        </tr>
      </thead>
      [#assign printDeparts=[]/]
      [#list plans as plan]
      <tr>
        [#if !printDeparts?seq_contains(plan.program.department)]
        <td rowspan="${departPlans.get(plan.program.department)?size}" style="vertical-align: middle;">${plan.program.department.shortName!plan.program.department.name}</td>
        [#assign printDeparts = printDeparts+[plan.program.department]]
        [/#if]
        <td style="min-width: 200px;text-align: left;">${plan_index+1} ${plan.program.major.name} ${(plan.program.direction.name)!}</td>
        [#list plans as plan2]
        [#if plan2.id!=plan.id]
        [#assign r =compareHelper.compare(plan,plan2)/]
          [#if r.allEmpty]<td>-</td>
          [#else]
          <td data-toggle="popover" data-trigger="hover"
             data-content="相同${r.sameCourseCount}门<br>${plan.program.department.name} ${plan.program.major.name} ${(plan.program.direction.name)!} ${r.courseCount1}门<br/>${plan2.program.department.name} ${plan2.program.major.name} ${(plan2.program.direction.name)!} ${r.courseCount2}门">${r.simularity2?string.percent}</td>
          [/#if]
        [#else]
        <td></td>
        [/#if]
        [/#list]
      </tr>
      [/#list]
    </table>
  </div>
  [/#if]
</div>
<script>
    beangle.load(["bootstrap"],function(){
      $('[data-toggle="popover"]').popover({html:true,trigger:"hover"})
    });
</script>
[@b.foot /]
