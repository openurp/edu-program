[@b.head/]
[@b.toolbar title="选择课程"]
  bar.addBack();
[/@]
<div class="card card-info card-primary card-outline">
    [@b.card_header]
      <div class="card-title">${program.grade.code}级 ${program.major.name} ${(program.direction.name)!} 选择课程
      </div>
     [/@]
    <div class="card-body" style="padding-top: 0px;">
      [@b.form name="courseListForm" action="!edit" theme="list"]
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
          [#list candidates as g]
            <tr style="background-color: #e9ecef;font-weight:bold;">
              <td colspan="8">${g.indexno} ${g.name}</td>
            </tr>
            [#list g.orderedPlanCourses as pc]
            <tr>
              <td>
                <input name="planCourse.id" type="checkbox" value="${pc.id}"
                  [#if allCourses?seq_contains(pc.course) || g.courseType.name="长学段-专业必修课"]checked="checked"[/#if]>
              </td>
              <td>${pc.course.code}</td>
              <td>${pc.course.name}</td>
              <td>${pc.course.defaultCredits}</td>
              <td>${pc.course.creditHours}</td>
              <td>${(g.rank.name)!}</td>
              <td>${pc.terms}</td>
              <td>
               [#if exists.get(pc.course)??]
                 [#list exists.get(pc.course) as c]${c.name}[#sep]&nbsp;[/#list]
               [/#if]
              </td>
            </tr>
            [/#list]
          [/#list]
          </tbody>
        </table>
        <input type="hidden" value="${program.id}"  name="program.id"/>
        [@b.submit value="下一步，指定先修课程"/]
      [/@]
</div>
[@b.foot/]
