[#ftl]
[@b.form name="courseSearchForm" method="post" action="!courses"]
    <table width="100%" align="center" class="listTable">
        <tr class="grayStyle">
            <td width="80%">
                <input type="hidden" name="plan.id" value="${Parameters['plan.id']}" />
                代码或名称:
                <input type="text" name="q" value="${Parameters['q']!}" maxlength="32" style="width:200px"  placeholder="代码或名称"/>
                [@b.submit value="查询"/]
            </td>
        </tr>
    </table>
[/@]

[@b.grid sortable="false" items=courseList! var="course"]
    [@b.row]
        [@b.boxcol type='radio' /]
        [@b.col width="13%" property="code" title="课程代码"/]
        [@b.col property="name" title="课程名称"/]
        [@b.col width="5%" property="defaultCredits" title="学分"]
          ${course.getCredits(plan.program.level)}
        [/@]
        [@b.col width="5%" property="creditHours" title="学时" /]
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
