[#ftl /]
[@b.head /]
[#assign doAction="stdAlternativeCourse.action"/]
[@b.toolbar title="个人替代课程管理" /]
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
