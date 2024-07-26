[#ftl]
[@b.form name="searchForm" action="!search" title="ui.searchForm" target="exemptList" theme="search"]
    [@b.textfield name="exempt.std.code" label="学号" maxlength="15"/]
    [@b.textfield name="exempt.std.name" label="姓名" maxlength="10"/]
    [@b.textfield name="exempt.std.state.grade" label="年级" maxlength="10"/]
    [@b.select name="exempt.std.state.department.id" items=departs empty="..." label="院系"/]
    [@b.textfield name="exempt.course.code" label="课程代码" maxlength="30"/]
    [@b.textfield name="exempt.course.name" label="课程名称" maxlength="30"/]
    <input type="hidden" name="orderBy" value="exempt.updatedAt desc"/>
[/@]
<script type="text/javascript">
  jQuery(function() {
      bg.form.submit(document.searchForm);
  });
</script>
