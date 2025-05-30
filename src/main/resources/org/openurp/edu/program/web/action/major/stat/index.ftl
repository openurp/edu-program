[@b.head/]
[@b.toolbar title="计划课程学分学时统计"]
  bar.addBack();
[/@]
[@b.messages slash="3"/]
  <div class="card">
    <div class="card-header">
      <nav class="navbar navbar-expand-lg navbar-light bg-white" style="padding:0rem 0.5rem;">
        <a class="navbar-brand" style="font-size: 1rem;">专业培养计划学分学时统计</a>
        <ul class="navbar-nav mr-auto">
          <li class="nav-item dropdown">
            <a class="nav-link dropdown-toggle" href="#" role="button" data-toggle="dropdown" aria-expanded="false">
              ${grade.name}
            </a>
            <div class="dropdown-menu">
              [#list grades as g]
              [@b.a class="dropdown-item" href="!index?grade.id="+g.id+"&level.id="+level.id]${g.name}[/@]
              [/#list]
            </div>
          </li>
          <li class="nav-item dropdown">
            <a class="nav-link dropdown-toggle" href="#" role="button" data-toggle="dropdown" aria-expanded="false">
              ${level.name}
            </a>
            <div class="dropdown-menu">
              [#list levels as l]
              [@b.a class="dropdown-item" href="!index?grade.id="+grade.id+"&level.id="+l.id]${l.name}[/@]
              [/#list]
            </div>
          </li>
        </ul>
      </nav>
    </div>

    <div class="card-body" style="padding-top: 0px;">
     [@b.tabs]
       [@b.tab href="!modules?grade.id=${grade.id}&level.id=${level.id}" label="课程模块"/]
       [@b.tab href="!natures?grade.id=${grade.id}&level.id=${level.id}" label="理论/实践"/]
       [@b.tab href="!ranks?grade.id=${grade.id}&level.id=${level.id}" label="必修/选修"/]
       [@b.tab href="!tasks?grade.id=${grade.id}&level.id=${level.id}" label="交叉开课"/]
     [/@]
    </div>
  </div>

  <script>
    function exportCourses(){
      bg.form.submit(document.exportCourseForm);
      return false;
    }
  </script>
[@b.foot/]
