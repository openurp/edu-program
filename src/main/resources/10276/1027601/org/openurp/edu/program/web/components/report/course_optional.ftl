[#ftl]
[#assign maxTerm = plan.terms /]
[#if Parameters['term']??]
[#assign term = Parameters['term']]
[/#if]
[#assign hours={}/]
<table id="planInfoTable${plan.id}_optional" name="planInfoTable${plan.id}_optional" class="plan-table"  style="width:100%;font-size:12px;font-family:宋体;vnd.ms-excel.numberformat:@">
      <thead>
          <tr align="center">
              <td colspan="${maxFenleiSpan}" width="7.3%">类别</td>
              <td width="38.7%">课程名称</td>
              <td width="7.2%">课程代码</td>
              <td width="5%">学分</td>
          [#assign total_term_credit={} /]
          [#list 1..maxTerm as i ]
              [#assign total_term_credit=total_term_credit + {i:0} /]
              <td>${chineseNums[i-1]}</td>
          [/#list]
            <td width="12.2%">应完成学分</td>
          </tr>
      </thead>
      <tbody>
      [#list plan.topGroups as courseGroup]
          [#if courseGroup.courseType.optional && !courseGroup.courseType.practical]
          [@drawOptionalGroup courseGroup planCourseCredit2Info courseGroupCredit2Info/]
          [/#if]
      [/#list]
      <tr align="center">
         <td colspan="${mustSpan + maxFenleiSpan}">建议完成学分</td>
         <td class="credit_hour summary">${optionStat.credits}</td>
     [#list 1..maxTerm as i]
         <td class="credit_hour">${optionStat.termCredits[i-1]}</td>
     [/#list]
         <td class="credit_hour">${optionStat.credits}分</td>
      </tr>
      </tbody>
  </table>
<script>
[@mergeCourseTypeCell plan.id+"_optional" teachPlanLevels 1 1/]
</script>
