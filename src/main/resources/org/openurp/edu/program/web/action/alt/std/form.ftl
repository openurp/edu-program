[#ftl]
[@b.head /]
[@b.toolbar title="学生替代课程维护"]
    bar.addBack();
[/@]
[@b.form name="altForm" title="学生替代课程基本信息" theme="list"  action=b.rest.save(alt) onsubmit="checkCourse"]
    [#if alt?? && alt.persisted]
    [@b.field label="学号" required='true']
      <input type="hidden" name="stdCode" value="${(alt.std.code)!}" />
      ${(alt.std.code)!} ${(alt.std.name)!}
    [/@]
    [#else]
      [@base.student title="学生" name="alt.std.id" required="true" onchange="fillStdPlanCourses(this.value)"/]
    [/#if]
    [@b.field label="原课程" required='true']
        <select id="oldCourses" name="old.id" style="width:500px;" multiple="true">
         [#list (alt.olds)! as course]
            <option value="${(course.code)!}" selected>${(course.name)!}${(course.code)!}</option>
         [/#list]
        </select>
    [/@]
    [@base.course label="替代课程" name="new.id" multiple="true" values=alt.news required='true'/]
    [@b.textarea name='alt.remark' label='备注' cols="46" rows="2" value="${(alt.remark?html)!}" comment="最多300字!"/]
    [@b.formfoot]
        [@b.submit value="action.submit" /]
    [/@]
[/@]

<script>
    bg.load(["bui-ajaxchosen"]);
    function checkCourse(form){
      if(jQuery("#oldCourses_chosen").find(".search-choice").html()==null){
        jQuery("#oldCourses").parent().find(".error").remove();
        jQuery("#oldCourses").parent().append("<label class='error' for='oldCourses'>原课程不能为空!</label>");
        return false;
      }
      return true;
    }
    function fillStdPlanCourses(stdId,cleanup){
      if(stdId){
        if (typeof cleanup == "undefined"){
          cleanup=true;
        }
        jQuery.ajax({
          type:"post",
          url:"${b.url('!courses')}?std.id="+stdId,
          success: function(data) {
            var dataObj=eval("(" + data + ")");
            if(cleanup)jQuery("#oldCourses").html('');
            jQuery.each(dataObj.courses, function (i, course) {
              var option = jQuery('<option/>');
              option.html(course.name + '(' + course.code + ')');
              option.val(course.id);
              option.appendTo(jQuery('#oldCourses'));
            });
            jQuery("#oldCourses").chosen()
          }
        });
      }
    }
    [#if alt?? && alt.persisted]
      fillStdPlanCourses('${alt.std.id}',false);
    [/#if]
</script>
[@b.foot /]
