[#ftl /]
[@b.head /]
[#include "../major/nav.ftl"/]
<div class="search-container">
   <div class="search-panel">
    [#include "searchForm.ftl"/]
   </div>
   <div class="search-list">
     [@b.div id="stdAlternativeCourseFrame" /]
   </div>
</div>

<script>
    jQuery(function(){
      bg.form.submit(document.searchForm);
    });
</script>
[@b.foot /]
