[@b.head /]

[@b.toolbar title='执行计划匹配统计']
[/@]
<div class="search-container">
   <div class="search-panel">
    [@b.form name="searchForm" action="!matchResult" title="ui.searchForm" target="planListFrame" theme="search"]
        [@b.select name="grade.id" label="年级" items=grades required="true" value=firstGrade/]
        [@b.select name="level.id" items=levels empty="..." label="培养层次"/]
        [@b.select name="stdType.id" items=stdTypes empty="..." label="学生类别"/]
        [@b.select name="department.id" items=departments empty="..." label="院系"/]
    [/@]
   </div>
   <div class="search-list">
      [@b.div id="planListFrame" /]
   </div>
</div>
<script>
    jQuery(function(){
        bg.form.submit(document.searchForm);
    });
</script>
[@b.foot/]
