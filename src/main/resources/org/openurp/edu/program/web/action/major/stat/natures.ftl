[@b.head/]
<p style="text-align:center;margin:0px;">${grade.name}级 培养方案学分学时统计
[#if (request.getHeader('x-requested-with')??) || Parameters['x-requested-with']??]
  [@b.a href="!natures?grade.id="+grade.id target="_blank" class="notprint"]<i class="fas fa-print"></i>打印[/@]&nbsp;&nbsp;
  [@b.a href="!natureExcel?grade.id="+grade.id target="_blank" class="notprint"]<i class="fas fa-file-excel"></i>导出[/@]
[/#if]
</p>
<div class="container">
    <table class="grid-table">
      <colgroup>
        <col width="4%"/>
        <col width="5%"/>
        <col width="5%"/>
        <col width="5%"/>
        <col />
        <col width="6.5%"/>
        <col width="6.5%"/>
        <col width="6.5%"/>
        <col width="6.5%"/>
        <col width="6.5%"/>
        <col width="6.5%"/>
        <col width="6.5%"/>
        <col width="6.5%"/>
        <col width="6.5%"/>
        <col width="6.5%"/>
      </colgroup>
      <thead class="grid-head">
        <tr>
          <td rowspan="3">序号</td>
          <td rowspan="3">培养层次</td>
          <td rowspan="3">学科门类</td>
          <td rowspan="3">院系</td>
          <td rowspan="3">专业</td>
          <td colspan="5">学分数</td><td colspan="5">学时数</td>
        </tr>
        <tr>
          <td rowspan="2">总学分</td><td colspan="2">其中1：</td><td colspan="2">其中2：</td>
          <td rowspan="2">总学时</td><td colspan="2">其中1：</td><td colspan="2">其中2：</td>
        </tr>
        <tr>
          <td>必修</td>
          <td>选修</td>
          <td>理论</td>
          <td>实践</td>
          <td>必修</td>
          <td>选修</td>
          <td>理论</td>
          <td>实践</td>
        </tr>
      </thead>
      <tbody class="grid-body">
      [#list plans as plan]
        [#assign stat = stats.get(plan)/]
      <tr>
        <td rowspan="2">${plan_index+1}</td>
        <td rowspan="2">${plan.program.level.name}</td>
        <td rowspan="2">[#list plan.program.major.disciplines as d]${d.category.name}[#break/][/#list]</td>
        <td rowspan="2">${(plan.program.department.shortName)!plan.program.department.name}</td>
        <td rowspan="2">${plan.program.major.name} ${(plan.program.direction.name)!}</td>
        <td rowspan="2">${plan.credits}</td>
        [#assign compulsoryStat=stat.getCompulsoryStat(true)/]
        [#assign optionalStat=stat.optionalStat/]
        [#assign theoreticalStat=stat.theoreticalStat/]
        [#assign practicalStat=stat.practicalStat/]
        [#assign practicalCredits = stat.practicalCredits/]

        <td>${compulsoryStat.credits}</td>
        <td>${optionalStat.credits}</td>
        <td>${(plan.credits - practicalCredits)?string("##.#")}</td>
        <td>${practicalCredits?string("##.#")}</td>
        <td rowspan="2">${plan.creditHours}</td>
        <td>${compulsoryStat.hours}</td>
        <td>${optionalStat.hours}</td>
        <td>${theoreticalStat.getHour("1")}</td>
        <td>${practicalStat.getHour("9")}</td>
      </tr>
      [#assign totalHours = plan.creditHours/]
      <tr>
        <td>${(compulsoryStat.credits*1.0/plan.credits)?string("##.00%")}</td>
        <td>${(optionalStat.credits*1.0/plan.credits)?string("##.00%")}</td>
        <td>${((plan.credits - practicalCredits)*1.0/plan.credits)?string("##.00%")}</td>
        <td>${(practicalCredits/plan.credits)?string("##.00%")}</td>
        <td>[#if totalHours>0]${(compulsoryStat.hours*1.0/plan.creditHours)?string("##.00%")}[/#if]</td>
        <td>[#if totalHours>0]${(optionalStat.hours*1.0/plan.creditHours)?string("##.00%")}[/#if]</td>
        <td>[#if totalHours>0]${(theoreticalStat.getHour("1")*1.0/plan.creditHours)?string("##.00%")}[/#if]</td>
        <td>[#if totalHours>0]${(practicalStat.getHour("9")*1.0/plan.creditHours)?string("##.00%")}[/#if]</td>
      </tr>
      [/#list]
    </tbody>
  </table>
</div>
[@b.foot/]
