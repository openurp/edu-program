[@b.head /]
[@b.toolbar title="培养方案课程英文名检查结果"]
  bar.addBack();
[/@]
<div class="card card-info card-outline">
  <div class="card-header">
    <h2 class="card-title">${depart.name} ${grade.name}级培养计划中的英文名检查结果</h2>
  </div>
  <div class="card-body" style="padding-top: 0px;">
    <table class="table table-hover table-sm">
      <thead>
        <tr>
          <th width="50px">序号</th>
          <th width="100px">课程代码</th>
          <th width="200px">课程名称</th>
          <th width="50px">学分</th>
          <th width="50px">学时</th>
          <th width="80px">开课单位</th>
          <th width="300px">课程英文名</th>
          <th>拼写检查</th>
        </tr>
      </thead>
      <tbody>
        [#list journals?sort_by(["course","code"]) as journal]
        <tr>
          <td>${journal_index+1}</td>
          <td>${journal.course.code}</td>
          <td>${journal.course.name}</td>
          <td>${journal.course.defaultCredits}</td>
          <td>${journal.creditHours}</td>
          <td>${(journal.department.shortName!journal.department.name)!}</td>
          <td>${journal.enName!}</td>
          <td>${results.get(journal)!}</td>
       </tr>
       [/#list]
      </tbody>
    </table>
  </div>
</div>
[@b.foot /]
