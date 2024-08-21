[#ftl/]
[@b.grid sortable="true" items=applies var="apply"]
    [@b.gridbar]
      bar.addItem("审核通过",action.multi("audit","确定通过?","approved=1"));
      bar.addItem("审核不通过",disapprove());
      function disapprove(){
        return {
          methodName:"audit",func:function(){
            var form = action.getForm();
            var reply = prompt("填写驳回原因(80个字以内):")
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
        [@b.col width='12%' title="学号" property="std.code"]
          ${apply.std.code}
        [/@]
        [@b.col width='8%' title="姓名" property="std.name"]
          <a href="${ems_base}/std/graduation/plan/depart/lastest?student.id=${apply.std.id}" target="_blank" title="查看最新计划完成情况">${apply.std.name}</a>
        [/@]
        [@b.col width='24%' title="原课程"]
            [#list apply.olds as course] ${course.code} ${course.name} (${course.defaultCredits})[#if course_has_next]&nbsp;[/#if][/#list]
        [/@]
        [@b.col width='24%' title="替代课程"]
            [#list apply.news as course]${course.code} ${course.name} (${course.defaultCredits})[#if course_has_next]&nbsp;[/#if][/#list]
        [/@]
        [@b.col title="理由" property="remark"]
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
