[@b.head /]

[@b.toolbar title='专业方案管理']
  bar.addItem("相似性对比","comparePlans()");
[/@]

<div class="search-container">
   <div class="search-panel">
      [#include "searchForm.ftl"/]
   </div>
   <div class="search-list">
      [@b.div id="programListFrame" /]
   </div>
</div>
<script type="text/javascript">
  function comparePlans(){
     var url = "${b.url('!compare')}";
     window.open(url);
  }
</script>

[@b.foot/]
