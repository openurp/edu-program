[@b.head/]
[@b.toolbar title="方案修订"]
  bar.addBack();
[/@]
[@b.messages slash="3"/]
  <div class="card">
    <div class="card-header">
      <nav class="navbar navbar-expand-lg navbar-light bg-white" style="padding:0rem 0.5rem;">
        <a class="navbar-brand" style="font-size: 1rem;">专业培养方案修订</a>
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
            [@b.a href="!plans?grade.id=${grade.id}&department.id=${depart.id}" target="_blank" class="nav-link"]<i class="fa-solid fa-file-excel" ></i>下载教学计划[/@]
          </li>
          <li class="nav-item">
            [@b.a href="plan!spellCheck?grade.id=${grade.id}&department.id=${depart.id}" class="nav-link" ]<i class="fa-solid fa-spell-check"></i>英文检查[/@]
          </li>
          <li class="nav-item">
            [@b.a href="plan!diffIndex?right.grade.id=${grade.id}" class="nav-link"]<i class="fa-solid fa-arrow-right-arrow-left"></i> 计划对比[/@]
          </li>
          <li class="nav-item">
            <a href="/edu/course/admin/new-course-apply" class="nav-link" onclick="return bg.Go(this,null)"><i class="fas fa-plus"></i>新课申请</a>
          </li>
          <li class="nav-item">
            <a href="#" class="nav-link" onclick="return displayCourses()"><i class="fas fa-list"></i>开课列表</a>
          </li>
          <li class="nav-item">
            <a href="/edu/course/admin/journal" class="nav-link" title="修改标签、课时、考核方式" onclick="return bg.Go(this,null)"><i class="fas fa-flag"></i>课程信息</a>
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
           <th width="300px">修订操作</th>
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
            [#if reviseOpening && editables?seq_contains(program.status)]
             [@b.a href="doc!edit?program.id=${program.id}" target="_blank"]方案文本[/@]
             [@b.a href="plan!edit?program.id=${program.id}" target="_blank"]教学计划[/@]
             [@b.a href="prerequisite!info?program.id=${program.id}"]先修课程[/@]
            [/#if]
            [#if program.status.id!=100 && program.status.id!=50 && program.status.id!=1]
            [@b.a href="!submit?program.id="+program.id title="${(program.opinions!)}" onclick="if(confirm('确定提交整个培养方案？')){ return bg.Go(this)} else return false;"]提交[/@]
            [/#if]
            [#if program.status.id==1]
            [@b.a href="!revoke?program.id="+program.id title="${(program.opinions!)}" onclick="if(confirm('确定撤回？')){ return bg.Go(this)} else return false;"]撤回[/@]
            [/#if]
         </td>
         <td>
           [@b.a href="!info?id=${program.id}" target="_blank"]查看[/@]
           [@b.a href="!report?id=${program.id}" target="_blank"]预览[/@]
           [@b.a href="!pdf?id=${program.id}" target="_blank"]PDF[/@]
           [@b.a href="plan!diffIndex?right.grade.id=${grade.id}&right.id=${program.id}&left.id=last" target="_blank"]对比[/@]
         </td>
         <td><span data-toggle="tooltip" title="${program.opinions!}">${program.status}</span></td>
         <td><span class="text-muted">${program.updatedAt?string('MM-dd HH:mm')}</span></td>
       </tr>
         [/#list]
       </tbody>
      </table>
    </div>
  </div>

  <div class="modal fade" id="courseListDialog" tabindex="-1" role="dialog" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered" role="document">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title">${grade.name} ${depart.name} 开课课程信息</h5>
          <button class="btn btn-sm btn-outline-primary" onclick="return exportCourses();">导出</button>
          <button type="button" class="close" data-dismiss="modal" aria-label="Close">
            <span aria-hidden="true">&times;</span>
          </button>
        </div>
        <div class="modal-body" style="padding-top:0px;">
          <div id='courseListDiv' style="width:100%"></div>
          [@b.form name="exportCourseForm" action="!exportCourses" target="_blank"]
            <input type="hidden" name="grade.id" value="${grade.id}"/>
            <input type="hidden" name="department.id" value="${depart.id}"/>
            <input type="hidden" name="titles"
              value="course.code:课程代码,journal.name:课程名称,course.defaultCredits:学分,journal.creditHours:学时,[#list teachingNatures as n]journal.hours.${n.id}:${n.name},[/#list],journal.weeks:周数,journal.examMode.name:考核方式,terms:开课学期"/>
          [/@]
        </div>
      </div>
    </div>
  </div>

  <script>
    beangle.load(["jquery-colorbox"]);
    $(function () {
      $('[data-toggle="tooltip"]').tooltip()
    })
    function displayCourses(){
      bg.Go('${b.url('!courses?grade.id=${grade.id}&department.id=${depart.id}')}',"courseListDiv")
      jQuery("#courseListDialog").modal('show');
      return false;
    }
    function exportCourses(){
      bg.form.submit(document.exportCourseForm);
      return false;
    }
  </script>
[@b.foot/]
