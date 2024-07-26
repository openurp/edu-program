[#ftl]
[@b.head /]
[@b.toolbar title='专业替代课程管理'][/@]
<div class="search-container">
   <div class="search-panel">
      [#include "searchForm.ftl"/]
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

[@b.foot /]
