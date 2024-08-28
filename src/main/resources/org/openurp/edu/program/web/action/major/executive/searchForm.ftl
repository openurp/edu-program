[@b.form name="searchForm" action="!search" title="ui.searchForm" target="planListFrame" theme="search"]
    [@b.textfield name="plan.program.grade.code" label="年级" maxlength="7"/]
    [@b.select name="plan.program.level.id" items=levels empty="..." label="培养层次"/]
    [#if educationTypes?size>1]
    [@b.select name="plan.program.eduType.id" items=educationTypes empty="..." label="培养类型"/]
    [/#if]
    [@b.select name="fake.program.stdType.id" items=stdTypes empty="..." label="学生类别"/]
    [@b.select name="plan.department.id" items=departments empty="..." label="院系"/]
    [@b.select name="plan.program.major.id" items=majors empty="..." label="专业"/]
    [@b.textfield name="plan.program.direction.name" label="方向"/]
    [@b.radios label="是否有效" name="fake.valid" value='1' items={'1':'是', '0':'否'}/]
    <input type="hidden" name="orderBy" value="plan.program.beginOn desc"/>
[/@]

<script>
    jQuery(function(){
        bg.form.submit(document.searchForm);
    });
</script>
