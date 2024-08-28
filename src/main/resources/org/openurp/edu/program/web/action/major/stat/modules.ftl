[@b.head/]
<p style="text-align:center;margin:0px;">${grade.name}级 ${level.name} 培养方案模块学分学时统计
[#if (request.getHeader('x-requested-with')??) || Parameters['x-requested-with']??]
  [@b.a href="!modules?grade.id="+grade.id+"&level.id="+ level.id target="_blank" class="notprint"]<i class="fas fa-print"></i>打印[/@]&nbsp;&nbsp;
  [@b.a href="!moduleExcel?grade.id="+grade.id+"&level.id="+ level.id target="_blank" class="notprint"]<i class="fas fa-file-excel"></i>导出[/@]
[/#if]
</p>
<div class="container-fluid">
    <table class="grid-table">
      <colgroup>
        <col width="4%"/>
        <col width="5%"/>
        <col width="5%"/>
        <col width="5%"/>
        <col />
      </colgroup>
      <thead class="grid-head">
        <tr>
          <td [#if hasLevel2]rowspan="2"[/#if]>序号</td>
          <td [#if hasLevel2]rowspan="2"[/#if]>培养层次</td>
          <td [#if hasLevel2]rowspan="2"[/#if]>学科门类</td>
          <td [#if hasLevel2]rowspan="2"[/#if]>院系</td>
          <td [#if hasLevel2]rowspan="2"[/#if]>专业</td>
          <td [#if hasLevel2]rowspan="2"[/#if]>学分数</td>
          [#list l1Types as n]
          <td colspan="[#if l2Types.get(n)??]${l2Types.get(n)?size +1}[#else]1[/#if]" [#if hasLevel2 && !l2Types.get(n)??]rowspan="2"[/#if]>${n.name}</td>
          [/#list]
        </tr>
        [#if hasLevel2]
        <tr>
          [#list l1Types as n]
            [#if l2Types.get(n)??]
              <td></td>
              [#list l2Types.get(n) as m]
              <td>${m.shortName!m.name}</td>
              [/#list]
            [/#if]
          [/#list]
        </tr>
        [/#if]
      </thead>
      <tbody class="grid-body">
      [#list plans as plan]
      <tr>
        <td>${plan_index+1}</td>
        <td>${plan.program.level.name}</td>
        <td>[#list plan.program.major.disciplines as d]${d.category.name}[#break/][/#list]</td>
        <td>${(plan.program.department.shortName)!plan.program.department.name}</td>
        <td>${plan.program.major.name} ${(plan.program.direction.name)!}</td>
        <td>${plan.credits}</td>
        [#list l1Types as n]
        <td>${(plan.getGroup(n.name).credits)!}</td>
        [#if l2Types.get(n)??]
          [#list l2Types.get(n) as m]
          <td>${(plan.getGroup(m.name).credits)!}</td>
          [/#list]
        [/#if]
        [/#list]
      </tr>
      [/#list]
    </tbody>
  </table>
</div>
[@b.foot/]
