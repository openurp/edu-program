[#ftl]
[@b.head /]
[@b.grid sortable="true" items=exempts var="exempt"]
    [@b.gridbar]
      //bar.addItem("${b.text("action.add")}",action.add());
      //bar.addItem("${b.text("action.modify")}",action.edit());
      bar.addItem("${b.text("action.delete")}",action.remove());
      bar.addItem("批量添加",action.method('batchAdd'));
    [/@]
    [@b.row]
        [@b.boxcol/]
        [@b.col width='10%' property="std.code" title="学号"]
            ${(exempt.std.code)!}
        [/@]
        [@b.col width='18%' property="std.name" title="姓名"]
            ${(exempt.std.name)!}
        [/@]
        [@b.col width='6%' property="std.state.grade" title="年级"]
            ${(exempt.std.state.grade)!}
        [/@]
        [@b.col width='15%' property="std.state.major.id" title="专业"]
            ${(exempt.std.state.major.name)!}
        [/@]
        [@b.col property="course.code" title="课程代码、名称"]
            ${exempt.course.code} ${exempt.course.name}
        [/@]
        [@b.col property="remark" title="备注" width="20%"]
            ${exempt.remark!}
        [/@]
        [@b.col width='7%' title="更新日期" property="updatedAt"]
           <span style="font-size:0.9em">${(exempt.updatedAt?string('yy-MM-dd'))!}</span>
        [/@]
    [/@]
[/@]

[@b.foot /]
