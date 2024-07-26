[#ftl]
[@b.head /]
[@b.grid sortable="true" items=exempts var="exempt"]
    [@b.gridbar]
      bar.addItem("${b.text("action.add")}",action.add());
      bar.addItem("${b.text("action.modify")}",action.edit());
      bar.addItem("${b.text("action.delete")}",action.remove());
    [/@]
    [@b.row]
      [@b.boxcol/]
      [@b.col width='10%' property="fromGrade" title="年级"]
        [#if exempt.toGrade?? && exempt.fromGrade = exempt.toGrade]${exempt.fromGrade.code}
        [#else]${exempt.fromGrade.code}~${(exempt.toGrade.code)!}
        [/#if]
      [/@]
      [@b.col property="level.name" title="培养层次" width="10%"/]
      [@b.col property="courseType" title="课程类别"]${(exempt.courseType.name)!}[/@]
      [@b.col property="course.code" title="课程代码" width="10%"/]
      [@b.col property="course.name" title="课程名称"]${(exempt.course.name)!}[/@]
      [@b.col property="major" title="学生类别" width="15%"]
        <div class="text-ellipsis">[#list exempt.stdTypes as ty]${ty.name}[#sep],[/#list]</div>
      [/@]
    [/@]
[/@]
[@b.foot /]
