[#ftl]
[@b.form name="searchForm" action="!search" title="ui.searchForm" target="stdAlternativeCourseFrame" theme="search"]

    [@b.textfield name="stdAlternativeCourse.std.user.code" label="学号" maxlength="15"/]
    [@b.textfield name="stdAlternativeCourse.std.user.name" label="姓名" maxlength="10"/]
    [@b.textfield name="stdAlternativeCourse.std.state.grade" label="年级" maxlength="10"/]
    [@b.textfield name="originCourse" label="原课程" maxlength="30" placeholder="代码或名称"/]
    [@b.textfield name="substituteCourse" label="新课程" maxlength="30" placeholder="代码或名称"/]
    [#--[#include "/template/major3Select.ftl"/]--]
    <input type="hidden" name="orderBy" value="stdAlternativeCourse.id desc"/>
    [#--[@majorSelect id="s1" projectId="" levelId="stdAlternativeCourse.std.level.id" departId="stdAlternativeCourse.std.state.department.id" majorId="stdAlternativeCourse.std.state.major.id" directionId="stdAlternativeCourse.std.state.direction.id" stdTypeId="stdAlternativeCourse.std.stdType.id"/]--]
[/@]
