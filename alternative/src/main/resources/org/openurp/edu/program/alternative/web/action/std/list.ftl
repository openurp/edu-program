[#ftl]
[@b.head /]
[@b.grid sortable="true" items=stdAlternativeCourses var="stdAlternativeCourse"]
    [@b.gridbar]
        bar.addItem("${b.text('action.add')}",action.add());
        bar.addItem("${b.text('action.modify')}",action.edit());
        bar.addItem("${b.text('action.delete')}",action.remove());
        bar.addItem("交换",action.multi('exchange',"确定选择选中记录的原课程和替代课程？"));
        bar.addItem("导入",action.method('importForm',null,null,"_blank"));
    [/@]
    [@b.row]
        [@b.boxcol/]
        [@b.col width='10%' property="std.user.code" title="学号"]
            ${(stdAlternativeCourse.std.user.code)!}
        [/@]
        [@b.col width='8%' property="std.user.name" title="姓名"]
            ${(stdAlternativeCourse.std.user.name)!}
        [/@]
        [@b.col width='6%' property="std.state.grade" title="年级"]
            ${(stdAlternativeCourse.std.state.grade)!}
        [/@]
        [@b.col width='14%' property="std.state.major.id" title="专业"]
            ${(stdAlternativeCourse.std.state.major.name)!}
        [/@]
        [@b.col width='25%' title="原课代码、名称、学分"]
          <span style="font-size:0.8em">
            [#list stdAlternativeCourse.olds as course]
                ${course.code} ${course.name} (${course.credits})
                [#if course_has_next]<br>[/#if]
            [/#list]
          </span>
        [/@]
        [@b.col width='25%' title="新课代码、名称、学分"]
          <span style="font-size:0.8em">
            [#list stdAlternativeCourse.news as course]
                ${course.code} ${course.name} (${course.credits})
                [#if course_has_next]<br>[/#if]
            [/#list]
           </span>
        [/@]
        [@b.col width='7%' title="更新日期" property="updatedAt"]
           <span style="font-size:0.9em">${(stdAlternativeCourse.updatedAt?string('yy-MM-dd'))!}</span>
        [/@]
    [/@]
[/@]
[@b.foot /]
