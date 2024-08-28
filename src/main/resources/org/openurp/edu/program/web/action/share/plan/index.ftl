[#ftl]
[@b.head/]
[@b.toolbar title="公共课程"/]

<div class="search-container">
   <div class="search-panel">
      [@b.form name="searchForm" action="!search" title="ui.searchForm" target="contentDiv" theme="search"]
         [@b.textfield  name="plan.name" label="名称"/]
         [@b.select  name="plan.level.id" label="培养层次" items=levels empty="..." /]
      [/@]
   </div>
   <div class="search-list">
        [@b.div id="contentDiv" href="!search" /]
   </div>
</div>
[@b.foot/]
