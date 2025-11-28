[#ftl]
[#macro i18nName(entity)]${entity.name?if_exists}[/#macro]
[#macro groupName(g)][#if g.givenName??]${g.givenName}[#else]${g.courseType.name?replace("通识类","")}[/#if][/#macro]
[#assign chineseNums=['一','二','三','四','五','六','七','八','九','十','十一','十二','十三','十四','十五','十六']/]

[#assign displayTeachDepart=true/]
[#if !displayCreditHour??][#assign displayCreditHour=true/][/#if]
[#-- 有时候必须跨的列数，在这里是课程名称和课程代码两列 --]
[#assign mustSpan = 2/]
[#assign courseCount = 0 /]

[#assign indexInGroup=0/]
[#assign indexInTopGroup=0/]
[#assign fenleiWidth = 10 /]
[#assign optionRemarkDisplayed={}/]
[#assign curTopGroup=""/]
[#assign groupRemindSpans = {} /]

[#include "baseFunctions.ftl" /]

[#-- 获得group的次顶端courseGroup --]
[#function getLevel2Group group]
  [#if group.parent??]
    [#if group.parent.parent??]
      [#return getLevel2Group(group.parent) /]
    [#elseif isLeafGroup(group) && ((groupRemindSpans[group.id?string])!0)==0]
      [#return group.parent /]
    [#else]
      [#return group /]
    [/#if]
  [#else]
    [#return group /]
  [/#if]
[/#function]

[#function getRowCount group]
    [#if isLeafGroup(group)] [#return 1/]
    [#else]
      [#local cnt=group.planCourses?size/]
      [#if group.children?size=0]
         [#if group.planCourses?size==0] [#local cnt=1/][/#if]
      [#else]
         [#list group.children as c]
           [#local cnt = cnt + getRowCount(c)/]
         [/#list]
      [/#if]
      [#return cnt /]
    [/#if]
[/#function]

[#-- 是叶子节点，叶子节点就是课程或没有课程的课程组 --]
[#function isLeafGroup obj]
    [#if obj.children?size == 0]
      [#if obj.planCourses?size == 0]
        [#return true /]
      [#else]
        [#return (obj.name?ends_with("通识类")||obj.name?ends_with("通识课")) /]
      [/#if]
    [#else]
      [#return false /]
    [/#if]
[/#function]

[#-- 获得一个课程组所应该colspan多少 --]
[#function fenleiSpan maxFenleiSpan group]
    [#if isLeafGroup(group)]
        [#if group.parent??]
            [#if (!group.children?? || group.children?size == 0) && myCurrentLevel(group)!=teachPlanLeafLevels && fenleiSpan(maxFenleiSpan,group.parent)==1]
                [#return mustSpan + teachPlanLeafLevels - myCurrentLevel(group)/]
            [#else]
                [#return mustSpan/]
            [/#if]
        [#else]
            [#return mustSpan + maxFenleiSpan /]
        [/#if]
    [#else]
        [#local all_children_leaf =  true /]
        [#list group.children! as c]
            [#if !isLeafGroup(c)][#local all_children_leaf = false /][#break][/#if]
        [/#list]
        [#if all_children_leaf]
            [#return maxFenleiSpan - myCurrentLevel(group) + 1/]
        [#else]
            [#return 1/]
        [/#if]
    [/#if]
[/#function]

[#-- 获得自己和自己的祖宗所使用的分类一栏的colspan总和 --]
[#function HierarchyFenleiSpanSum maxFenleiSpan group]
    [#if !group.parent??]
        [#return fenleiSpan(maxFenleiSpan, group) /]
    [/#if]
    [#return fenleiSpan(maxFenleiSpan, group) + HierarchyFenleiSpanSum(maxFenleiSpan, group.parent) /]
[/#function]

[#-- 获得从树的顶端到自己的一条链 --]
[#function getHierarchyTree group]
    [#if group.parent??]
        [#return getHierarchyTree(group.parent) + [group] /]
    [/#if]
    [#return [group] /]
[/#function]

[#-- 把自己的向上的一条树统统画出来, eg. 爷爷/儿子/孙子 --]
[#macro drawAllAncestor courseGroup indexno]
    [#local tree = getHierarchyTree(courseGroup) /]
    [#assign usedSpan=0/]
    [#list tree as node]
        [#assign nodeSpan=fenleiSpan(maxFenleiSpan, node)/]
        [#if (!node.parent??)][#--顶层节点--]
            [#if  (node.children?size < 1) && (node.planCourses?size < 1)]
                <td class="group" colspan="${nodeSpan}">[@groupName node/]</td>
            [/#if]
            [#if (node.children?size < 1) && (node.planCourses?size > 0)]
                <td class="group" colspan="${nodeSpan}" width="${fenleiWidth * maxFenleiSpan}px">[@groupName node/]</td>
            [/#if]
            [#if (node.children?size > 0) ]
                <td class="group" colspan="${nodeSpan}">[@groupName node/]</td>
            [/#if]
            [#assign usedSpan = usedSpan + nodeSpan/]
        [#else]
            [#if (node.children?size < 1)][#--叶子空组--]
              [#if isLeafGroup(node)]
                [#local remindSpan = maxFenleiSpan - usedSpan/]
                [#assign groupRemindSpans =  groupRemindSpans + {node.id?string:remindSpan} /]
                [#if indexno > 0][#--需要组名称前添加序号的情况--]
                  [#if remindSpan >0 ]
                  [#list 1..remindSpan as i]<td></td>[/#list]
                  [/#if]
                  <td style="text-align:center">${indexno}</td>
                  <td >&nbsp;[@groupName node/]
                  [#if node.planCourses?size >0]&nbsp;[#list node.planCourses as pc]${pc.course.name}(${pc.course.defaultCredits}分)[#if pc_has_next],[/#if][/#list][/#if]
                  </td>
                [#else]
                  <td colspan="${remindSpan+2}">&nbsp;[@groupName node/][#--多占课程代码一列--]
                  [#if node.planCourses?size >0]&nbsp;[#list node.planCourses as pc]${pc.course.name}(${pc.course.defaultCredits}分)[#if pc_has_next],[/#if][/#list][/#if]
                  </td>
                [/#if]
              [#else]
                [#assign usedSpan = usedSpan + nodeSpan/]
                <td class="group" colspan="${nodeSpan}">
                    [@groupName node/]
                </td>
              [/#if]
            [/#if]
            [#if (node.children?size > 0)]
                [#assign usedSpan= usedSpan + nodeSpan/]
                <td class="group" colspan="${nodeSpan}" width="2%">[@groupName node/]</td>
            [/#if]
        [/#if]
    [/#list]
[/#macro]

[#-- 课程组的一格一格的学分信息 --]
[#macro courseGroupCreditInfo courseGroup]
    [#local i = 1 /]
    [#if  courseGroup.termCredits=="*"]
        [#list i..maxTerm as t]<td class="credit_hour">&nbsp;</td>[/#list]
    [#else]
        [#local termCredits= courseGroup.termCredits/]
        [#if termCredits?starts_with(",")]
            [#local termCredits= termCredits[1..termCredits?length-1] /]
        [/#if]
        [#if termCredits?ends_with(",")]
            [#local termCredits= termCredits[0..termCredits?length-2] /]
        [/#if]
        [#list termCredits[0..termCredits?length-1]?split(",") as credit]
          [#if (i<=maxTerm)]
            <td class="credit_hour">[#if credit!="0"]${credit}[#else]&nbsp;[/#if]</td>
            [#if !courseGroup.parent??]
                [#local current_totle=total_term_credit[i?string]!(0) /]
                [#assign total_term_credit=total_term_credit + {i:current_totle+credit?number} /]
                [#local i = i + 1 /]
            [/#if]
          [/#if]
        [/#list]
    [/#if]
[/#macro]
[#-- 课程组的一格一格的学分信息 --]
[#macro courseGroupCredit2Info courseGroup]
    [#list 1..maxTerm as i]
        <td class="credit_hour">[#if courseGroup.terms.contains(i)]√[/#if]</td>
    [/#list]
[/#macro]
[#-- 计划课程的一格一格的周课时信息 --]
[#macro planCourseWeekHoursInfo planCourse]
    [#list 1..maxTerm as i]
        <td class="credit_hour">[#if planCourse.terms.contains(i)]${(planCourse.course.weekHours)?if_exists}[#else]&nbsp;[/#if]</td>
    [/#list]
[/#macro]
[#-- 计划课程的一格一格的学分信息 --]
[#macro planCourseCreditInfo planCourse]
    [#list 1..maxTerm as i]
        <td class="credit_hour">[#if planCourse.terms.contains(i)]${(planCourse.course.defaultCredits)?if_exists}[#else]&nbsp;[/#if]</td>
    [/#list]
[/#macro]

[#-- 计划课程的一格一格的学分信息 --]
[#macro planCourseCredit2Info planCourse]
    [#list 1..maxTerm as i]
        <td class="credit_hour">[#if planCourse.terms.contains(i)]√[/#if]</td>
    [/#list]
[/#macro]

[#-- 画出一个选修组后的备注 --]
[#macro displayRemark courseGroup]
    [#assign level2Group = getLevel2Group(courseGroup)/]
    [#if !remarkGroups?seq_contains(level2Group)]
      [#assign remarkGroups = remarkGroups+[level2Group]/]
      [#if level2Group.parent??]

        [#if level2Group.parent.remark??]
          [#assign childrenAreNaive = true /] [#--平行的所有子组的都是啥都没要求 或者有要求也不能显示--]
        [#else]
          [#assign childrenAreNaive = false /]
          [#if level2Group.credits == 0 && !level2Group.remark??][#--什么都不写的组，看看是否能显示上级组的备注--]
            [#assign childrenAreNaive = true /]
            [#list level2Group.parent.children as g]
              [#if g.credits != 0 || g.remark??][#assign childrenAreNaive=false/][#break/][/#if]
            [/#list]
          [/#if]
        [/#if]

        [#if childrenAreNaive]
          [#assign level2Group = level2Group.parent/]
          [#list level2Group.children as g]
            [#assign remarkGroups = remarkGroups+[g]/]
          [/#list]
        [/#if]
      [/#if]
      [#assign childrenCount = getRowCount(level2Group)/]
      <td style="text-align:center" rowspan="${childrenCount}">
        [#if level2Group.remark??]${level2Group.remark}[#elseif level2Group.credits>0]${level2Group.credits}分[/#if]
      </td>
    [/#if]
[/#macro]

[#macro displayPercent courseGroup]
    [#assign level2Group = getLevel2Group(courseGroup)/]
    [#if !remarkGroups?seq_contains(level2Group)]
      [#assign remarkGroups = remarkGroups+[level2Group] /]
      [#assign childrenCount = getRowCount(level2Group)/]
      <td style="text-align:center" rowspan="${childrenCount}">${level2Group.creditHours!}</td>
      <td style="text-align:center" rowspan="${childrenCount}">${(level2Group.creditHours/plan.creditHours*100)?string("0.00")}%</td>
    [/#if]
[/#macro]
[#-- 需要完善，画出一个必修组课程组 --]
[#macro drawCompulsoryGroup courseGroup courseTermInfoMacro groupTermInfoMacro]
    [#if isLeafGroup(courseGroup)]
        <tr>
            [#assign indexInTopGroup = indexInTopGroup + 1]
            [@drawAllAncestor courseGroup indexInTopGroup/]
            <td>&nbsp;</td>
            <td class="credit_hour">${courseGroup.creditHours}</td>
            [#list natures as tn]
            <td class="credit_hour">${courseGroup.getHours(natures).get(tn)!}</td>
            [/#list]
            <td class="credit_hour">${courseGroup.credits}</td>
            [@groupTermInfoMacro courseGroup /]
            [@displayPercent courseGroup/]
        </tr>
    [#else]
        [#if getTopCourseGroup(courseGroup) !=  curTopGroup]
          [#assign indexInTopGroup=0/]
          [#assign curTopGroup=getTopCourseGroup(courseGroup)/]
        [/#if]
        [#assign indexInGroup=0/]
        [#list courseGroup.planCourses?sort_by(['course','code'])?sort_by(['terms','value']) as planCourse]
           [#if !(term??) || term?? && term?length=0 ||term?? && planCourse.terms.contains(term?number)]
            [#assign indexInTopGroup = indexInTopGroup + 1]
            [#assign indexInGroup = indexInGroup + 1]
            <tr>
            [@drawAllAncestor courseGroup indexInTopGroup/]

            [#-- 存在非叶子节点的子组 add on 2012-04-11 --]
            [#local exists_nonleaf_child = false /]
            [#list courseGroup.children as c]
                [#if !isLeaf(c) ][#local exists_nonleaf_child=true /][#break][/#if]
            [/#list]
            [#if exists_nonleaf_child]
                <td class="group" colspan="${maxFenleiSpan - myCurrentLevel(courseGroup)}">&nbsp;</td>
            [/#if]
            <td style="text-align:center">${indexInTopGroup}</td>
            <td class="course">&nbsp;[@i18nName planCourse.course/]</td>
            <td style="text-align: center;">${planCourse.course.code!}</td>
            <td class="credit_hour">${(planCourse.course.creditHours)?default(0)}</td>
            [#list natures as tn]
            <td class="credit_hour">${planCourse.journal.getHour(tn)!0}</td>
            [/#list]
            <td class="credit_hour">${(planCourse.credits)?default(0)}</td>
            [@courseTermInfoMacro planCourse /]
            [@displayPercent courseGroup/]
          </tr>
         [/#if]
        [/#list]
        [#list courseGroup.children! as child]
            [@drawCompulsoryGroup child courseTermInfoMacro groupTermInfoMacro/]
        [/#list]
    [/#if]
[/#macro]

[#-- 画出一个选修组 --]
[#macro drawOptionalGroup courseGroup courseTermInfoMacro groupTermInfoMacro]
    [#if isLeafGroup(courseGroup)]
        [#if !courseGroup.parent??]
         <tr>
            [@drawAllAncestor courseGroup 0/]
            <td class="credit_hour">[#if courseGroup.credits>0]${courseGroup.credits}[/#if]</td>
            [@groupTermInfoMacro courseGroup /]
            <td class="credit_hour">[#if courseGroup.remark??]${courseGroup.remark}[#else]${courseGroup.credits}分[/#if]</td>
         </tr>
         [#else]
         <tr>
           [@drawAllAncestor courseGroup 0/]
           <td class="credit_hour">[#if courseGroup.credits>0]${courseGroup.credits}[/#if]</td>
           [@groupTermInfoMacro courseGroup /]

           [@displayRemark courseGroup/]
         </tr>
        [/#if]
    [#else]
        [#assign indexInGroup=0/]
        [#list courseGroup.planCourses?sort_by(['course','code'])?sort_by(['terms','value']) as planCourse]
           [#if !(term??) || term?? && term?length=0 ||term?? && planCourse.terms.contains(term?number)]
            [#assign indexInGroup = indexInGroup + 1]
            <tr>
            [@drawAllAncestor courseGroup 0/]

            [#-- 存在非叶子节点的子组 add on 2012-04-11 --]
            [#local exists_nonleaf_child = false /]
            [#list courseGroup.children as c]
                [#if !isLeafGroup(c) ][#local exists_nonleaf_child=true /][#break][/#if]
            [/#list]
            [#if exists_nonleaf_child]
                <td class="group" colspan="${maxFenleiSpan - myCurrentLevel(courseGroup)}">&nbsp;</td>
            [/#if]
            <td class="course">&nbsp;[@i18nName planCourse.course/]</td>
            <td style="text-align: center;">${planCourse.course.code!}</td>
            <td class="credit_hour">${(planCourse.course.defaultCredits)?default(0)}</td>
            [@courseTermInfoMacro planCourse /]

            [@displayRemark courseGroup/]
          </tr>
         [/#if]
        [/#list]
        [#list courseGroup.children! as child]
            [@drawOptionalGroup child courseTermInfoMacro groupTermInfoMacro/]
        [/#list]
    [/#if]
[/#macro]

[#-- 画出一个实践组 --]
[#macro drawPracticeGroup courseGroup courseTermInfoMacro groupTermInfoMacro]
    [#if courseGroup.children?size>0]
       [#list courseGroup.children as c]
       [@drawPracticeGroup c,courseTermInfoMacro,groupTermInfoMacro/]
       [/#list]
    [#else]
      [#if courseGroup.planCourses?size>0]
        [#list courseGroup.planCourses?sort_by(['course','code'])?sort_by(['terms','value']) as planCourse]
          <tr>
            [@drawAllAncestor courseGroup 0/]
            <td class="course" style="text-align: center;">&nbsp;[@i18nName planCourse.course/]</td>
            <td style="text-align: center;">${planCourse.course.code}</td>
            <td class="credit_hour">${(planCourse.course.defaultCredits)?default(0)}</td>
            [#list 1..maxTerm as i]
              [#assign matched=planCourse.terms?exists && (","+planCourse.terms+",")?contains(","+i+",")/]
              [#assign vocation=planCourse.stage?? && planCourse.stage.name?contains("假")/]
              <td class="credit_hour">[#if matched && !vocation]√[/#if]</td>
              <td class="credit_hour">[#if matched && vocation]√[/#if]</td>
            [/#list]
            [@displayRemark courseGroup/]
          </tr>
        [/#list]
      [#else]
         <tr>
           [@drawAllAncestor courseGroup 0/]
           <td style="text-align: center;">${courseGroup.credits}</td>
            [#list 1..maxTerm as i]
              [#assign matched=courseGroup.terms?exists && (","+courseGroup.terms+",")?contains(","+i+",")/]
              <td class="credit_hour">[#if matched]√[/#if]</td>
              <td class="credit_hour"></td>
            [/#list]
           [@displayRemark courseGroup/]
         </tr>
      [/#if]
    [/#if]
[/#macro]

[#-- 列举一个实践组内课程 --]
[#macro listPracticeCourse courseGroup courseTermInfoMacro groupTermInfoMacro]
    [#list courseGroup.planCourses?sort_by(['course','code'])?sort_by(['terms','value']) as planCourse]
        <tr>
          <td class="course" style="text-align: center;">&nbsp;[@i18nName planCourse.course/]</td>
          <td style="text-align: center;">${planCourse.course.code!}</td>
          <td class="credit_hour">${(planCourse.course.defaultCredits)?default(0)}</td>
          [#list 1..maxTerm as i]
            [#assign matched=planCourse.terms?exists && (","+planCourse.terms+",")?contains(","+i+",")/]
            [#assign vocation=planCourse.stage?? && planCourse.stage.name?contains("假")/]
            <td class="credit_hour">[#if matched && !vocation]√[/#if]</td>
            <td class="credit_hour">[#if matched && vocation]√[/#if]</td>
          [/#list]
        </tr>
    [/#list]
[/#macro]

[#-- 课程学分要求的叫法--]
[#macro requireLabel courseGroup]
  [#if courseGroup.autoAddup]学分小计[#else]
  <font color="#1F3D83">
    [#if courseGroup.credits=0]应修门数[#else]应修学分[/#if]
  </font>
  [/#if]
[/#macro]

[#-- 需要完善，画出一个课程组 --]
[#macro drawGroup courseGroup courseTermInfoMacro groupTermInfoMacro]
    [#if isLeaf(courseGroup)]
        <tr>
            [@drawAllAncestor courseGroup 0/]
            <td class="credit_hour">${courseGroup.credits}</td>
            [#if displayCreditHour]<td class="credit_hour">${courseGroup.creditHours}</td>[/#if]
            [@groupTermInfoMacro courseGroup /]
            [#if displayTeachDepart]<td>&nbsp;</td>[/#if]
            <td class="remark">&nbsp;${courseGroup.remark!}</td>
        </tr>
    [#else]
        [#list courseGroup.children! as child]
            [@drawGroup child courseTermInfoMacro groupTermInfoMacro/]
        [/#list]
        [#list courseGroup.orderedPlanCourses as planCourse]
           [#if !(term??) || term?? && term?length=0 ||term?? && planCourse.terms.contains(term?number)]
            [#assign courseCount = courseCount + 1]
            <tr>
            [@drawAllAncestor courseGroup 0/]

            [#-- 存在非叶子节点的子组 add on 2012-04-11 --]
            [#local exists_nonleaf_child = false /]
            [#list courseGroup.children as c]
                [#if !isLeaf(c) ][#local exists_nonleaf_child=true /][#break][/#if]
            [/#list]
            [#if exists_nonleaf_child]
                <td class="group" colspan="${maxFenleiSpan - myCurrentLevel(courseGroup)}">&nbsp;</td>
            [/#if]

            <td style="text-align: center;">${planCourse.course.code!}</td>
            <td class="course">&nbsp;${courseCount}&nbsp;[@i18nName planCourse.course/][#if courseGroup.plan.program.degreeCourses?seq_contains(planCourse.course)]<span style="color:red" title="学位课程">*</span>[/#if]</td>
            <td class="credit_hour">${(planCourse.course.getCredits(courseGroup.plan.program.level))?default(0)}</td>
            [#if displayCreditHour]<td class="credit_hour">${(planCourse.course.creditHours)?default(0)}</td>[/#if]
            [@courseTermInfoMacro planCourse /]
            [#if displayTeachDepart]<td class="credit_hour">${planCourse.journal.department.name}</td>[/#if]
            <td class="remark">[#if planCourse.compulsory && !courseGroup.autoAddup]必修 [/#if][#if planCourse.remark?exists]${planCourse.remark!}[#else]&nbsp;[/#if]</td>
          </tr>
         [/#if]
        [/#list]
        [#if courseGroup.parent?? && courseGroup.autoAddup && courseGroup.children?size==0]
        [#else]
        <tr>
            [@drawAllAncestor courseGroup 0/]
            <td colspan="${mustSpan + maxFenleiSpan - HierarchyFenleiSpanSum(maxFenleiSpan, courseGroup)}" class="credit_hour summary">[@requireLabel courseGroup/]</td>
            <td class="credit_hour summary">
              [#if courseGroup.autoAddup]${courseGroup.credits}
              [#else]
                <font color="#1F3D83">
                [#if courseGroup.credits=0]${courseGroup.courseCount}门[#else]${courseGroup.credits}[/#if]
                </font>
              [/#if]
            </td>
            [#if displayCreditHour]<td class="credit_hour summary">[#if courseGroup.creditHours>0]${courseGroup.creditHours!}[/#if]</td>[/#if]
            [@groupTermInfoMacro courseGroup /]
            [#if displayTeachDepart]<td>&nbsp;</td>[/#if]
            <td class="remark">${courseGroup.remark!}</td>
        </tr>
        [/#if]
    [/#if]
[/#macro]

[#-- 培养计划中课程组的层次, 默认为1层 --]
[#assign teachPlanLevels = planMaxDepth(plan) /]
[#if teachPlanLevels == 0]
    [#assign teachPlanLevels = 1 /]
[/#if]

[#-- 培养计划中叶子节点的最深层次, 默认为1层 --]
[#assign teachPlanLeafLevels = planLeafMaxLevel(plan) /]

[#if teachPlanLeafLevels == 0]
    [#assign teachPlanLeafLevels = 1 /]
[/#if]

[#-- 分类一栏的colspan --]
[#assign maxFenleiSpan = teachPlanLeafLevels - 1]
[#if maxFenleiSpan <= 0]
    [#assign maxFenleiSpan = 1 /]
[/#if]

[#macro mergeCourseTypeCell planId t_planLevels startRowIndex bottomrows]
    mergeCourseTypeCell('planInfoTable${planId}', ${t_planLevels},${startRowIndex},${bottomrows});
[/#macro]

[#macro planSupTitle plan]
    状态：${plan.program.status.fullName}&nbsp;
    生效日期：${plan.program.beginOn?string('yyyy-MM-dd')}~${(plan.program.endOn?string('yyyy-MM-dd'))!}&nbsp;
    [#if plan.program.degree??]学位：${plan.program.degree.name }&nbsp;[/#if]
    [#if plan.program.degreeGpa??]学位绩点：${plan.program.degreeGpa }&nbsp;[/#if]
    最后修改时间：${(plan.program.updatedAt?string('yyyy-MM-dd HH:mm:ss'))!}
[/#macro]

[#macro planTitle plan]
${plan.program.level.name}&nbsp;${plan.program.stdType.name}&nbsp;${plan.program.department.name}&nbsp;${plan.program.major.name}专业
<br>${(plan.program.direction.name + "&nbsp;")!}${b.text('entity.program')}&nbsp;(${plan.program.grade})
[/#macro]

[#macro exePlanTitle plan]
${plan.program.level.name}&nbsp;${(plan.program.stdType.name)!}&nbsp;${plan.program.department.name}&nbsp;${plan.program.major.name}专业
<br>${(plan.program.direction.name + "&nbsp;")!}培养计划(${plan.program.grade.code})
[/#macro]

[#macro displayStat categoryStat title]
    <tr>
        <td class="summary" colspan="${maxFenleiSpan + mustSpan}">${title}</td>
        <td></td>
        <td class="credit_hour summary">${categoryStat.hours}</td>
        [#list natures as cht]
        <td class="credit_hour summary">${categoryStat.getHour(cht)}</td>
        [/#list]
        <td class="credit_hour summary">${categoryStat.credits}</td>
    [#list 1..maxTerm as i]
        <td class="credit_hour">${categoryStat.termCredits[i-1]!}</td>
    [/#list]
        <td class="credit_hour">${categoryStat.hours}</td>
        <td class="credit_hour">
        [#if categoryStat.credits<stat.credits]
          [#assign overall_percent= overall_percent + (categoryStat.credits/stat.credits*100*100)?round/]
          [#if overall_percent>10000]
          ${(((categoryStat.credits/stat.credits*100*100)?round-1)/100)?string("0.00")}%
          [#else]
          ${((categoryStat.credits/stat.credits*100*100)?round/100)?string("0.00")}%
          [/#if]
        [#else]
          ${((categoryStat.credits/stat.credits*100*100)?round/100)?string("0.00")}%
        [/#if]
        </td>
    </tr>
[/#macro]
