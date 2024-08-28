    <table class="table table-hover table-sm">
      <thead>
        <tr>
          <th width="50px">序号</th>
          <th width="100px">课程代码</th>
          <th>课程名称</th>
          <th width="50px">学分</th>
          <th width="100px">学时</th>
          <th width="80px">考核方式</th>
          <th width="100px">培养层次</th>
          <th width="80px">开课学期</th>
          <th width="50px">次数</th>
          <th width="25%">面向专业</th>
        </tr>
      </thead>
      <tbody>
        [#list coursesOwn as s]
        <tr>
          <td>${s_index+1}</td>
          <td>${s.course.code}</td>
          <td><a href="#" onclick="return displayCourses('${s.course.id}','[#list s.programs as p]${p.id}[#sep],[/#list]')">${s.course.name}</a></td>
          <td>${s.course.defaultCredits}</td>
          [#assign cj = s.course.getJournal(grade)/]
          <td>[#if cj.weeks?? && cj.weeks>0]${cj.weeks}周[#else]${cj.creditHours}<span [#if cj.creditHourIdentical]class="text-muted"[#else]style="color:red"[/#if]>([#list teachingNatures as n]${cj.getHour(n)!0}[#sep]+[/#list])</span>[/#if]</td>
          <td>${cj.examMode.name}</td>
          <td>[#list s.levels as m]${m.name}[#sep] [/#list]</td>
          <td>${s.terms}</td>
          <td>${s.count}</td>
          <td><span style="font-size:0.8rem;">[#list s.programs as m][#if m.direction??]${(m.direction.name)}[#else]${m.major.name}[/#if][#sep] [/#list]</span></td>
       </tr>
       [/#list]
      </tbody>
    </table>
