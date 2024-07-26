[#ftl]
[@b.form name="searchForm" action="!search" title="ui.searchForm" target="planListFrame" theme="search"]
    [@b.textfield name="exempt.fromGrade.code" label="年级" maxlength="7"/]
    [@b.textfield name="exempt.course.name" label="课程名称" maxlength="30"/]
    [@b.textfield name="exempt.courseType.name" label="课程类别" maxlength="30"/]
    [@base.code type='std-types' name='stdType.id'  label="学生类别" /]
[/@]
<script type="text/javascript">
  jQuery(function() {
      bg.form.submit(document.searchForm);
  });
</script>
