[#ftl]
[@b.head /]
[@b.grid sortable="true" items=alts var="alt"]
    [@b.gridbar]
        bar.addItem("${b.text("action.add")}",action.add());
        bar.addItem("${b.text("action.modify")}",action.edit());
        bar.addItem("${b.text("action.delete")}",action.remove());
    [/@]
    [@b.row]
      [@b.boxcol/]
      [@b.col width='8%' property="fromGrade" title="年级"]
        [#if alt.fromGrade = alt.toGrade]${alt.fromGrade.code}
        [#else]${alt.fromGrade.code}~${alt.toGrade.code}
        [/#if]
      [/@]
      [@b.col property="department" title="院系"]${(alt.department.name)!}[/@]
      [@b.col width='15%' property="major" title="专业"]${(alt.major.name)!"不限"}[#if alt.direction??] ${(alt.direction.name)!}[/#if][/@]
      [@b.col width='30%' title="原课程代码、名称、学分"]
        [#list (alt.olds)! as course]${(course.code)!} ${(course.name)!} (${(course.defaultCredits)!})[#if course_has_next]<br>[/#if][/#list]
      [/@]
      [@b.col width='30%' title="新课程代码、名称、学分"]
        [#list (alt.news)! as course]${(course.code)!} ${(course.name)!} (${(course.defaultCredits)!})[#if course_has_next]<br>[/#if][/#list]
      [/@]
    [/@]
[/@]
[@b.foot /]
