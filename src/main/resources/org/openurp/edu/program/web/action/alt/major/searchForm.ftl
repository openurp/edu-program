[#ftl]
[@b.form name="searchForm" action="!search" title="ui.searchForm" target="planListFrame" theme="search"]
    [@b.textfield name="alt.fromGrade.code" label="年级" maxlength="7"/]
    [@b.textfield name="oldCode" label="原课代码" maxlength="30"/]
    [@b.textfield name="oldName" label="原课名称" maxlength="30"/]
    [@b.textfield name="newCode" label="新课代码" maxlength="30"/]
    [@b.textfield name="newName" label="新课名称" maxlength="30"/]
    [@b.select name='alt.department.id' label="院系" items=departs /]
    [@base.code type='std-types' name='alt.stdType.id'  label="学生类别" /]
    [@b.select name='alt.major.id' label="专业" items=majors  /]
    [@b.select name='alt.direction.id' label='方向' items=directions /]
    <input type="hidden" name="alt.project.id" value="${project.id}"/>
    <input type="hidden" name="orderBy" value="alt.fromGrade.id desc"/>
[/@]
