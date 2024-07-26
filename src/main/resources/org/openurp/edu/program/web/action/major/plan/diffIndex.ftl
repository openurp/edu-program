[@b.head/]
  [@b.toolbar title="培养计划对比"]
    bar.addBack();
  [/@]
  <div style="margin:auto;text-align:center;">
  [@b.form name="diffForm" action="!diff"  target="diff-result"]
    [@b.select name="left.id" items=lefts empty="..." value=left required="true" option=r"${item.name} ${item.level.name}" label="计划1" style="width:300px;"/]
    [@b.select name="right.id" items=rights empty="..." value=right required="true" option=r"${item.name} ${item.level.name}" label="计划2" style="width:300px;"/]
    [@b.submit value="比较" class="btn btn-sm btn-outline-primary"/]
  [/@]
  </div>
  [#if right?? && left??]
  [@b.div id="diff-result" href="!diff?left.id=${left.id}&right.id=${right.id}"/]
  [#else]
  [@b.div id="diff-result"/]
  [/#if]
[@b.foot/]
