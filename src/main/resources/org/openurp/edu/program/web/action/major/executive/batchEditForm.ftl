[@b.form name="batchEditForm" title="批量修改课程" action="!batchEditCourses" onsubmit="validateBatchEditCourses"]
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
  [@b.grid sortable="false" items=planCourses var="planCourse" style='width:100%;border:0.5px']
    [@b.row]
      [@b.boxcol checked=true/]
      [@b.col width="13%" property="course.code" title="课程代码"/]
      [@b.col property="course.name" title="课程名称"/]
      [@b.col width="10%" title="开课学期" property="_batch.fake.terms"]
        <input type="text" id="terms${planCourse.id}" name="planCourse.${planCourse.id}.terms" title="开课学期" style='width:80%;' maxlength="20"/>
      [/@]
      [@b.col width="8%" property="defaultCredits" title="学分"]${planCourse.credits}[/@]
      [@b.col width="8%" property="creditHours" title="学时"]${planCourse.course.creditHours}[/@]
    [/@]
  [/@]

[/@]
<script type="text/javascript">
  jQuery(function() {
    jQuery('#batchEditForm th.grid-select-top>input').remove();
    jQuery('#batchEditForm input[name=_batch\\.fake\\.terms]').keyup(function() {
      var terms = jQuery(this).val();
      if(terms) {
        jQuery("input[name$='.terms'][name^='planCourse.']").each(function(){
          jQuery(this).val(terms);
        });
      }
    });
    function batchEditSubmit(){
      bg.form.submit(document.batchEditForm);
    }
    setupPlanDialog("批量修改课程(${courseGroup.name})",batchEditSubmit,"修改");
  });
</script>
