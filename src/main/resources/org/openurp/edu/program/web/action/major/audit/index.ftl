[@b.head/]
[@b.toolbar title="专业培养方案审核"]
  bar.addBack();
[/@]
  <div class="card">
    <div class="card-header">
      <nav class="navbar navbar-expand-lg navbar-light bg-white" style="padding:0rem 0.5rem;">
        <a class="navbar-brand" style="font-size: 1rem;">专业培养方案审核</a>
        <ul class="navbar-nav mr-auto">
          <li class="nav-item dropdown">
            <a class="nav-link dropdown-toggle" href="#" role="button" data-toggle="dropdown" aria-expanded="false">
              ${depart.name}
            </a>
            <div class="dropdown-menu">
              [#list departs as d]
              [@b.a class="dropdown-item" href="!index?department.id="+d.id+"&grade.id="+grade.id]${d.name}[/@]
              [/#list]
            </div>
          </li>
          <li class="nav-item dropdown">
            <a class="nav-link dropdown-toggle" href="#" role="button" data-toggle="dropdown" aria-expanded="false">
              ${grade.name}
            </a>
            <div class="dropdown-menu">
              [#list grades as g]
              [@b.a class="dropdown-item" href="!index?department.id="+depart.id+"&grade.id="+g.id]${g.name}[/@]
              [/#list]
            </div>
          </li>
        </ul>

        <ul class="navbar-nav ml-auto">
          <li class="nav-item">
            [@b.a href="!diffIndex?right.grade.id=${grade.id}" class="nav-link"]<i class="fa-solid fa-arrow-right-arrow-left"></i>计划对比[/@]
          </li>
          <li class="nav-item">
            <a href="/edu/course/admin/journal?grade.id=${grade.id}&journal.department.id=${depart.id}&planIncluded=1" class="nav-link" title="修改标签、课时、考核方式" onclick="return bg.Go(this,null)"><i class="fas fa-flag"></i>课程信息</a>
          </li>
        </ul>
      </nav>
    </div>

    <div class="card-body" style="padding-top: 0px;">
     <table class="table table-hover table-sm">
       <thead>
         <tr>
           <th>序号</th>
           <th>培养层次</th>
           <th>专业代码</th>
           <th>专业和方向</th>
           <th>学制</th>
           <th>学位类型</th>
           <th>要求学分</th>
           <th>操作</th>
           <th>查看/预览</th>
           <th>状态</th>
           <th>修订时间</th>
         </tr>
       </thead>
       <tbody>
         [#list programs as program]
       <tr>
         <td>${program_index+1}</td>
         <td>${program.level.name}</td>
         <td>${program.disciplineCode!}</td>
         <td>${program.major.name} ${(program.direction.name)!}</td>
         <td>${program.duration}年</td>
         <td>${(program.degree.name)!'--'}</td>
         <td>${program.credits}</td>
         <td>
            [#if reviseOpening && auditables?seq_contains(program.status)]
             [@b.a href="!auditSetting?program.id=${program.id}" target="_blank"]审核[/@]
            [/#if]
         </td>
         <td>
           [@b.a href="!report?program.id=${program.id}" target="_blank"]预览[/@]
           [@b.a href="!diffIndex?right.grade.id=${grade.id}&right.id=${program.id}&left.id=last" target="_blank"]对比[/@]
         </td>
         <td><span data-toggle="tooltip" title="${program.opinions!}">${program.status}</span></td>
         <td><span class="text-muted">${program.updatedAt?string('MM-dd HH:mm')}</span></td>
       </tr>
       [#if auditMessages.get(program)?size>0]
       <tr>
         <td colspan="11" class="alert alert-warning"><ol style="margin-bottom:0px;">[#list auditMessages.get(program) as msg]<li>${msg}</li>[/#list]</ol></td>
       </tr>
       [/#if]
         [/#list]
       </tbody>
      </table>
    </div>
  </div>
  <script>
    $(function () {
      $('[data-toggle="tooltip"]').tooltip()
    })
  </script>
[@b.foot/]
