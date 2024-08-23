[#if courses??]
[@b.form name="batchAddForm" title="批量添加课程" action="!batchAddCourses" onsubmit="validateBatchAddCourses"]
  <input type="hidden" name="courseGroup.id" value="${courseGroup.id}"/>
  <table  class="grid-table" style="width:100%;border:0.5px">
    <thead class="grid-head">
    <tr>
      <th style="width:32px">&nbsp;</th>
      <th style="padding-left:3px" width="13%"></th>
      <th style="padding-left:3px"></th>
      <th style="padding-left:3px" width="10%">
        <input maxLength="20" style="width:80%;" title="开课学期" name="_batch.fake.terms" type="text">
      </th>
      <th style="padding-left:3px" width="8%"></th>
      <th style="padding-left:3px" width="8%"></th>
    </tr>
    </thead>
  </table>
  [@b.grid sortable="false" items=courses var="course" style='width:100%;border:0.5px']
    [@b.row]
      [@b.boxcol checked=true/]
      [@b.col width="13%" property="code" title="课程代码"/]
      [@b.col property="name" title="课程名称"/]
      [@b.col width="10%" title="开课学期" property="_batch.fake.terms"]
        <input type="text" id="terms${course.id}" name="course.${course.id}.terms" title="开课学期" style='width:80%;' maxlength="20"/>
      [/@]
      [@b.col width="8%" property="defaultCredits" title="学分"]${course.getCredits(plan.program.level)}[/@]
      [@b.col width="8%" property="creditHours" title="学时"]${course.creditHours}[/@]
    [/@]
  [/@]

[/@]
<script type="text/javascript">
  jQuery(function() {
    jQuery('#batchAddForm th.grid-select-top>input').remove();
    jQuery('#batchAddForm input[name=_batch\\.fake\\.terms]').keyup(function() {
      var terms = jQuery(this).val();
      if(terms) {
        jQuery("input[name$='.terms'][name^='course.']").each(function(){
          jQuery(this).val(terms);
        });
      }
    });
    function batchAddSubmit(){
      bg.form.submit(document.batchAddForm);
    }
    setupPlanDialog("批量添加课程(${courseGroup.name})",batchAddSubmit,"添加");
  });
</script>
[#else]
[@b.form name="batchAddForm" title="批量添加课程" target="planDialogBody" action="!batchAddForm" theme='list']
    [@b.textarea label="" name="courseCodes" cols="40" rows="5" required="true" title="课程代码"
           comment="多个代码可用空格、逗号、分号、回车分割" /]
    [@b.formfoot]
      <input type="hidden" name="courseGroup.id" value="${courseGroup.id}"/>
      [@b.submit value="下一步"/]
    [/@]
[/@]
[/#if]
