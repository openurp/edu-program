[@b.form name="searchForm" action="!search" title="ui.searchForm" target="programListFrame" theme="search"]
    [@b.textfield name="program.grade.code" label="年级" maxlength="7"/]
    [@b.select name="program.level.id" items=levels empty="..." label="培养层次"/]
    [#if educationTypes?size>1]
    [@b.select name="program.eduType.id" items=educationTypes empty="..." label="培养类型"/]
    [/#if]
    [@b.select name="fake.program.stdType.id" items=stdTypes empty="..." label="学生类别"/]
    [@b.select name="program.department.id" items=departments empty="..." label="院系"/]
    [@b.select name="program.major.id" items=majors empty="..." label="专业"/]
    [@b.textfield name="program.direction.name" label="方向"/]
    [@b.select name="program.status" items={}  label="审核状态"]
        <option value="">...</option>
        [#list statuses as state]
        <option value="${state.id}">${state.name}</option>
        [/#list]
    [/@]
    [@b.radios label="是否有效" name="fake.valid" value='1' items={'1':'是', '0':'否'}/]
    <input type="hidden" name="orderBy" value="program.beginOn desc,program.department.code,program.name"/>
[/@]

<script>
    jQuery(function(){
        bg.form.submit(document.searchForm);
    });
</script>
