[@b.head/]
<p style="text-align:center;margin:0px;">${grade.name}级 ${level.name} 培养方案开课院系承担量统计</p>
<div class="container-fluid">
  <table class="grid-table" id="task_table" style="width:${200+35*(departs?size*3+otherDeparts?size*2)}px">
    <colgroup>
      <col width="3%"/>
      <col width="2%"/>
      <col width="10%"/>
      <col width="2%"/>
      [#assign avgWidth = 85/((departs?size*3)+(otherDeparts?size*2))/]
      [#list departs as t]<col width="${avgWidth}%"/><col width="${avgWidth}%"/><col width="${avgWidth}%"/>[/#list]
      [#list otherDeparts as t]<col width="${avgWidth}%"/><col width="${avgWidth}%"/>[/#list]
    </colgroup>
    <thead class="grid-head">
      <tr>
        <th rowspan="2">院系</th>
        <th rowspan="2">序号</th>
        <th rowspan="2">专业</th>
        <th rowspan="2">班级数</th>
        [#list departs as depart]
        <th colspan="3">${depart.shortName!depart.name}</th>
        [/#list]
        [#list otherDeparts as depart]
        <th colspan="2">${depart.shortName!depart.name}</th>
        [/#list]
      </tr>
      <tr>
        [#list departs as depart]
        <th>学分</th>
        <th>本院系班学分</th>
        <th>非本院系班学分</th>
        [/#list]
        [#list otherDeparts as depart]
        <th>学分</th>
        <th>非本院系班学分</th>
        [/#list]
      </tr>
    </thead>
    <tbody class="grid-body">
    [#assign curDepart='--'/]
    [#assign curPlanIdx=1/]
    [#list plans as plan]
      [#assign stat = stats.get(plan)/]
      <tr>
        <td>${(plan.program.department.shortName)!plan.program.department.name}</td>
        <td>[#if plan.program.department.name == curDepart][#assign curPlanIdx = curPlanIdx +1/][#else][#assign curPlanIdx=1/][#assign curDepart=plan.program.department.name/][/#if]
        ${curPlanIdx}
        </td>
        <td>${plan.program.major.name} ${(plan.program.direction.name)!}</td>
        <td>${stat.squadCount}</td>
        [#list departs as depart]
        <td>[#if stat.getDepartCredits(depart)>0]${stat.getDepartCredits(depart)}[/#if]</td>
        [#if depart == plan.program.department]
        <td>[#if stat.getDepartSquadCredits(depart)>0]${stat.getDepartSquadCredits(depart)}[/#if]</td>
        <td></td>
        [#else]
        <td></td>
        <td>[#if stat.getDepartSquadCredits(depart)>0]${stat.getDepartSquadCredits(depart)}[/#if]</td>
        [/#if]
        [/#list]

        [#list otherDeparts as depart]
        <td>[#if stat.getDepartCredits(depart)>0]${stat.getDepartCredits(depart)}[/#if]</td>
        <td>[#if stat.getDepartSquadCredits(depart)>0]${stat.getDepartSquadCredits(depart)}[/#if]</td>
        [/#list]
      </tr>
    [/#list]
    </tbody>
  </table>
</div>
<script>
  function mergeDepart(tableId) {
    var table = document.getElementById(tableId)
    // 从最后一列开始，从右向左
    var x = 0;
    var content = '';
    var firstY = -1;
    //从第二行开始，从上到下
    for(var y = 2; y < table.rows.length - 0; y++) {
      if(table.rows[y] == undefined || table.rows[y].cells[x] == undefined) {
        content = '';
        firstY = y+1;
        continue;
      }
      var cell = jQuery(table.rows[y].cells[x]);
      var cellContent = table.rows[y].cells[x].innerHTML;
      if(content == cellContent) {
        table.rows[y].deleteCell(x);
        var mergedCell = table.rows[firstY].cells[x];
        mergedCell.rowSpan++;
        if(mergedCell.rowSpan>3){
          jQuery(mergedCell).addClass("vertical-group");
        }
      }else {
        content = cellContent;
        firstY = y;
      }
    }
  }
  jQuery(function() {
    mergeDepart('task_table');
  });
</script>
[@b.foot/]
