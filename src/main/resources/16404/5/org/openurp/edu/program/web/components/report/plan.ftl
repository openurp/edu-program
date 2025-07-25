[#assign teachPlanLeafLevels = plan.depth/]
[#assign mustSpan = 2/]
[#assign branchSpan = planRender.calcBranchLevel(plan,1?int)/]
[#assign rowNum=1/] [#--开头一个 学院名称占一行--]
[#assign rowsOfHead=2/]
[#if !rowsPerPage??]
[#assign rowsPerPage=35/]
[/#if]

[#if !stdTypeNames??]
  [#assign stdTypeNames]${program.stdTypeNames}[/#assign]
  [#if stdTypeNames?ends_with('生')][#assign stdTypeNames=stdTypeNames[0..stdTypeNames?length-2]/][/#if]
  [#assign stdTypeNames][#if stdTypeNames?contains(program.level.name)]${stdTypeNames}[#else]${program.level.name}（${stdTypeNames}）[/#if][/#assign]
  [#if stdTypeNames=="二学位（第二学士学位）"][#assign stdTypeNames]本科（二学位）[/#assign][/#if]
[/#if]

[#assign shortGroupNames={
       '长学段-通识课模块':'通识课模块',
       '长学段-通识必修课':'长学段/必修',
       '长学段-通识限定选修课':'长学段/限选',
       '长学段-通识自由选修课':'长学段/自由选修',
       '长学段-学科专业课模块':'学科专业课模块',
       '长学段-专业必修课':'长学段/专业必修',
       '长学段-专业选修课':'长学段/专业选修',
       '长学段-专业与创新实践':'实践课模块',
       '长学段-专业与创新实践必修课':'长学段/必修',
       '长学段-专业与创新实践限定选修课':'长学段/限选',
       '短学段-综合素质实践':'实践课模块',
       '短学段-综合素质实践必修课':'短学段/必修',
       '短学段-专业与创新实践':'实践课模块'
       }]
[#assign maxTerm = plan.terms /]
[#assign tableIdx= -1 ]
[#assign courseCount=0/]
[#assign hanziSeq=["零","一","二","三","四","五","六","七","八","九","十"]/]

[#--多级情况下，顶级不绘制--]
[#if branchSpan>1]
  [#assign branchSpan=branchSpan-1/]
[/#if]
[#assign practicalGroups=[]/]
[#function isLeaf obj]
    [#if (obj.children?size == 0)]
      [#if (obj.planCourses?size == 0)]
        [#return true /]
      [#elseif obj.planCourses?size==1 && (obj.rank.id!0)==3] [#--只有一门课程限选课也是叶子节点--]
        [#return true /]
      [/#if]
    [/#if]
    [#return false /]
[/#function]
[#--层级号减一级--]
[#function depthOf group]
  [#local d = group.depth/]
  [#if d>1][#return d-1/][#else][#return d /][/#if]
[/#function]

[#function courseGroupName group]
[#if group.givenName??][#return group.givenName/][#else][#return shortGroupNames[group.courseType.name]!group.courseType.name/][/#if]
[/#function]

[#assign programCourseTags = program.courseTags/]

[#-- 获得一个课程组所应该colspan多少 --]
[#function typeSpan group]
  [#if isLeaf(group)]
    [#-- 2 是因为需要跨 课程代码，课程名称两列 --]
    [#if group.parent??]
      [#if depthOf(group) <= branchSpan && typeSpan(group.parent)==1]
        [#return mustSpan + branchSpan - depthOf(group) /]
      [#else]
        [#return mustSpan/]
      [/#if]
    [#else]
      [#return mustSpan + branchSpan /]
    [/#if]
  [#else]
    [#local all_children_leaf =  true /]
    [#list group.children! as c]
      [#if !isLeaf(c)][#local all_children_leaf = false /][#break][/#if]
    [/#list]
    [#if all_children_leaf]
      [#return branchSpan - depthOf(group) + 1/]
    [#else]
      [#return 1/]
    [/#if]
  [/#if]
[/#function]

[#-- 把自己的向上的一条树统统画出来, eg. 爷爷/父亲  不包括自己 --]
[#macro drawAllAncestor courseGroup drawFreeSpan=true]
    [#local tree = courseGroup.path /]
    [#assign spanUsed=0/]
    [#if tree?size>1]
      [#list tree as node]
        [#if node_index>0 && !isLeaf(node)][#--叶子节点单独处理--]
        [#assign nspan=typeSpan(node)/]
        [#assign spanUsed=spanUsed+nspan/]
        <td class="group" colspan="${nspan}">${courseGroupName(node)}</td>
        [/#if]
      [/#list]
    [#else]
      [#assign nspan=typeSpan(courseGroup)/]
      [#assign spanUsed=spanUsed+nspan/]
      <td class="group" colspan="${nspan}">${courseGroupName(courseGroup)}</td>
    [/#if]
    [#assign freeSpan = (branchSpan-spanUsed) /]
    [#if drawFreeSpan && freeSpan > 0 ]
      <td colspan="${branchSpan-spanUsed}"></td>
    [/#if]
[/#macro]

[#macro displayCourse plan,course]
  ${course.name}<br>${course.enName!}
[/#macro]

[#function isAllChildrenLeaf group]
  [#local all_children_leaf =  true /]
  [#list group.children! as c]
    [#if !c.leaf][#local all_children_leaf = false /][#break][/#if]
  [/#list]
  [#return all_children_leaf /]
[/#function]

[#macro tableHeader plan]
[#assign tableIdx= tableIdx+1]
<table id="plan-table-${plan.id}_${tableIdx}" style="page-break-before:always;" width="100%" class="plan-table"
       data-sheet-name="${program.major.name}[#if program.direction??] ${(program.direction.name)!}[/#if] ${stdTypeNames}"
       data-repeating-rows="2:5" data-zoom="80" data-print-scale="57">
  <colgroup>
    [#list 1..branchSpan as i]<col width="32px"/>[/#list]
    <col width="2.8%"/>
    <col width="7.6%"/>
    <col width="30.1%"/>
    <col width="5%"/>
    <col width="5%"/>
    <col width="4.3%"/>
    <col width="4.3%"/>
    <col width="6.5%"/>
    <col width="6.2%"/>
    <col width="6.2%"/>
    <col width="15%"/>
  </colgroup>
  <thead class="[#if tableIdx>0] table-repeat-header[/#if]">
    [#if tableIdx==0]
    <tr>
      <th colspan="${11+branchSpan}" class="headline" style="border: 0px;">${program.department.name}</th>
    </tr>
    [/#if]
    <tr>
      <th colspan="${11+branchSpan}" class="headline" style="border: 0px;">${program.grade.name}级${program.major.name}[#if program.direction??]（${program.direction.name?replace("方向","")}）[/#if]专业${stdTypeNames}指导性教学计划表</th>
    </tr>
    [#assign levelEnName]${program.level.enName!program.level.name}[/#assign]
    <tr>
      <th colspan="${11+branchSpan}" class="headline" style="border: 0px;">Education Guiding Schedule for ${program.major.enName!'--无英文名--'}[#if program.direction??](${program.direction.enName!'--无英文名--'})[/#if] ${levelEnName} of Grade ${program.grade.code}</th>
    </tr>
    <tr>
      <th rowspan="2" colspan="${branchSpan}">课程<br>模块<br>Course<br>Module</th>
      <th rowspan="2">序号<br>Seq.</th>
      <th rowspan="2">课程编码<br>Course<br>Code</th>
      <th rowspan="2">课程名称<br>Courses</th>
      <th rowspan="2">总学分<br>Credits</th>
      <th rowspan="2">总学时<br>Hours</th>
      <th colspan="2" class="period1">学时分配<br>Allocation of Period</th>
      <th rowspan="2">课程<br>性质<br>Course<br>Nature</th>
      <th rowspan="2">开设<br>学期<br>Semester<br>(长/短)</th>
      <th rowspan="2">开课<br>单位<br>School</th>
      <th rowspan="2">备注<br>Notice</th>
    </tr>
    <tr>
      [#list natures as nature]
      <th class="period2">${nature.name}<br>学时<br>[#if nature.id==1]Theoretical[#else]Practical[/#if]</th>
      [/#list]
    </tr>
    [#assign rowNum=rowNum+4/]
  </thead>
  <tbody>
[/#macro]

[#macro drawGroup courseGroup]
  [#if isLeaf(courseGroup) && courseGroup.planCourses?size==0] [#--如果不判断planCourse的数量，会把只有一门课程限选组也绘制出来--]
    [#assign courseCount = courseCount + 1]

    [#--判断上下合并单元格的显示，能否在一页上,如果不在一页上，则放到下一页--]
    [#if courseGroup.parent?? && isAllChildrenLeaf(courseGroup.parent) && courseGroup.parent.planCourses?size=0]
      [#if courseGroup.id=courseGroup.parent.children?sort_by('indexno')?first.id]
        [#if rowNum + courseGroup.parent.children?size > rowsPerPage]
          [#assign rowNum=rowNum+ (rowsPerPage - rowNum % rowsPerPage)/]
        [/#if]
      [/#if]
    [/#if]

    [#assign rowNum=rowNum+1/]
    [#if rowNum % rowsPerPage==1]</tbody></table>[@tableHeader courseGroup.plan/][/#if]
    <tr>
      [@drawAllAncestor courseGroup /]
      <td>${courseCount}</td>
      <td colspan="2" class="course">${courseGroup.name}<br>${courseGroup.courseType.enName!'MISSING ENGLISH NAME'}</td>
      [#--第一个子组显示上级组的内容,这种情况适合于，父组下都是组，没有课程--]
      [#if courseGroup.parent?? && isAllChildrenLeaf(courseGroup.parent) && courseGroup.parent.planCourses?size=0]
        [#if courseGroup.id=courseGroup.parent.children?sort_by('indexno')?first.id]
          [#local myParent=courseGroup.parent]
          <td rowspan="${myParent.children?size}">${myParent.credits}</td>
          <td rowspan="${myParent.children?size}">${myParent.creditHours}</td>
          [#local groupHours = myParent.getHours(natures)/]
          [#list natures as nature]
            <td rowspan="${myParent.children?size}">[#if (groupHours.get(nature)!0)>0]${groupHours.get(nature)}[/#if]</td>
          [/#list]
        [/#if]
      [#else]
        <td>${courseGroup.credits}</td>
        <td>${courseGroup.creditHours}</td>
        [#local groupHours = courseGroup.getHours(natures)/]
        [#list natures as nature]
          <td>[#if (groupHours.get(nature)!0)>0]${groupHours.get(nature)}[/#if]</td>
        [/#list]
      [/#if]
      <td>${(courseGroup.rank.name)!"--"}</td>
      <td>${termHelper.getTermText(courseGroup)}</td>
      <td>${courseGroup.departments!'—'}</td>
      <td class="remark">&nbsp;${courseGroup.remark!}</td>
    </tr>
  [#else]

    [#--顶级课程组(长学段教学，短学段教学下的组)--]
    [#--添加一个抬头说明类似这样 （一）长学段教学| 1.3长学段-专业与创新实践 Long Semester—Professional and Innovation Practial Education --]
    [#if depthOf(courseGroup)==1 && (courseGroup.parent?? || courseGroup.planCourses?size>0)]
      [#assign courseCount=0/]
      [#assign rowNum=rowNum+1/]
      [#--标题不适合放在页脚--]
      [#if rowNum % rowsPerPage==0][#assign rowNum=rowNum+1/][/#if]
      [#if rowNum % rowsPerPage==1]</tbody></table>[@tableHeader courseGroup.plan/][/#if]
      <tr  style="text-align:left">
        <td colspan="${branchSpan+11}" class="level2module">
          [#if courseGroup.parent??]
         （${hanziSeq[courseGroup.parent.index]}）${courseGroup.parent.name}| ${courseGroup.indexno}${courseGroup.name} ${courseGroup.courseType.enName!'无'}
          [#else]
          （${hanziSeq[courseGroup.index]}）${courseGroup.name} ${courseGroup.courseType.enName!'无'}
          [/#if]
        </td>
      </tr>
    [/#if]

    [#list cluster.cluster(courseGroup) as planCourse]
      [#if !(term??) || term?? && term?length=0 ||term?? && planCourse.terms.contains(term?number?int)]
      [#assign courseCount = courseCount + 1]
      [#assign rowNum=rowNum+1/]
      [#if rowNum % rowsPerPage==1]</tbody></table>[@tableHeader courseGroup.plan/][/#if]
      <tr>
      [@drawAllAncestor courseGroup /]

      <td>${courseCount}</td>
      <td>${planCourse.course.code}</td>
      <td class="course">[@displayCourse courseGroup.plan,planCourse.course/]</td>
      [#assign credits =(planCourse.course.getCredits(courseGroup.plan.program.level))?default(0)/]
      [#assign cj = planCourse.course.getJournal(program.grade)/]
      <td>[#if credits>0]${credits}[#else]※[/#if]</td>
      <td>[#if credits>0][#if cj.weeks?? && cj.weeks>0][#if cj.weeks>15]每周[#else]${cj.weeks}周[/#if][#else]${cj.creditHours}[/#if][#else]※[/#if]</td>
      [#list natures as nature]
        [#if cj.weeks?? && cj.weeks>0]
          <td>[#if nature.id==9][#if cj.weeks<16]${cj.weeks}周[/#if][#else]&nbsp;[/#if]</td>
        [#else]
        <td>[#if (cj.getHour(nature)!0)>0][#if credits>0]${cj.getHour(nature)}[#else]※[/#if][/#if]</td>
        [/#if]
      [/#list]
      <td>${(courseGroup.rank.name)!}</td>
      <td>${termHelper.getTermText(planCourse)}</td>
      <td>[#if planCourse.course.name?contains("普通话水平")]校语委[#else]${cj.department.shortName!cj.department.name}[/#if]</td>
      <td class="remark">
        [#if planCourse.compulsory && !courseGroup.rank.compulsory]必选 [/#if]
        [#if cj.examMode.id==1]${cj.examMode.name}&nbsp;[/#if][#t/]
        [#if planCourse.remark?exists]${planCourse.remark!}&nbsp;[/#if][#t/]
        [#if programCourseTags.get(planCourse.course)??][#list programCourseTags.get(planCourse.course) as t]${t.name}&nbsp;[/#list][/#if][#t/]
        [#if cj.tags?size>0][#list cj.tags as t]${t.name}[#sep]&nbsp;[/#list][/#if][#t/]
      </td>
      </tr>
     [/#if]
    [/#list]

    [#if !isLeaf(courseGroup)]
      [#--绘制子组--]
      [#list courseGroup.children?sort_by("indexno") as child]
        [@drawGroup child/]
      [/#list]

      [#--该组小计--]
      [#assign orphanSon=false/][#--一个和父组一样学分的独组--]
      [#if courseGroup.parent?? && courseGroup.parent.children?size==1 && courseGroup.credits==courseGroup.parent.credits]
        [#assign orphanSon=true/]
      [/#if]
      [#if !orphanSon && (courseGroup.credits>0 || courseGroup.creditHours>0)]
        [#assign rowNum=rowNum+1/]
        [#--结尾不好另起一页，放在下一页的首页很难看--]
        [#if rowNum % rowsPerPage==1][#assign rowNum=rowNum-1/][/#if]
        <tr style="font-weight:bold;">
           [#assign summarySpan=3+branchSpan/]
           [#if courseGroup.parent??]
             [@drawAllAncestor courseGroup false/]
             [#assign summarySpan=3+freeSpan/]
           [/#if]
           <td colspan="${summarySpan}">
             [#local groupName=courseGroupName(courseGroup)/]
             [#if groupName=='长学段教学']长学段学分小计<br>Subtotal of Credit Requirement for Long Semesters
             [#elseif groupName=='短学段教学']实践课（短学段）学分要求<br>Credit Requirement for Practical Education (Short Semester)[#assign practicalGroups=practicalGroups+[courseGroup]/]
             [#elseif groupName=='通识课模块']通识课模块学分小计<br>Subtotal of Credit Requirement for Liberal Education
             [#elseif groupName=='学科专业课模块']学科专业课模块学分小计<br>Subtotal of Credit Requirement for Professsional Education
             [#elseif groupName=='实践课模块']
               [#if courseGroup.courseType.name?contains("长学段")]
                 实践课（长学段）学分要求<br>Credit Requirement for Practical Education (Long Semester)
                 [#assign practicalGroups=practicalGroups+[courseGroup]/]
               [#else]
                 [#if courseGroup.rank?? && courseGroup.rank.id==1]学分要求<br>Credit Requirement[#else]学分应选要求<br>Selective Credit Requirement[/#if]
               [/#if]
             [#else]
               [#if courseGroup.rank?? && courseGroup.rank.id==1]学分要求<br>Credit Requirement[#else]学分应选要求<br>Selective Credit Requirement[/#if]
             [/#if]
           </td>
           <td>${courseGroup.credits}</td>
           <td>${courseGroup.creditHours}</td>
           [#assign ghours = courseGroup.getHours(natures)/]
           [#list natures as nature]
           <td>${ghours.get(nature)!}</td>
           [/#list]
           <td></td><td></td><td></td><td></td>
        </tr>
      [/#if]
      [#--绘制实践课汇总，这是单独加出来的--]
      [#if practicalGroups?size==2]
        [#assign rowNum=rowNum+1/]
        [#if rowNum % rowsPerPage==1]</tbody></table>[@tableHeader courseGroup.plan/][/#if]
        <tr style="font-weight:bold;">
          <td colspan="${3+branchSpan}">实践课模块小计<br>Subtotal of Practical Education</td>
          <td>[#assign practicalCredits=0/][#list practicalGroups as g][#assign practicalCredits=practicalCredits+g.credits/][/#list]${practicalCredits}</td>
          <td>[#assign practicalHours=0/][#list practicalGroups as g][#assign practicalHours=practicalHours+g.creditHours/][/#list]${practicalHours}</td>

          [#list natures as nature]
            [#assign practicalHours=0/]
            [#list practicalGroups as g]
              [#assign ghours = g.getHours(natures)/]
              [#assign practicalHours=practicalHours+ghours.get(nature)!0/]
            [/#list]
          <td>${practicalHours!}</td>
          [/#list]
          <td></td><td></td><td></td><td></td>
        </tr>
        [#--销毁，否则后续又会画出改组--]
        [#assign practicalGroups=[]/]
      [/#if]
    [/#if]
  [/#if]
[/#macro]

[#macro mergeCourseTypeCell plan t_planLevels bottomrows]
    function mergeCourseTypeCell(tableId) {
        var table = document.getElementById(tableId)
        // 从最后一列开始，从右向左
        for(var x = ${t_planLevels} - 1; x >= 0 ; x--) {
            var content = '';
            var firstY = -1;
            //从第二行开始，从上到下
            for(var y = 2; y < table.rows.length - ${bottomrows}; y++) {
                if(table.rows[y] == undefined || table.rows[y].cells[x] == undefined) {
                  content = '';
                  firstY = y+1;
                  continue;
                }
                var cell = jQuery(table.rows[y].cells[x]);
                var cellContent = table.rows[y].cells[x].innerHTML;
                if(content == cellContent && cell.hasClass('group')) {
                  table.rows[y].deleteCell(x);
                  var mergedCell = table.rows[firstY].cells[x];
                  mergedCell.rowSpan++;
                  if(mergedCell.rowSpan>3){
                    jQuery(mergedCell).addClass("vertical-group");
                  }
                }else {
                  content = cellContent;
                  // 如果是纯数字或‘学分小计’则不合并
                  if(!cell.hasClass('group') ) {
                      content = '';
                  }
                  firstY = y;
                }
            }
        }
    }
[/#macro]

    [#assign tableIdx= -1 ]
    [@tableHeader plan/]
    [#list plan.topGroups! as courseGroup]
      [@drawGroup courseGroup/]
    [/#list]
    [#--绘制最后一行--]
      <tr style="font-weight:bold;">
        <td class="summary" colspan="${branchSpan + 3}">专业学分要求合计  Total Credit Requirement</td>
        <td class="credit_hour summary">${plan.credits!}</td>
        <td class="credit_hour summary">${plan.creditHours}</td>
        [#assign phours = plan.getHours(natures)/]
        [#list natures as nature]
        <td>${phours.get(nature)!}</td>
        [/#list]
        <td></td><td></td><td></td><td></td>
      </tr>
      <tr>
       <td colspan="${branchSpan+11}" class="footer">注：①实践课部分，除学校统一安排的实践教学环节外，由学院组织实施。②综合能力素质测评不占学分。获得毕业资格，需达到综合能力素质测评要求。</td>
      </tr>
      <tr><td  colspan="${branchSpan+11}" class="footer">&nbsp;</td></tr>
      <tr>
       <td colspan="${branchSpan+11}" class="footer">制定人Drafter(专业主任 Director of Major):</td>
      </tr>
      <tr><td  colspan="${branchSpan+11}" class="footer">&nbsp;</td></tr>
      <tr>
       <td colspan="${branchSpan+11}" class="footer">审核人Reviewer(教学副院长 Vice Dean of School)：</td>
      </tr>
      <tr><td  colspan="${branchSpan+11}" class="footer">&nbsp;</td></tr>
      <tr>
       <td colspan="${branchSpan+11}" class="footer">学院院长 Dean of School：</td>
      </tr>
    </tbody>
  </table>
  <br>
<script>
[#assign bottomRows=1/]
[#if plan.program.remark??][#assign bottomRows=2/][/#if]
[@mergeCourseTypeCell plan branchSpan 0/]
[#list 0..tableIdx as t]
mergeCourseTypeCell("plan-table-${plan.id}_${t}");
[/#list]
</script>
