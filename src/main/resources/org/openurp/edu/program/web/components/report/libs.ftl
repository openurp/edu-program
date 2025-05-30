[#ftl]
[#assign maxTerm = plan.terms /]
[#-- 获得一个courseGroup的最深层次，自己的层次为1 --]
[#function myMaxDepth courseGroup]
    [#local max_level = 0 /]
    [#list courseGroup.children! as child]
        [#local t_level = myMaxDepth(child) /]
        [#if t_level > max_level]
            [#local max_level = t_level /]
        [/#if]
    [/#list]
    [#return max_level + 1 /]
[/#function]
[#-- 获得一个plan的课程组的最深层次 --]
[#function planMaxDepth plan]
    [#local max_level = 0 /]
    [#list plan.topGroups! as group]
        [#local t_level = myMaxDepth(group) /]
        [#if t_level > max_level]
            [#local max_level = t_level /]
        [/#if]
    [/#list]
    [#return max_level /]
[/#function]

[#-- 是叶子节点，叶子节点就是课程或没有课程的课程组 --]
[#function isLeaf obj]
    [#if obj.course??]    [#-- 是planCourse --]
        [#return true /]
    [#else]                [#-- 是courseGroup --]
        [#if (!obj.children?? || obj.children?size == 0) && (!obj.planCourses?? || obj.planCourses?size == 0)]
            [#return true /]
        [/#if]
    [/#if]
    [#return false /]
[/#function]

[#function isLeafGroup obj]
    [#if (obj.children?size == 0) && (obj.planCourses?size == 0)]
        [#return true /]
    [/#if]
    [#return false /]
[/#function]

[#-- 一个课程组的最深的叶子处于第几层 --]
[#function myLeafMaxLevel courseGroup]
    [#if isLeafGroup(courseGroup)]    [#-- 如果是叶子节点 --]
        [#return 1 /]
    [/#if]
    [#if !courseGroup.children?? || courseGroup.children?size == 0] [#-- 不是叶子节点，但是也没有子课程组 --]
        [#return 2 /]
    [/#if]

    [#local max_level = 0 /]
    [#list courseGroup.children! as child]
        [#local t_level = myLeafMaxLevel(child) /]
        [#if t_level > max_level]
            [#local max_level = t_level /]
        [/#if]
    [/#list]
    [#return max_level + 1 /]
[/#function]

[#-- 一个培养计划的最深的叶子处于第几层 --]
[#function planLeafMaxLevel plan]
    [#local max_level = 0 /]
    [#list plan.topGroups! as group]
        [#local t_level = myLeafMaxLevel(group) /]
        [#if t_level > max_level]
            [#local max_level = t_level /]
        [/#if]
    [/#list]
    [#return max_level /]
[/#function]

[#-- 获得当前courseGroup的顶端courseGroup --]
[#function getTopCourseGroup group]
    [#if group.parent??]
        [#return getTopCourseGroup(group.parent) /]
    [#else]
        [#return group /]
    [/#if]
[/#function]

[#-- 获得一个courseGroup在自己的树里在第几层次 --]
[#function myCurrentLevel group]
    [#if group.parent??]
        [#return 1 + myCurrentLevel(group.parent) /]
    [#else]
        [#return 1 /]
    [/#if]
[/#function]

[#macro planMainTitle plan]${plan.program.department.name}&nbsp;${plan.program.major.name}专业[/#macro]
[#macro planSubTitle plan]${("("+ plan.program.direction.name + ")&nbsp;")!}&nbsp; ${plan.program.level.name}&nbsp;培养方案&nbsp;(${plan.program.grade.code})[/#macro]

[#assign displayTeachDepart=true/]
[#assign displayCreditHour=true/]
[#macro i18nName(entity)]${entity.name}[/#macro]

[#macro displayCourse plan,course]
  [#assign course_remark][#if plan.program.degreeCourses?seq_contains(course)]<span style="color:red" title="学位课程">*</span>[/#if][/#assign]
  [#if enableLinkCourseInfo]
   <a href="${ems_base}/edu/course/profile/info/${course.id}" target="_blank">${course.name}${course_remark}</a>[#t/]
  [#else]
    ${course.name}${course_remark}[#t/]
  [/#if]
[/#macro]
[#-- 获得一个课程组所应该colspan多少 --]
[#function fenleiSpan maxFenleiSpan group]
    [#if isLeaf(group)]
        [#-- 2 是因为需要跨 课程代码，课程名称两列 --]
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
            [#if !isLeaf(c)][#local all_children_leaf = false /][#break][/#if]
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

[#macro courseGroupName group]
[#if group.givenName??]${group.givenName}[#else]${group.courseType.name}[/#if]
[/#macro]
[#-- 把自己的向上的一条树统统画出来, eg. 爷爷/儿子/孙子 --]
[#macro drawAllAncestor courseGroup]
    [#local tree = getHierarchyTree(courseGroup) /]
    [#list tree as node]
        [#if (!node.parent??)]
            [#if  (node.children?size < 1) && (node.planCourses?size < 1)]
                <td class="leaf_group" colspan="${fenleiSpan(maxFenleiSpan, node)}">[@courseGroupName node/]</td>
            [/#if]
            [#if (node.children?size < 1) && (node.planCourses?size > 0)]
                <td class="group" colspan="${fenleiSpan(maxFenleiSpan, node)}" width="${fenleiWidth * maxFenleiSpan}px">[@courseGroupName node/]</td>
            [/#if]
            [#if (node.children?size > 0) ]
                <td class="group" colspan="${fenleiSpan(maxFenleiSpan, node)}">[@courseGroupName node/]</td>
            [/#if]
        [#else]
            [#if (node.children?size < 1) && (node.planCourses?size < 1)]
                <td class="leaf_group" colspan="${fenleiSpan(maxFenleiSpan, node)}" >[@courseGroupName node/]</td>
            [/#if]
            [#if (node.children?size < 1) && (node.planCourses?size > 0)]
                <td class="group" colspan="${fenleiSpan(maxFenleiSpan, node)}">
                    [@courseGroupName node/]
                </td>
            [/#if]
            [#if (node.children?size > 0)]
                <td class="group" colspan="${fenleiSpan(maxFenleiSpan, node)}">[@courseGroupName node/]</td>
            [/#if]
        [/#if]
    [/#list]
[/#macro]

[#-- 课程组的一格一格的学分信息 --]
[#macro courseGroupCreditInfo courseGroup]
    [#local i = 1 /]
    [#if  courseGroup.termCredits=="*"]
        [#list i..maxTerm as t]<td>&nbsp;</td>[/#list]
    [#else]
        [#local termCredits = courseGroup.termCreditSeq/]
        [#list termCredits as credit]
          [#if (i<=maxTerm)]
            <td>[#if credit>0]${credit}[#else]&nbsp;[/#if]</td>
            [#if !courseGroup.parent??]
                [#local current_totle=total_term_credit[i?string]!(0) /]
                [#assign total_term_credit=total_term_credit + {i:current_totle+credit?number} /]
                [#local i = i + 1 /]
            [/#if]
          [/#if]
        [/#list]
    [/#if]
[/#macro]

[#-- 计划课程的一格一格的周课时信息 --]
[#macro planCourseWeekHoursInfo planCourse]
    [#list plan.program.startTerm..plan.program.endTerm as i]
        <td>[#if planCourse.terms.contains(i?int)]${(planCourse.course.weekHours)?if_exists}[#else]&nbsp;[/#if]</td>
    [/#list]
[/#macro]
[#-- 计划课程的一格一格的学分信息 --]
[#macro planCourseCreditInfo planCourse]
    [#local plan= planCourse.group.plan/]
    [#list plan.program.startTerm..plan.program.endTerm as i]
      <td>[#if planCourse.terms.contains(i?int)]√[#else]&nbsp;[/#if]</td>
    [/#list]
[/#macro]
[#-- 课程学分要求的叫法--]
[#macro requireLabel courseGroup]
  [#if courseGroup.rank?? && courseGroup.rank.compulsory]学分小计[#else]应修学分[/#if]
[/#macro]
[#-- 需要完善，画出一个课程组 --]
[#macro drawGroup courseGroup courseTermInfoMacro groupTermInfoMacro]
    [#if isLeaf(courseGroup)]
        <tr style="text-align:center">
            [@drawAllAncestor courseGroup /]
            <td>${courseGroup.credits}</td>
            [#if displayCreditHour]<td>${courseGroup.creditHours}</td>[/#if]
            [@groupTermInfoMacro courseGroup /]
            [#if courseGroup.remark??]
              <td class="remark" [#if displayTeachDepart] colspan="2"[/#if]>${courseGroup.remark}</td>
            [#else]
              [#if displayTeachDepart]<td>&nbsp;</td>[/#if]
              <td></td>
            [/#if]
        </tr>
    [#else]
        [#list courseGroup.orderedPlanCourses as planCourse]
           [#if !(term??) || term?? && term?length=0 ||term?? && planCourse.terms.contains(term?number?int)]
            [#assign courseCount = courseCount + 1]
            <tr style="text-align:center">
            [@drawAllAncestor courseGroup /]
            [#local exists_nonleaf_child = false /] [#-- 存在非叶子节点的子组 add on 2012-04-11 --]
            [#list courseGroup.children as c]
                [#if !isLeaf(c) ][#local exists_nonleaf_child=true /][#break][/#if]
            [/#list]
            [#if exists_nonleaf_child]
                <td class="group" colspan="${maxFenleiSpan - myCurrentLevel(courseGroup)}">&nbsp;</td>
            [/#if]

            <td style="text-align: center;">${planCourse.course.code!}</td>
            <td class="course">&nbsp;${courseCount}&nbsp;[@displayCourse courseGroup.plan,planCourse.course/][#if courseGroup.plan.program.degreeCourses?seq_contains(planCourse.course)]<span style="color:red" title="学位课程">*</span>[/#if]</td>
            <td>${(planCourse.course.getCredits(courseGroup.plan.program.level))?default(0)}</td>
            [#if displayCreditHour]<td>[#assign j = planCourse.journal/][#if j.weeks?exists && j.weeks>0]${j.weeks}周[#else]${(j.creditHours)?default(0)}[/#if]</td>[/#if]
            [@courseTermInfoMacro planCourse /]
            [#if displayTeachDepart]<td>[#if planCourse.department??][@i18nName planCourse.department/][#else][@i18nName planCourse.course.department!/][/#if]</td>[/#if]
            <td class="remark">[#if planCourse.compulsory && courseGroup.rank?? && !courseGroup.rank.compulsory]必修 [/#if][#if planCourse.remark?exists]${planCourse.remark!}[#else]&nbsp;[/#if]</td>
          </tr>
         [/#if]
        [/#list]
        [#list courseGroup.children?sort_by("indexno") as child]
            [@drawGroup child courseTermInfoMacro groupTermInfoMacro/]
        [/#list]
        [#if courseGroup.parent?? && courseGroup.autoAddup && courseGroup.children?size==0]
        [#else]
        <tr>
            [@drawAllAncestor courseGroup /]
            <td colspan="${mustSpan + maxFenleiSpan - HierarchyFenleiSpanSum(maxFenleiSpan, courseGroup)}" class="credit_hour summary">[@requireLabel courseGroup/]</td>
            <td class="credit_hour summary">${courseGroup.credits}</td>
            [#if displayCreditHour]<td class="credit_hour summary">[#if courseGroup.creditHours>0]${courseGroup.creditHours!}[/#if]</td>[/#if]
            [@groupTermInfoMacro courseGroup /]
            [#if courseGroup.remark??]
              <td class="remark" [#if displayTeachDepart] colspan="2"[/#if]>${courseGroup.remark}</td>
            [#else]
              [#if displayTeachDepart]<td>&nbsp;</td>[/#if]
              <td></td>
            [/#if]
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

[#-- 有时候必须跨的列数，在这里是课程名称和课程代码两列 --]
[#assign mustSpan = 2/]

[#assign courseCount = 0 /]
[#assign fenleiWidth = 10 /]

[#macro mergeCourseTypeCell plan t_planLevels bottomrows]
function mergeCourseTypeCell(tableId) {
    var table = document.getElementById(tableId)
    for(var x = ${t_planLevels} - 1; x >= 0 ; x--) {
        var content = '';
        var firstY = -1;
        for(var y = 2; y < table.rows.length - ${bottomrows}; y++) {
            if(table.rows[y] == undefined || table.rows[y].cells[x] == undefined) {
                continue;
            }
            if(content == table.rows[y].cells[x].innerHTML && table.rows[y].cells[x].className == 'group') {
                table.rows[y].deleteCell(x);
                table.rows[firstY].cells[x].rowSpan++;
            }
            else {
                content = table.rows[y].cells[x].innerHTML;
                // 如果是纯数字或‘学分小计’则不合并
                if(table.rows[y].cells[x].className != 'group') {
                    content = '';
                }
                firstY = y;
            }
        }
    }
}
[/#macro]

[#macro planFoot plan]
    <p style="text-align:center;color:#6c757d;font-size:10pt;">生效日期：${plan.program.beginOn?string('yyyy-MM-dd')}~${(plan.program.endOn?string('yyyy-MM-dd'))!}&nbsp;
    [#if plan.program.degree??]学位：${plan.program.degree.name }&nbsp;[/#if]
    [#if plan.program.degreeGpa??]学位绩点：${plan.program.degreeGpa }&nbsp;[/#if]
    最后修改时间：${(plan.program.updatedAt?string('yyyy-MM-dd HH:mm:ss'))!}</p>
[/#macro]

[#macro planHead plan]
  <p style="font-weight:bold;font-size:16pt;margin:0px 5px;text-align:center;">${plan.program.grade.code} ${plan.program.department.name} ${plan.program.major.name} ${(plan.program.direction.name)!} ${plan.program.level.name}教学计划表</p>
[/#macro]

[#macro exePlanTitle plan]
${plan.program.grade.code} ${plan.program.department.name} ${plan.program.major.name}专业 ${(plan.program.direction.name)!} ${plan.program.level.name} 执行计划
[/#macro]

[#if Parameters['term']??]
[#assign term = Parameters['term']]
[/#if]
