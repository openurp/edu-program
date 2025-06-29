[#assign programCourseTags = program.courseTags/]
<table class="table table-sm mb-0 plan_table">
  <thead>
    <tr>
      <th width="40px">序号</th>
      <th width="10%">课程代码</th>
      <th>课程名称以及英文名</th>
      <th width="5%">学分</th>
      <th width="10%">学时</th>
      <th width="70px">课程属性</th>
      <th width="70px">考核方式</th>
      <th width="70px">开课学期</th>
      <th width="70px">开课单位</th>
      <th width="120px">备注</th>
    </tr>
  </thead>
  <tbody>
    [#list plan.topGroups as g]
    [@displayGroup g,1/]
    [/#list]
  </tbody>
</table>

[#macro displayGroup(g,level)]
  <tr class="grouprow">
    <td colspan="3">
      <div class="coursegroup">
        <div style="display: flex;flex: 5;">
        ${g.indexno}&nbsp;
        ${g.shortName}
        </div>
      </div>
    </td>
    <td>[#if g.credits>0]${g.credits}[/#if]</td>
    <td>[#if g.creditHours>0]${g.creditHours}[#assign ghours = g.getHours(natures)/][#if ghours?size>0]([#list ghours?keys as h]${ghours.get(h)}[#sep]+[/#list])[/#if][/#if]</td>
    <td>${(g.rank.name)!}</td>
    <td></td>
    <td>${termHelper.getTermText(g)!}</td>
    <td>${g.departments!}</td>
    <td><span class="text-muted" style="font-size:0.8rem">${g.remark!}</span></td>
  </tr>

  [#if g.planCourses?size>0]
    [#list g.orderedPlanCourses as pc]
    <tr>
      <td>${pc_index+1}</td>
      <td>${pc.course.code}</td>
      <td>
        <div style="display: inline-block;">
          <span class="course_name" id="pc_course_${pc.course.id}" [#if programCourseTags.get(pc.course)??]style="font-weight:bold;"[/#if]>
                ${pc.course.name}[#if displayCourseEnName]<br>${pc.course.enName!'无'}[/#if]</span>
        </div>
      </td>
      <td>${pc.course.defaultCredits}</td>
      [#assign cj = pc.course.getJournal(program.grade)/]
      <td>[#if cj.weeks?? && cj.weeks>0][#if cj.weeks>15]每周[#else]${cj.weeks}周[/#if][#else]${cj.creditHours}<span [#if cj.creditHourIdentical]class="text-muted"[#else]style="color:red"[/#if]>([#list natures as n]${cj.getHour(n)!0}[#sep]+[/#list])</span>[/#if]</td>
      <td>[#if pc.compulsory]必修[#else]${(g.rank.name)!}[/#if]</td>
      <td>${(cj.examMode.name)!}</td>
      <td>${termHelper.getTermText(pc)}<div style="display:none">${pc.terms!}</div></td>
      <td>${(cj.department.shortName!cj.department.name)!}</td>
      <td>
        <span class="text-muted" style="font-size:0.8rem">
        [#if cj.examMode.id==1]${cj.examMode.name}&nbsp;[/#if][#t/]
        [#if pc.remark??]${pc.remark}&nbsp;[/#if][#t/]
        [#if programCourseTags.get(pc.course)??] [#list programCourseTags.get(pc.course) as t]${t.name}&nbsp;[/#list][/#if][#t/]
        [#if cj.tags?size>0] [#list cj.tags as t]${t.name}[#sep]&nbsp;[/#list][/#if][#t/]
        </span>
      </td>
    </tr>
    [/#list]
  [/#if]

  [#if g.children?size>0]
    [#list g.children?sort_by("indexno") as gc]
    [@displayGroup gc,level+1/]
    [/#list]
  [/#if]

[/#macro]
