[#ftl]
[#assign maxTerm = plan.terms /]
[#if Parameters['term']??]
[#assign term = Parameters['term']]
[/#if]
[#assign hours={}/]
[#assign practicalGroups = []/]
[#assign multilevel = false/]
[#list plan.topGroups! as courseGroup]
    [#if courseGroup.courseType.practical]
    [#if courseGroup.children?size>0][#assign multilevel = true/][/#if]
    [#assign practicalGroups = practicalGroups + [courseGroup]/]
    [/#if]
[/#list]
[#if practicalGroups?size >1 ][#assign multilevel = true/][/#if]

[#if multilevel]
  <table id="planInfoTable${plan.id}_practical" name="planInfoTable${plan.id}_practical" class="plan-table"  style="width:100%;font-size:12px;font-family:宋体;vnd.ms-excel.numberformat:@">
      <thead>
          <tr align="center">
              <td rowspan="2" colspan="${maxFenleiSpan}" width="7.3%">类别</td>
              <td rowspan="2" width=20%">课程名称</td>
              <td rowspan="2" width="10%">课程代码</td>
              <td rowspan="2" width="5%">学分</td>
              <td colspan="${maxTerm*2}" width="60%">各学期（含寒、暑假）学分分布</td>
              <td rowspan="2" width="5%">应完成学分</td>
          </tr>
          <tr style="text-align:center;">
          [#assign total_term_credit={} /]
          [#list 1..maxTerm as i ]
              [#assign total_term_credit=total_term_credit + {i:0} /]
              <td>${chineseNums[i-1]}</td>
              <td>[#if i%2==1]寒假[#else]暑假[/#if]</td>
          [/#list]
          </tr>
      </thead>
      <tbody>
        [#list practicalGroups as courseGroup]
        [@drawPracticeGroup courseGroup planCourseCreditInfo courseGroupCreditInfo/]
        [/#list]
      </tbody>
  </table>
  <br/>
  <script>
  [@mergeCourseTypeCell plan.id+"_practical" teachPlanLevels 2 0/] [#--开头有两行--]
  </script>
[#else]
  <table id="planInfoTable${plan.id}_practical" name="planInfoTable${plan.id}_practical" class="plan-table"  style="width:100%;font-size:12px;font-family:宋体;vnd.ms-excel.numberformat:@">
      <thead>
          <tr align="center">
              <td rowspan="2" width=20%">课程名称</td>
              <td rowspan="2" width="10%">课程代码</td>
              <td rowspan="2" width="5%">学分</td>
              <td colspan="${maxTerm*2}" width="65%">各学期（含寒、暑假）学分分布</td>
          </tr>
          <tr style="text-align:center;">
          [#assign total_term_credit={} /]
          [#list 1..maxTerm as i ]
              [#assign total_term_credit=total_term_credit + {i:0} /]
              <td>${chineseNums[i-1]}</td>
              <td>[#if i%2==1]寒假[#else]暑假[/#if]</td>
          [/#list]
          </tr>
      </thead>
      <tbody>
        [#list practicalGroups as courseGroup]
        [@listPracticeCourse courseGroup planCourseCreditInfo courseGroupCreditInfo/]
        [/#list]
      </tbody>
  </table>
[/#if]
