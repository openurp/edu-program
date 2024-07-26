[@b.head/]
<div class="card card-info card-primary card-outline">
    [@b.card_header]
      <div class="card-title">${program.grade.code}级 ${program.major.name} ${(program.direction.name)!} 先修课程
      </div>
      [@b.card_tools]
       <div class="btn-group">
       [@b.a href="!courses?program.id=${program.id}" class="btn btn-sm btn-outline-info"]<i class="fa fa-edit"></i>修改[/@]
       [@b.a href="!dependencyGraph?program.id=${program.id}" class="btn btn-sm btn-outline-info" target="_blank"]<i class="fa fa-edit"></i>查看课程关系图[/@]
       </div>
      [/@]
     [/@]
    <div class="card-body">
      [#if planCourses?size>0]
        <div style="margin:auto;text-align:center;">
          <iframe HEIGHT="400px" WIDTH="100%" SCROLLING="auto"
             FRAMEBORDER="0" src="${b.url('!dependencyGraph?program.id='+program.id)}" name="graph" id="graph">
            </iframe>
        </div>
      [/#if]
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
        [#list planCourses?keys?sort_by("indexno") as g]
          <tr style="background-color: #e9ecef;font-weight:bold;">
            <td colspan="8">${g.indexno} ${g.name}</td>
          </tr>
          [#list planCourses.get(g)?sort as planCourse]
          <tr>
            <td>${planCourse_index+1}</td>
            <td>${planCourse.course.code}</td>
            <td>${planCourse.course.name}</td>
            <td>${planCourse.course.defaultCredits}</td>
            <td>${planCourse.journal.creditHours}</td>
            <td>${(g.rank.name)!}</td>
            <td>${planCourse.terms}</td>
            <td>
               [#list prerequisites.get(planCourse.course) as p]${p.name}[#sep]&nbsp;[/#list]
            </td>
          </tr>
        [/#list]
        [/#list]
        </tbody>
      </table>
    </div>
</div>
[@b.foot/]
