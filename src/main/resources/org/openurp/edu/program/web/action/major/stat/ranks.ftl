[@b.head/]
<p style="text-align:center;margin:0px;">${grade.name}级 ${level.name} 培养方案必修/选修学分统计</p>
<div class="container-fluid">
    <table class="grid-table">
      <colgroup>
        <col width="4%"/>
        <col width="5%"/>
        <col width="5%"/>
        <col width="10%"/>
        <col width="5%"/>
        <col width="5%"/>
        [#list minTerm..maxTerm as t]<col width="6.5%"/>[/#list]
        <col width="5%"/>
        [#if hasDesignated]
        <col width="6%"/>
        [/#if]
        <col width="6%"/>
      </colgroup>
      <thead class="grid-head">
        <tr>
          <td rowspan="2">序号</td>
          <td rowspan="2">学科门类</td>
          <td rowspan="2">院系</td>
          <td rowspan="2">专业</td>
          <td rowspan="2">总学分</td>
          <td colspan="${maxTerm-minTerm+1}">必修学分按学期分布</td>
          <td rowspan="2">必修学分</td>
          [#if hasDesignated]
          <td rowspan="2">限选学分</td>
          <td rowspan="2">自由选修学分</td>
          [#else]
          <td rowspan="2">选修学分</td>
          [/#if]
        </tr>
        <tr>
          [#list minTerm..maxTerm as t]<td>${t}学期</td>[/#list]
        </tr>
      </thead>
      <tbody class="grid-body">
      [#list plans as plan]
        [#assign stat = stats.get(plan)/]
      <tr>
        <td>${plan_index+1}</td>
        <td>[#list plan.program.major.disciplines as d]${d.category.name}[#break/][/#list]</td>
        <td>${(plan.program.department.shortName)!plan.program.department.name}</td>
        <td>${plan.program.major.name} ${(plan.program.direction.name)!}</td>
        <td>${plan.credits}</td>
        [#assign compulsoryStat=stat.getCompulsoryStat(true)/]
        [#list minTerm..maxTerm as t]
        <td>[#if (compulsoryStat.termCredits[t-1]!0)>0]${compulsoryStat.termCredits[t-1]}[/#if]</td>
        [/#list]
        <td>[@displayCredits compulsoryStat/]</td>
        [#if hasDesignated]
        <td>[@displayCredits stat.designatedSelectiveStat/]</td>
        [/#if]
        <td>[@displayCredits stat.freeSelectiveStat/]</td>
      </tr>
      [/#list]
    </tbody>
  </table>
</div>

[#macro displayCredits stat]
  [#if stat.credits>0]${stat.credits}[/#if]
[/#macro]
[@b.foot/]
