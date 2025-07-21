[@b.head/]
<div class="card card-info card-primary card-outline">
    [@b.card_header]
      <div class="card-title">${program.grade.code}级 ${program.level.name} ${program.major.name} ${(program.direction.name)!} <span class="text-muted">（${program.stdTypeNames}）</span>先修课程</div>

        <ul class="navbar-nav" style="width:300px;display:inline-block;">
          <li class="nav-item dropdown">
            <a class="nav-link dropdown-toggle" href="#" role="button" data-toggle="dropdown" aria-expanded="false">
              其他方案
            </a>
            <div class="dropdown-menu">
              [#list others as d]
              [@b.a class="dropdown-item" href="!info?program.id="+d.id]${d.grade.name} ${d.level.name} ${d.major.name} ${(d.direction.name)!} <span class="text-muted">${d.stdTypeNames}</span>[/@]
              [/#list]
            </div>
          </li>
        </ul>

      [@b.card_tools]
       <div class="btn-group">
       [@b.a href="!courses?program.id=${program.id}" class="btn btn-sm btn-outline-info"]<i class="fa fa-edit"></i>修改[/@]
       [@b.a href="!graph?program.id=${program.id}" class="btn btn-sm btn-outline-info" target="graph"]<i class="fa fa-edit"></i>调整布局[/@]
       [@b.a href="!uploadImg?program.id=${program.id}" class="btn btn-sm btn-outline-info" target="_blank" target="graph"]<i class="fa-regular fa-image"></i>手绘上传[/@]
       </div>

       <div class="btn-group">
       [@b.a href="!dependency?program.id=${program.id}" class="btn btn-sm btn-outline-info" target="_blank"]<i class="fa-solid fa-route"></i>全部关系图[/@]
       [@b.a href="revise!index?department.id=${program.department.id}&grade.id=${program.grade.id}" class="btn btn-sm btn-outline-info"]<i class="fa-solid fa-list"></i>计划列表[/@]
       </div>
      [/@]
    [/@]
    <div class="card-body">
      [#if groupCourses?size>0]
        <div style="margin:auto;text-align:center;">
          <iframe HEIGHT="450px" WIDTH="100%" SCROLLING="auto"
             FRAMEBORDER="0" src="${b.url('!image?autoCreate=1&program.id='+program.id+"&t="+b.now?string("yyyyMMddHHmmss"))}" name="graph" id="graph">
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
        [#list groupCourses?keys?sort_by("indexno") as g]
          <tr style="background-color: #e9ecef;font-weight:bold;">
            <td colspan="8">${g.indexno} ${g.name}</td>
          </tr>
          [#list groupCourses.get(g)?sort as planCourse]
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
