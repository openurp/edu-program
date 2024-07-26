<table class="table table-sm mb-0 plan_table">
  <thead>
    <tr>
      <th width="40px">序号</th>
      <th width="10%">培养层次</th>
      <th >专业/方向</th>
      <th width="200px">课程类别</th>
      <th width="70px">课程属性</th>
      <th width="70px">开课学期</th>
      <th width="120px">备注</th>
    </tr>
  </thead>
  <tbody>
    [#list planCourses as pc]
    <tr>
      <td>${pc_index+1}</td>
      <td>${pc.group.plan.program.level.name}</td>
      <td>${pc.group.plan.program.major.name} ${(pc.group.plan.program.direction.name)!}</td>
      <td>${pc.group.courseType.name}</td>
      <td>[#if pc.compulsory]必修[#else]${(pc.group.rank.name)!}[/#if]</td>
      <td>${termHelper.getTermText(pc)}<div style="display:none">${pc.terms!}</div></td>
      <td><span class="text-muted" style="font-size:0.8rem">${pc.remark!}</span></td>
    </tr>
    [/#list]
  </tbody>
</table>
<script>
  jQuery("#course_detail_title").html("开课情况——${course.code} ${course.name?js_string} ${course.defaultCredits}学分 ${course.creditHours}学时");
</script>
