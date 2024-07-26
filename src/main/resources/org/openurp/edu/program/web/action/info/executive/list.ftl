[#ftl]
[@b.head /]
[@b.grid items=plans! var="plan"]
  [@b.row]
    [@b.boxcol/]
    [@b.col width="8%" property="program.grade.code" title="年级"/]
    [@b.col width="8%" property="program.level.name" title="培养层次"/]
    [@b.col width="20%" property="program.department.name" title="院系"/]
    [@b.col property="program.major.name" title="专业/方向"]
      [@b.a href="!info?id=" + plan.id title="点击查看详情" target="_blank"]${(plan.program.name)}[/@]
    [/@]
    [@b.col width="15%" title="学生类别"]
      <div class="text-ellipsis">[#list plan.program.stdTypes as ty]${ty.name}[#sep],[/#list]</div>
    [/@]
    [@b.col width="8%" property="program.duration" title="学制"/]
    [@b.col width="5%" property="credits" title="总学分"/]
    [@b.col width="5%" title="操作"]
       [@b.a href="!diff?planId=${plan.id}" title="点击查看详情" target="_blank"]对比[/@]
    [/@]
  [/@]
[/@]
[@b.foot /]
