[#ftl]
[@b.head /]

[@b.toolbar title="培养计划"][/@]
<div align="center" >
    <h5>${executivePlan.program.grade.name?html} ${executivePlan.program.level.name} ${executivePlan.program.department.name}
    ${executivePlan.program.major.name} ${(executivePlan.program.direction.name)!} 执行计划和培养计划对比</h5>
</div>

[#if diffResults?size ==0]
    <h6 align="center">该年份类别的培养计划和原始培养计划完全一致。</h6>
[#else]
<div class="container">
    <table class="grid-table" style="planCourse" width="100%" align="center">
      <thead class="grid-head">
        <tr align="center" class="darkColumn">
            <th colspan="7" width="50%"><b>执行计划</b></th>
            <th colspan="7" width="50%"><b>培养计划</b></th>
        </tr>
      </thead>
    </table>
    <table class="grid-table" style="planCoursetext-align: center;" width="100%" >
      <thead class="grid-head">
        <tr align="center" class="darkColumn">
            <th width="15%">分类</th>
            <th width="7%">代码</th>
            <th width="16%">名称</th>
            <th width="4%">学时</th>
            <th width="4%">学分</th>
            <th width="4%">学期</th>

            <th width="7%">代码</th>
            <th width="16%">名称</th>
            <th width="4%">学时</th>
            <th width="4%">学分</th>
            <th width="4%">学期</th>
            <th width="15%">分类</th>
        </tr>
      </thead>
    [#list diffResults as diffResult]
        [#list diffResult.commons as c]
        <tr>
          [#assign epc= c._1/]
          [#assign mpc= c._2/]
          [#if c_index == 0 ]
          <td rowspan="${diffResult.diffCount}">[#if diffResult.left??]${diffResult.name}[/#if]</td>
          [/#if]
          <td>${(epc.course.code)!}</td>
          <td class="ready">${epc.course.name}</td>
          <td>${(epc.course.creditHours)!}</td>
          <td>${(epc.course.defaultCredits)!}</td>
          <td>${(epc.terms)!}</td>
          <td>${(mpc.course.code)!}</td>
          <td class="ready">${mpc.course.name}</td>
          <td>${(mpc.course.creditHours)!}</td>
          <td>${(mpc.course.defaultCredits)!}</td>
          <td>${(mpc.terms)!}</td>
          [#if c_index == 0 ]
          <td rowspan="${diffResult.diffCount}">[#if diffResult.right??]${diffResult.name}[/#if]</td>
          [/#if]
        </tr>
        [/#list]

        [#assign size = diffResult.diffCount - diffResult.commons?size/]
        [#assign left = (diffResult.left.courses)![]/]
        [#assign right = (diffResult.right.courses)![]/]
        [#list 0..(size - 1 ) as i]
            [#if size == 0][#break][/#if]
            <tr>
            [#if i == 0 && diffResult.commons?size==0]
                <td rowspan="${diffResult.diffCount}">[#if diffResult.left??]${diffResult.name}[/#if]</td>
            [/#if]
            [#if i &lt; left?size]
                [#assign epc = left[i]/]
                <td>${(epc.course.code)!}</td>
                <td class="ready">${epc.course.name}</td>
                <td>${(epc.course.creditHours)!}</td>
                <td>${(epc.course.defaultCredits)!}</td>
                <td>${(epc.terms)!}</td>
            [#else]
                <td></td>
                <td></td>
                <td></td>
                <td></td>
                <td></td>
            [/#if]
            [#--这里是专业培养计划的东西--]
            [#if i &lt; right?size]
                [#assign mpc = right[i] /]
                <td>${(mpc.course.code)!}</td>
                <td class="ready">${mpc.course.name}</td>
                <td>${(mpc.course.creditHours)!}</td>
                <td>${(mpc.course.defaultCredits)!}</td>
                <td>${(mpc.terms)!}</td>
            [#else]
                <td></td>
                <td></td>
                <td></td>
                <td></td>
                <td></td>
            [/#if]

            [#if i == 0  && diffResult.commons?size==0]
                <td rowspan="${diffResult.diffCount}">[#if diffResult.right??]${diffResult.name}[/#if]</td>
            [/#if]
            </tr>
        [/#list]
    [/#list]
    </table>
 </div>
[/#if]

[@b.foot /]
