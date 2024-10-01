[@b.form name="searchForm" action="!search" title="ui.searchForm" target="courseListFrame" theme="search"]
    [@b.textfield name="pc.group.plan.program.grade.code" label="年级" maxlength="7"/]
    [@b.textfield name="pc.course.code" label="课程代码"/]
    [@b.textfield name="pc.course.name" label="课程名称"/]
    [@b.select name="pc.group.plan.program.level.id" items=levels empty="..." label="培养层次"/]
    [#if educationTypes?size>1]
    [@b.select name="pc.group.plan.program.eduType.id" items=educationTypes empty="..." label="培养类型"/]
    [/#if]
    [@b.select name="pc.group.plan.program.department.id" items=departments empty="..." label="院系"/]
    [@b.select name="pc.group.plan.program.major.id" items=majors empty="..." label="专业"/]
    [@b.textfield name="pc.group.plan.program.direction.name" label="方向"/]
    [@b.textfield name="pc.group.courseType.name" label="课程类别"/]
    <input type="hidden" name="orderBy" value="pc.group.plan.program.beginOn desc"/>
[/@]

<script>
    jQuery(function(){
        bg.form.submit(document.searchForm);
    });
</script>
