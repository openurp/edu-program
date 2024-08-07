[#ftl]
[@b.form name="planSearchForm" action="!search" title="ui.searchForm" target="planListFrame" theme="search"]
    [@b.textfield name="plan.program.grade.code" label="年级" maxlength="7"/]
    [@b.select name='plan.program.department.id' label="院系" items=departs /]
    [@b.select name='plan.program.major.id' label="专业" items=majors  /]
    [@b.select name='plan.program.direction.id' label='方向' items=directions /]
    [@base.code type='std-types' name='stdType.id'  label="学生类别" /]
    [@b.radios label="是否有效" name="fake.valid" value='1' items={'1':'是', '0':'否'}/]
    <input type="hidden" name="orderBy" value="plan.program.beginOn desc"/>
[/@]
