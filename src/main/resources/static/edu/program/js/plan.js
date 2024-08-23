  var startTerm=1;
  var endTerm=6;
  function setupPlanDialog(title,submitHandler,submitText) {
    jQuery('#planDialogTitle').html(title);
    if(submitHandler!=null){
      jQuery('#planDialogSubmit').show();
      jQuery('#planDialogSubmit').unbind('click');
      jQuery('#planDialogSubmit').click(submitHandler);
      jQuery('#planDialogSubmit').html(submitText||"确定");
    }else{
      jQuery('#planDialogSubmit').hide();
    }
  }

  function closeDialog(id){
    jQuery("#"+id).modal('hide');
    jQuery("body>div.modal-backdrop").remove();
    return true;
  }
  function findGroup(groupId){
    for(i=0;i<courseGroups.length;i++){
      if(courseGroups[i].id==groupId){
        return courseGroups[i];
      }
    }
    return null;
  }

  function chooseCourseToPlanCourse() {
    var id = jQuery(':checked[name=course\\.id]', jQuery('#planDialogBody')).val();
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
  }

  function editPlanCourse(planCourseId, courseGroupId) {
    var planCourse=planCourses['pc'+planCourseId];
    _fillFormCoursePart(planCourse.course);

    var form = document.planCourseForm;
    form['planCourse.id'].value = planCourse.id;
    var g = findGroup(courseGroupId);
    form['planCourse.group.id'].value = g.id;
    form['stage'].value = g.stage;
    jQuery('#planCourse_group_name').html(g.name);
    form['planCourse.terms'].value = planCourse.terms.replace(/^,/, '').replace(/,$/, '');
    if(!form['planCourse.terms'].value) form['planCourse.terms'].value="*";
    form['planCourse.termText'].value = planCourse.termText;
    form['planCourse.idx'].value = planCourse.idx;
    if(planCourse.weekstate) form['planCourse.weekstate'].value = planCourse.weekstate;
    jQuery(':radio[name=planCourse\\.compulsory]', form).prop('checked',false);
    if(planCourse.compulsory) {
      jQuery(':radio[name=planCourse\\.compulsory][value=1]', form).prop("checked",true);
    } else {
      jQuery(':radio[name=planCourse\\.compulsory][value=0]', form).prop("checked",true);
    }
    if (null != planCourse.department) {
     jQuery("#planCourse_department_name").html(planCourse.department.name);
    }
    if(null != planCourse.remark) {
      jQuery(form['planCourse.remark']).html(planCourse.remark);
    } else {
      jQuery(form['planCourse.remark']).html('');
    }
    openPlanCourseDialog();
    return false;
  }

  function addPlanCourse(courseGroupId) {
    var form = document.planCourseForm;
    var g = findGroup(courseGroupId);
    form['planCourse.group.id'].value = g.id;
    form['stage'].value = g.stage;
    jQuery('#planCourse_group_name').html(g.name);
    form["planCourse.id"].value = '';
    form["planCourse.terms"].value = '';
    clearPlanCourseForm();
    openCourseListDialog();
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
        return checkTerms(termInput, startTerm ,endTerm);
      }
      ,
      '开课学期为数字'+startTerm+'-'+endTerm+'和,组成,不指定学期请输入星号*'
    ).require();
    jQuery('#planCourse_remark').maxLength(500);
    res = jQuery.validity.end().valid;
    if(false == res) {
      return false;
    }
    return true;
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

  function validateBatchAddCourses(form) {
    var res = null;
    jQuery.validity.start();
    jQuery("#batchAddForm input[name='course.id']").each(function(i,e){
      jQuery('#terms' + e.value)
        .assert(
          function(termInput) {
            return checkTerms(termInput,startTerm,endTerm);
          }
          ,  '开课学期为数字'+startTerm+'-'+endTerm+'和逗号,组成,不指定学期请输入星号*'
        ).require();
    });
    res = jQuery.validity.end().valid;
    if(false == res) {
      return false;
    }
    closeDialog("planDialog");
    return true;
  }

  function validateBatchEditCourses(form) {
    var res = null;
    jQuery.validity.start();
    jQuery("#batchAddForm input[name='planCourse.id']").each(function(i,e){
      jQuery('#terms' + e.value)
        .assert(
          function(termInput) {
            return checkTerms(termInput,startTerm,endTerm);
          }
          ,  '开课学期为数字'+startTerm+'-'+endTerm+'和逗号,组成,不指定学期请输入星号*'
        ).require();
    });
    res = jQuery.validity.end().valid;
    if(false == res) {
      return false;
    }
    closeDialog("planDialog");
    return true;
  }
  function openPlanCourseDialog() {
    jQuery("#planDialog").modal('hide');
    jQuery("#planCourseFormDiv").modal('show');
  }
  function closePlanCourseDialog() {
    closeDialog("planCourseFormDiv");
  }
