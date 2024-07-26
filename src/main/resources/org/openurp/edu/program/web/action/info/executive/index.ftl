[#ftl]
[@b.head/]
[@b.toolbar title='执行计划查询']
[/@]
<div class="search-container">
   <div class="search-panel">
      [#include "searchForm.ftl"/]
   </div>
   <div class="search-list">
      [@b.div id="planListFrame"  /]
   </div>
</div>
<script type="text/javascript">
  jQuery(function() {
      bg.form.submit(document.planSearchForm);
  });
</script>
[@b.foot /]
