[#ftl]
[#assign maxTerm = plan.terms /]
[#if Parameters['term']??]
[#assign term = Parameters['term']]
[/#if]
[#assign hours={}/]
  <table id="planInfoTable${plan.id}_overall" name="planInfoTable${plan.id}_overall" class="plan-table"  style="width:100%;font-size:12px;font-family:宋体;vnd.ms-excel.numberformat:@">
      <thead>
          <tr align="center">
              <th rowspan="2" colspan="${maxFenleiSpan}" width="5%">类别</th>
              <th rowspan="2" width="5%">序号</th>
              <th rowspan="2" width="29%">课程名称</th>
              <th rowspan="2" width="9%">课程代码</th>
              <th width="12%" colspan="${natures?size+1}">学时数</th>
              <th rowspan="2" width="5%">学分</th>
              <th colspan="${maxTerm}" width="25%">各学期学分分布</th>
              <th rowspan="2" width="5%">课时</th>
              <th rowspan="2" width="5%">百分比</th>
          </tr>
          <tr  align="center">
          [#assign total_term_credit={} /]
          <th>合计</th>
          [#list natures as tn]
          <th>${tn.name}</th>
          [/#list]
          [#list 1..maxTerm as i ]
              [#assign total_term_credit=total_term_credit + {i:0} /]
              <th>${chineseNums[i-1]}</th>
          [/#list]
          </tr>
      </thead>
      <tbody>
      [#assign remarkGroups=[]/]
      [#assign groupRemindSpans={}/]
      [#assign hasRX=false/] [#--是否含任意选修--]
      [#list plan.topGroups! as courseGroup]
          [#if !courseGroup.courseType.optional && !courseGroup.courseType.practical]
          [@drawCompulsoryGroup courseGroup planCourseCreditInfo courseGroupCreditInfo/]
          [/#if]
          [#if courseGroup.name?contains("全校性公选课")]
          [#assign hasRX=true/]
          [/#if]
      [/#list]
          [#assign optionStat=stat.optionalStat/]
          [#assign practicalStat=stat.practicalStat/]
          [#assign overall_percent=0/]
          [@displayStat  stat.getCompulsoryStat(false) "必修课"/]
          [#if stat.hasOptional]
          [#assign optionTitle=hasRX?string('选修课（含限选课和任选课）','选修课（含限选课和通识选修课）')/]
          [@displayStat optionStat optionTitle/]
          [/#if]
          [#if  stat.hasPractice]
          [@displayStat practicalStat "实践课程"/]
          [/#if]
          [@displayStat  stat.allStat "总计"/]
      </tbody>
  </table>
<script>
[#assign bottomLine=2/]
[#if stat.hasOptional][#assign bottomLine=bottomLine+1/][/#if]
[#if stat.hasPractice][#assign bottomLine=bottomLine+1/][/#if]

[@mergeCourseTypeCell plan.id+"_overall" teachPlanLevels 2 bottomLine/]
</script>
