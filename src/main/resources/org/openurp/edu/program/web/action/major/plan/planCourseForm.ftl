[#ftl]
<form name="planCourseForm" method="post" action="${b.url('!saveCourse')}">
    <input type="hidden" name="planId" value="${plan.id}"/>
    <input type="hidden" name="planCourse.group.id" value="${courseGroup.id}"/>
    <input type="hidden" name="stage" value="${(courseGroup.stage.name)!}"/>
    <input type="hidden" name="planCourse.id" value=""/>
    <input type="hidden" name="planCourse.course.id" id="planCourse_course_id" value=""/>
    <input type="hidden" name="toGroups" value="1"/>
    <table width="100%" valign="top" class="grid-table">
       <tr>
         <td class="grayStyle" width="25%">&nbsp;课程代码<font color="red">*</font></td>
         <td class="brightStyle" colspan="3">
              <input type="text" name="planCourse.course.code" id="planCourse_course_code" value="" readonly size="20" maxlength="20"/>
              <input type="button" value="选择课程" onclick="openCourseListDialog();"  class="buttonStyle"/>
         </td>
       </tr>
       <tr>
         <td class="grayStyle" width="25%">&nbsp;课程名称<font color="red">*</font></td>
         <td class="brightStyle" colspan="3">
           <span id='planCourse_course_name'></span>&nbsp;
           <span id='planCourse_course_defaultCredits'></span>学分
           <span id='planCourse_course_creditHours'></span>学时
         </td>
       </tr>
       <tr>
         <td class="grayStyle" width="25%">&nbsp;开课院系</td>
         <td class="brightStyle" colspan="3"><span id='planCourse_department_name'></span></td>
       </tr>
       <tr>
         <td class="grayStyle" width="25%">&nbsp;开课学期<font color="red">*</font></td>
         <td class="brightStyle" colspan="3">
              <input type="text" name="planCourse.terms" id="planCourse_terms" size="10" title="开课学期" maxlength="50" value=""  onchange="generateTermText(this)"/>
              <span style="font-size:0.8rem;color: #999;">格式为:1或者1,2  *表示不限</span>
         </td>
       </tr>
       <tr>
           <td class="grayStyle" width="25%">&nbsp;开课学期说明</td>
           <td class="brightStyle" colspan="3">
               <input name="planCourse.termText" id="planCourse_termText" value=""/>
           </td>
       </tr>
       <tr>
         <td class="grayStyle" width="25%">&nbsp;开课周</td>
         <td class="brightStyle" colspan="3">
              <input type="text" name="planCourse.weekstate" size="10" maxlength="50" value=""/>
              <span style="font-size:0.8rem;color: #999;">格式为:1或者1,2;1-8;1-15单</span>
         </td>
       </tr>
       <tr>
           <td class="grayStyle" width="25%">&nbsp;是否必修</td>
           <td class="brightStyle" colspan="3">
               [@b.radios name="planCourse.compulsory" label='' items={'1':'是', '0':'否'} value=courseGroup.autoAddup?string('1','0') /]
           </td>
       </tr>
       <tr>
         <td class="grayStyle" width="25%">&nbsp;顺序号</td>
         <td class="brightStyle" colspan="3">
              <input type="text" name="planCourse.idx" style="width:40px" maxlength="3" value=""/>
              <span style="font-size:0.8rem;color: #999;">整数1开始，默认为0,按照学期排序+代码排序</span>
         </td>
       </tr>
       <tr>
         <td class="grayStyle">&nbsp;备注</td>
         <td class="brightStyle" colspan="3">
              <textarea name="planCourse.remark" id="planCourse_remark" cols="25" rows="2"></textarea>
         </td>
       </tr>
    </table>
</form>
<script type="text/javascript">
    beangle.load(["jquery-validity"]);
    function clearPlanCourseForm() {
        var planCourseForm = document.planCourseForm;
        planCourseForm["planCourse.course.id"].value = '';
        planCourseForm["planCourse.course.code"].value = '';
        planCourseForm["planCourse.terms"].value = '';
        planCourseForm["planCourse.termText"].value = '';
        planCourseForm["planCourse.weekstate"].value = '';
        planCourseForm["planCourse.idx"].value = '';
        jQuery('#planCourse_course_defaultCredits').html('');
        jQuery('#planCourse_course_creditHours').html('');
        jQuery('#planCourse_course_name').html('');
        jQuery(planCourseForm["planCourse.remark"]).html('');
        jQuery(':radio[name=planCourse\\.compulsory]', planCourseForm).prop('checked',false);
        [#if courseGroup.autoAddup]
            jQuery(':radio[name=planCourse\\.compulsory][value=1]', planCourseForm).prop("checked",true);
        [#else]
            jQuery(':radio[name=planCourse\\.compulsory][value=0]', planCourseForm).prop("checked",true);
        [/#if]
    }

    function chooseCourseToPlanCourse() {
        var id = jQuery(':checked[name=course\\.id]', jQuery('#courseListDiv')).val();
        if (id == undefined || id == "") {
            alert('请选择课程');
            return;
        }
        _fillFormCoursePart(courseResults['c'+id]);
        openPlanCourseDialog();
    }

    function _fillFormCoursePart(course) {
        var planCourseForm = document.planCourseForm;
        clearPlanCourseForm();
        planCourseForm["planCourse.course.id"].value = course.id;
        planCourseForm["planCourse.course.code"].value = course.code;
        jQuery('#planCourse_course_defaultCredits').html(course.defaultCredits);
        jQuery('#planCourse_course_name').html(course.name);
        jQuery('#planCourse_department_name').html(course.department.name);
        if(course.creditHours != null) {
          if(course.creditHours != null) {
            jQuery('#planCourse_course_creditHours').html(course.creditHours);
          }
        }
    }

    // 验证培养计划的课程
    function validatePlanCourse() {
        var form = document.planCourseForm;

        var terms = jQuery('input[name=planCourse\\.terms]', jQuery(form)).val();
        jQuery('input[name=planCourse\\.terms]', jQuery(form)).val(terms.replace(/，/g, ','));

        var res = null;
        jQuery.validity.start();
        jQuery('#planCourse_department_id').require();
        jQuery('#planCourse_course_id').require();
        jQuery('#planCourse_terms').assert(
          function(termInput) {
              return checkTerms(termInput, ${plan.program.startTerm},${plan.program.endTerm});
          }
          ,
          '开课学期为数字${plan.program.startTerm}-${plan.program.endTerm}和,组成,不指定学期请输入星号*'
        ).require();
        jQuery('#planCourse_remark').maxLength(500);
        res = jQuery.validity.end().valid;
        if(false == res) {
            return false;
        }
        return true;
    }

     /**
     * 保存培养计划中的课程
     */
    function savePlanCourse() {
        if(validatePlanCourse()) {
            closePlanCourseDialog();
            bg.form.submit(document.planCourseForm, '${b.url('!saveCourse')}');
        }
    }
    function checkTerms(termInput, startTerm,endTerm) {
      if(!termInput)return false;
      var termArr = termInput.value.split(',').sort();
      var termArr_ = new Array();
      var prev = '';
      for(var i = 0; i < termArr.length; i++) {
        if(prev != termArr[i]) {
          termArr_.push(termArr[i]);
          prev = termArr[i];
        }
      }
      termArr = termArr_;
      termInput.value = termArr.join(',');

      for(var i = 0; i < termArr.length; i++) {
        if((!/^[1-9]\d*$/.test(termArr[i]) &&
         jQuery.trim(termArr[i])!='春季' &&
         jQuery.trim(termArr[i])!='秋季' &&
         jQuery.trim(termArr[i])!='春秋季')&&
         !/^\*$/.test(termArr[i])) {
          return false;
        }
        if(new Number(termArr[i]) > endTerm || new Number(termArr[i]) < startTerm) {
          return false;
        }
      }

      termArr.sort(function(a,b) {
        return new Number(a) - new Number(b);
      });
      termInput.value = termArr.join(',');

      return true;
    }
  //根据输入的学期自动生成学期说明
  function generateTermText(termInput){
    var form = termInput.form;
    var stage=form['stage'].value||"";
    if(stage.length>0){
      var sn = stage.substring(0,1);
      var terms = termInput.value;
      terms = terms.replace('-',sn+'-')
      terms = terms.replace(',',sn+'+')
      terms+=sn;
      form['planCourse.termText'].value=terms;
    }
  }
</script>
