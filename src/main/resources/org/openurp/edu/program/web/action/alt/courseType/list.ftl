[#ftl/]
[@b.grid sortable="true" items=applies var="apply"]
    [@b.gridbar]
      bar.addItem("审核通过",action.multi("audit","确定通过?","approved=1"));
      bar.addItem("审核不通过",disapprove());
      function disapprove(){
        return {
          methodName:"audit",func:function(){
            var form = action.getForm();
            var reply = prompt("填写驳回原因:")
            if(reply) {
              bg.form.addInput(form, "reply",reply);
              bg.form.addInput(form, "approved","0");
              action.submitIdAction("audit", true, "确定驳回吗?",true);
            }
          },objectCount:'ge1'
          }
      }
    [/@]
    [@b.row]
        [@b.boxcol/]
        [@b.col width='10%' title="学号"]
          ${apply.std.code}
        [/@]
        [@b.col width='8%' title="姓名"]
          <span title="${apply.remark!}">${apply.std.name}</span>
        [/@]
        [@b.col title="课程代码、名称"]
           ${apply.course.code} ${apply.course.name}
        [/@]
        [@b.col width='33%' title="原类别=>新类别"]
           ${apply.oldType.name} => ${apply.newType.name}
        [/@]
        [@b.col width="13%" title="理由" property="remark"]
          <div data-toggle="tooltip" data-placement="top" class="text-ellipsis" title="${apply.remark?js_string}">${apply.remark!}</div>
        [/@]
        [@b.col width='8%' title="更新日期" property="updatedAt"]
           ${(apply.updatedAt?string('yy-MM-dd'))!}
        [/@]
        [@b.col width='5%' title="状态" property="approved"]
          [#if apply.approved??]
            <span title="${apply.reply!}">${apply.approved?string('通过','不通过')}</span>
          [#else]未审核[/#if]
        [/@]
    [/@]
[/@]
<script>
  jQuery(function() {
    $('#applyFrame [data-toggle="tooltip"]').tooltip();
  });
</script>
