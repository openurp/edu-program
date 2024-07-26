[#ftl]
[@b.head /]
<div align="center" >
    <h5>培养计划对比</h5>
</div>

[#if diffResults?size ==0]
    <h6 align="center">两个计划完全一致。</h6>
[#else]
<div class="container">
    <table class="grid-table" style="planCourse" width="100%" align="center">
      <thead class="grid-head">
        <tr align="center" class="darkColumn">
            <th colspan="7" width="50%"><b>${left.program.grade.name?html} ${left.program.level.name} ${left.program.department.name} ${left.program.major.name} ${(left.program.direction.name)!}</b></th>
            <th colspan="7" width="50%"><b>${right.program.grade.name?html} ${right.program.level.name} ${right.program.department.name} ${right.program.major.name} ${(right.program.direction.name)!}</b></th>
        </tr>
      </thead>
    </table>
    <table class="grid-table" style="text-align: center;" width="100%" >
      <thead class="grid-head">
        <tr align="center" class="darkColumn">
            <th width="10%">分类</th>
            <th width="7%">代码</th>
            <th width="20%">名称</th>
            <th width="4%">学时</th>
            <th width="4%">学分</th>
            <th width="5%">学期</th>

            <th width="7%">代码</th>
            <th width="20%">名称</th>
            <th width="4%">学时</th>
            <th width="4%">学分</th>
            <th width="5%">学期</th>
            <th width="10%">分类</th>
        </tr>
      </thead>
    [#list diffResults as diffResult]
        [#list diffResult.commons as c]
        <tr>
          [#assign lpc= c._1/]
          [#assign rpc= c._2/]
          [#if c_index == 0 ]
          <td rowspan="${diffResult.diffCount}">[#if diffResult.left??]${diffResult.name}[/#if]</td>
          [/#if]
          <td>${(lpc.course.code)!}</td>
          <td class="ready">${lpc.course.name}</td>
          <td>${(lpc.course.creditHours)!}</td>
          <td [#if lpc.course.defaultCredits != rpc.course.defaultCredits] style="color:red"[/#if]>${(lpc.course.defaultCredits)!}</td>
          <td [#if lpc.terms!=rpc.terms] style="color:red"[/#if]>${termHelper.getTermText(lpc)!}</td>
          <td>${(rpc.course.code)!}</td>
          <td class="ready">${rpc.course.name}</td>
          <td [#if lpc.course.defaultCredits!=rpc.course.defaultCredits] style="color:red"[/#if]>${(rpc.course.creditHours)!}</td>
          <td>${(rpc.course.defaultCredits)!}</td>
          <td [#if lpc.terms!=rpc.terms] style="color:red"[/#if]>${termHelper.getTermText(rpc)!}</td>
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
                [#assign lpc = left[i]/]
                <td>${(lpc.course.code)!}</td>
                <td class="ready">${lpc.course.name}</td>
                <td>${(lpc.course.creditHours)!}</td>
                <td>${(lpc.course.defaultCredits)!}</td>
                <td>${termHelper.getTermText(lpc)!}</td>
            [#else]
                <td></td>
                <td></td>
                <td></td>
                <td></td>
                <td></td>
            [/#if]
            [#--这里是专业培养计划的东西--]
            [#if i &lt; right?size]
                [#assign rpc = right[i] /]
                <td>${(rpc.course.code)!}</td>
                <td class="ready">${rpc.course.name}</td>
                <td>${(rpc.course.creditHours)!}</td>
                <td>${(rpc.course.defaultCredits)!}</td>
                <td>${termHelper.getTermText(rpc)!}</td>
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
