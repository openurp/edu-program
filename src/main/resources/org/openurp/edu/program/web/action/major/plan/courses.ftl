[#ftl]
[@b.form name="courseSearchForm" method="post" action="!courses" target="planDialogBody"]
  <table width="100%" align="center" class="listTable">
    <tr class="grayStyle">
      <td width="80%">
        <input type="hidden" name="plan.id" value="${Parameters['plan.id']}" />
        代码或名称:
        <input type="text" name="q" value="${Parameters['q']!}" style="width:300px" maxlength="30000" placeholder="代码或名称"/>
        [@b.submit value="查询" class="btn btn-sm btn-outline-primary"/]
      </td>
    </tr>
  </table>
[/@]

[@b.grid sortable="false" items=courseList! var="course"]
  [@b.row]
    [#assign checked=false/][#if course?? && course== courseList?first][#assign checked=true/][/#if]
    [@b.boxcol type='radio' checked=checked/]
    [@b.col width="13%" property="code" title="课程代码"/]
    [@b.col property="name" title="课程名称"/]
    [@b.col width="5%" property="defaultCredits" title="学分"]
      ${course.getCredits(plan.program.level)}
    [/@]
    [@b.col width="11%" property="creditHours" title="学时" ]
      [#assign cj = course.getJournal(plan.program.grade)/]
      [#if cj.weeks?? && cj.weeks > 0]${cj.weeks}周[#else]
        ${cj.creditHours}
        [#if cj.hours?size>1]<span class="text-muted">([#list cj.hours as h]${h.creditHours}[#sep]+[/#list])</span>[/#if]
      [/#if]
    [/@]
    [@b.col width="8%" property="examMode.name" title="考核方式"/]
    [@b.col width="15%" property="department.name" title="开课院系" ]
      [#if course.department??]
        [#if course.department.shortName??]${course.department.shortName}[#else]${course.department.name}[/#if]
      [/#if]
    [/@]
  [/@]
[/@]

<script>
  var courseResults = {}
  [#list courseList as c]
    courseResults['c${c.id}']={'id':'${c.id}','code':'${c.code}','name':'${c.name}','defaultCredits':'${c.defaultCredits}','creditHours':'${c.creditHours}','weekHours':'${c.weekHours}','department':{'id':'${c.department.id}','name':'${c.department.name}'}}
  [/#list]
</script>
