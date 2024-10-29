[@b.head /]
[#assign titleName]复制培养方案(${copyFrom.grade.code} ${copyFrom.level.name} ${copyFrom.major.name} ${(copyFrom.direction.name)!})[/#assign]
[@b.toolbar title=titleName]
   bar.addItem("返回列表", "backToList()","action-backward");
   function backToList() {
     bg.form.submit(document.searchForm);
   }
[/@]
  [@b.form name="planForm" id="planForm" action=b.rest.save(program) theme="list"]
    [@b.textfield id="program_name" name='program.name' label="名称" value=program.name!
        disabled="disabled" required='true' maxlength='200' size="30" ]
        <input type='checkbox' id='autoname' name='autoname' value='1' onclick='switchAutoName()' checked/>自动命名
    [/@]
    [@b.select name="program.grade.id" label="年级" value=program.grade required='true' items=grades style="width:100px"/]
    [@b.select name='program.department.id' label='院系' items=departs value=program.department required='true' style="width:200px"/]
    [@b.select id='level' name='program.level.id' items=project.levels label="培养层次" value=program.level required='true' style="width:200px"/]
    [#if project.eduTypes?size>1]
    [@b.select name='program.eduType.id' label="培养类型" items=project.eduTypes value=program.eduType! required='true' /]
    [/#if]
    [@b.select label="学生类别" name="stdType.id" multiple="multiple" values=program.stdTypes items=project.stdTypes style="width:400px"/]
    [@b.select id="major" name='program.major.id' label='专业' items=majors value=program.major required='true' style="width:200px"/]
    [@b.select name='program.direction.id' label='专业方向' items=directions value=program.direction! style="width:200px" /]
    [@base.code type="study-types" name="program.studyType.id" label="学习形式" value=program.studyType required="true" style="width:200px"/]
    [@b.textfield label='学制' name="program.duration" check="match('number').greaterThan(0)" value=program.duration! required="true" style="width:40px" maxlength="4" comment="年制"/]
    [@b.textfield label='起始学期' name='program.startTerm' check="match('integer').greaterThan(0)" required='true' value=program.startTerm style='width:40px' maxlength='2' comment='正整数'/]
    [@b.textfield label='结束学期' name='program.endTerm' check="match('integer').greaterThan(0)" required='true' value=program.endTerm
         style='width:40px' maxlength='2' comment='正整数(最多两位)'/]
    [@b.select items=degrees name='program.degree.id' label='学位' empty="..." value=program.degree! width="200px"/]
    [@b.textfield name='program.degreeGpa' label='学位绩点' maxlength="3" size="3" required="false" value=program.degreeGpa! /]
    [@b.select name='degreeCertificate.id' label='学位要求的校外证书' required="false" values=program.degreeCertificates! items=certificates multiple="true"/]
    [@b.startend label="起止日期" name="program.beginOn,program.endOn" required="true" start=program.beginOn end=program.endOn/]
    [@b.textarea name='program.remark' cols='80' rows='3' maxlength='800' label='备注' comment="(限800字)" value=program.remark!/]
    [@b.formfoot]
        [#if project.eduTypes?size==1]
        <select name='program.eduType.id' style="display:none"><option value="${project.eduTypes?first.id}" selected>${project.eduTypes?first.name}</option></select>
        [/#if]
        <input type="hidden" name="copyFrom.id" value="${copyFrom.id}"/>
        [@b.submit value="保存"/]
        [@b.reset/]
    [/@]
  [/@]
  <script type="text/javascript">
    function switchAutoName() {
      if(document.getElementById('autoname').checked) {
        jQuery('#program_name').prop("disabled",true);
      } else {
        jQuery('#program_name').prop('disabled',false);
      }
    }

    jQuery(function() {
      switchAutoName();
      var gradeBeginOns = {}
      [#list grades as grade]
         gradeBeginOns["${grade.id}"]="${grade.beginOn?string('yyyy-MM-dd')}";
      [/#list]
      /*
       * 当年级发生变化的时候，自动更新开始时间，结束时间
       */
      jQuery("#planForm [name='program.grade.id']").change(function(){
        jQuery("#planForm [name='program.beginOn']").val("");
        var gradeId = jQuery(this).val();
        var start =gradeBeginOns[gradeId];
        jQuery("#planForm [name='program.beginOn']").val(start);
        setEnd(jQuery("#major").val(),jQuery("#level").val(),start);
      });

      /* 当专业发生变化的时候，自动更新结束时间 */
      jQuery("#major").change(function() {
        jQuery("#planForm [name='program.endOn']").val("");
        setEnd(jQuery(this).val(), jQuery("#level").val(),jQuery("#planForm [name='program.beginOn']").val());
      });

      /** 当开始时间发生变化的时候，自动更新结束时间  */
      jQuery("#planForm [name='program.beginOn']").blur(function() {
        if(jQuery("#major").val()) {
          setEnd(jQuery("#major").val(), jQuery("#level").val(),jQuery(this).val());
        }
      });
    });

    function setEnd(majorId,levelId,start){
      if(majorId && levelId && start) {
        jQuery.ajax({
          async : false,
          url : '${b.url('!duration')}',
          method : "POST",
          data : {majorId : majorId, levelId:levelId,start:start},
          success : function(data) {
              var result = eval('(' + data + ')');
              jQuery("#planForm [name='program.endOn']").val(result.endOn);
              jQuery("#planForm [name='program.duration']").val(result.duration);
          }
        });
      }
    }
  </script>
[@b.foot /]
