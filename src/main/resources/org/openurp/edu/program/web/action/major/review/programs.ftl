<div class="card card-info card-outline">
  <div class="card-header">
    <h2 class="card-title">${depart.name} 培养方案</h2>
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
          <th>查看</th>
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
           [@b.a href="!report?program.id=${program.id}" target="_blank"]查看[/@]
          </td>
          <td>${program.status}</td>
          <td><span class="text-muted">${program.updatedAt?string('MM-dd HH:mm')}</span></td>
       </tr>
       [/#list]
      </tbody>
    </table>
  </div>
</div>

[@b.div href="!courses?department.id="+depart.id+"&grade.id="+grade.id/]
