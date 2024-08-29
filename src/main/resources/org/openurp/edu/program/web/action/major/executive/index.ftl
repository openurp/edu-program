[@b.head /]

[@b.toolbar title='执行计划管理']
   bar.addItem("匹配统计", "planMatching()");
[/@]
<div class="search-container">
   <div class="search-panel">
      [#include "searchForm.ftl"/]
   </div>
   <div class="search-list">
      [@b.div id="planListFrame" /]
   </div>
</div>
<script>
    function planMatching() {
        bg.form.submit(document.searchForm, '${b.url('!matchIndex')}' , '_blank');
    }
</script>
[@b.foot/]
