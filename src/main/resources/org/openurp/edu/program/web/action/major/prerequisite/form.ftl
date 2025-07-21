[@b.head/]
[@b.toolbar title="指定先修课程"]
  bar.addBack();
[/@]
<div class="card card-info card-primary card-outline">
    [@b.card_header]
      <div class="card-title">${program.grade.code}级 ${program.level.name} ${program.major.name} ${(program.direction.name)!} <span class="text-muted">${program.stdTypeNames}</span> 指定课程先修关系</div>
     [/@]
    <div class="card-body">
      [@b.form name="courseListForm" action="!save" theme="list"]
        <table class="table table-sm ">
          <thead>
            <tr>
              <th width="40px">序号</th>
              <th width="10%">课程代码</th>
              <th width="300px">课程名称</th>
              <th width="5%">学分</th>
              <th width="10%">学时</th>
              <th width="70px">课程属性</th>
              <th width="70px">开课学期</th>
              <th>先修课程</th>
            </tr>
          </thead>
          <tbody>
          [#list groupCourses?keys?sort_by("indexno") as g]
            <tr style="background-color: #e9ecef;font-weight:bold;">
              <td colspan="8">${g.indexno} ${g.name}</td>
            </tr>
            [#list groupCourses.get(g)?sort as planCourse]
            [#if planCourse.terms.first>1]
            <tr>
              <td><input name="course.id" type="hidden" value="${planCourse.course.id}">${planCourse_index+1}</td>
              <td>${planCourse.course.code}</td>
              <td>${planCourse.course.name}</td>
              <td>${planCourse.course.defaultCredits}</td>
              <td>${planCourse.journal.creditHours}</td>
              <td>${(g.rank.name)!}</td>
              <td>${planCourse.terms}</td>
              <td>
                [#if g.stage?? && g.stage.name?contains("短")]
                [@b.select name="course${planCourse.course.id}_pres" values=(prerequisites.get(planCourse.course)![]) multiple="true" items=stageCourses[planCourse.terms.first-1] style="width:400px"  label="" theme="html"/]
                [#else]
                [@b.select name="course${planCourse.course.id}_pres" values=(prerequisites.get(planCourse.course)![]) multiple="true" items=termsCourses[planCourse.terms.first-1] style="width:400px"  label="" theme="html"/]
                [/#if]
              </td>
            </tr>
            [/#if]
            [/#list]
          [/#list]
          </tbody>
        </table>
        <input type="hidden" value="${program.id}"  name="program.id"/>
        [@b.submit value="保存先修关系"/]
      [/@]
</div>
[@b.foot/]
