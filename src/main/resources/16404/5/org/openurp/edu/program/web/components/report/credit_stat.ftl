    <table class="doc-table" style="page-break-inside: avoid;">
      <caption style="caption-side: top;text-align: center;padding: 0px;">表 ${doc_table_index}：本专业学分学时结构</caption>
      [#assign doc_table_index = doc_table_index+1/]
      <thead style="font-weight:bold;">
        <tr>
          <td rowspan="3">分类</td><td colspan="5">学分数</td><td colspan="5">学时数</td>
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
      <tbody>
      <tr>
        <td>小计</td>
        <td>${plan.credits}</td>
        [#assign compulsoryStat=stat.getCompulsoryStat(true)/]
        [#assign optionalStat=stat.optionalStat/]
        [#assign theoreticalStat=stat.theoreticalStat/]
        [#assign practicalStat=stat.practicalStat/]
        [#assign practicalCredits = stat.practicalCredits/]

        <td>${compulsoryStat.credits}</td>
        <td>${optionalStat.credits}</td>
        <td>${(plan.credits - practicalCredits)?string("##.#")}</td>
        <td>${practicalCredits?string("##.#")}</td>
        <td>${plan.creditHours}</td>
        <td>${compulsoryStat.hours}</td>
        <td>${optionalStat.hours}</td>
        <td>${theoreticalStat.getHour("1")}</td>
        <td>${practicalStat.getHour("9")}</td>
      </tr>
      [#assign totalHours = plan.creditHours/]
      <tr>
        <td>比重</td>
        <td>100%</td>
        <td>${(compulsoryStat.credits*1.0/plan.credits)?string("##.00%")}</td>
        <td>${(optionalStat.credits*1.0/plan.credits)?string("##.00%")}</td>
        <td>${((plan.credits - practicalCredits)*1.0/plan.credits)?string("##.00%")}</td>
        <td>${(practicalCredits/plan.credits)?string("##.00%")}</td>
        <td>100%</td>
        <td>[#if totalHours>0]${(compulsoryStat.hours*1.0/plan.creditHours)?string("##.00%")}[/#if]</td>
        <td>[#if totalHours>0]${(optionalStat.hours*1.0/plan.creditHours)?string("##.00%")}[/#if]</td>
        <td>[#if totalHours>0]${(theoreticalStat.getHour("1")*1.0/plan.creditHours)?string("##.00%")}[/#if]</td>
        <td>[#if totalHours>0]${(practicalStat.getHour("9")*1.0/plan.creditHours)?string("##.00%")}[/#if]</td>
      </tr>
      <tr><td colspan="11" style="text-align:left;">注：选修课包括限选课；实践教学含课内实践、实验和实训等环节；比重为占总学分或总学时的比例。实践学时不含按周开展实践教学活动的课程学时。</td></tr>
    </tbody>
  </table>
  <table class="doc-table" style="page-break-inside: avoid;">
    <colgroup>
      <col width="18%"/>
    </colgroup>
    <tbody>
      <tr style="font-weight:bold;"><td colspan="${2+program.terms}" style="border-top:0px;">学年学期的学分分布</td></tr>
      [#assign years=["","第一学年","第二学年","第三学年","第四学年","第五学年","第六学年"] /]
      <tr style="font-weight:bold;"><td>学年</td>[#list 1..program.duration?int as i]<td colspan="2">${years[i]}</td>[/#list]<td>小计</td></tr>
      <tr style="font-weight:bold;"><td>学期</td>[#list program.startTerm..program.endTerm as i]<td>${i}</td>[/#list]<td>&nbsp;</td></tr>
      <tr>
        <td style="font-weight:bold;">必修学分</td>
        [#list compulsoryStat.termCredits as tc]
        <td>${tc}</td>
        [/#list]
        <td>${compulsoryStat.credits}</td>
      </tr>
      <tr><td style="font-weight:bold;">限选学分</td><td colspan="${1+program.terms}">${stat.designatedSelectiveStat.credits}</td></tr>
      <tr><td style="font-weight:bold;">自由选修学分</td><td colspan="${1+program.terms}">${stat.freeSelectiveStat.credits}</td></tr>
      </tbody>
    </table>
