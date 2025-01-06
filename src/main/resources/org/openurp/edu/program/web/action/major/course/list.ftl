[@b.grid items=pcs var="pc"]
  [@b.gridbar]
    bar.addItem("批量设置",action.multi('batchEdit'));
    bar.addItem("${b.text("action.export")}",
        action.exportData("course.code:课程代码,course.name:课程名称,journal.department.name:开课院系,"+
        "credits:学分,journal.creditHours:学时,journal.examMode.name:考核方式,terms:学期,group.name:课程类别,"+
        "journal.department.name:开课院系,group.plan.program.grade.code:年级,group.plan.program.major.name:专业,"+
        "group.plan.program.direction.name:方向,group.plan.program.level.name:培养层次,"+
        "group.plan.program.eduType.name:培养类型,labels:课程标签",null,'fileName=计划课程信息'));
  [/@]
  [@b.row]
    [@b.boxcol /]
    [@b.col width="9%" title="课程代码" property="course.code"/]
    [@b.col title="课程名称" property="course.name"]
      ${pc.course.name}
      [#if pc.compulsory]<sup>必</sup>[/#if]
      [#if pc.stage??]<sup>${pc.stage.name}</sup>[/#if]
    [/@]
    [@b.col width="5%" title="学分" property="course.defaultCredits"]
      ${pc.course.getCredits(pc.group.plan.program.level)}
    [/@]
    [#assign cj = (pc.journal)!/]
    [@b.col width="8%" title="学时"]
      [#if cj??]
        [#if cj.weeks??&& cj.weeks>0]${cj.weeks}周[#else]
          ${cj.creditHours!}
          [#if cj.hours?size>1]<span class="text-muted">([#list cj.hours as h]${h.creditHours}[#sep]+[/#list])</span>[/#if]
        [/#if]
      [/#if]
    [/@]
    [@b.col width="6%" title="开课学期"]
        ${termHelper.getTermText(pc)}
    [/@]
    [@b.col width="6%" title="考核方式"]
       [#if cj??]${(cj.examMode.name)!}[/#if]
    [/@]
    [@b.col width="6%" title="年级"]
      ${pc.group.plan.program.grade.name}
    [/@]
    [@b.col width="6%" title="层次"]
      ${pc.group.plan.program.level.name}
    [/@]
    [@b.col width="15%" title="专业/方向"]
       ${pc.group.plan.program.major.name} ${(pc.group.plan.program.direction.name)!}
    [/@]
    [@b.col width="13%" title="课程类别" sort="group.courseType.name"]
       ${pc.group.name}
    [/@]
    [@b.col width="8%" title="开课院系"]
       [#if cj??]
       ${(cj.department.shortName)!((cj.department.name)!'--')}
       [/#if]
    [/@]
  [/@]
[/@]
