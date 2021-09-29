[#ftl]
[@b.head /]

<script type="text/javascript" src="${base}/dwr/interface/studentServiceDwr.js"></script>
<script language="JavaScript" type="text/JavaScript" src="${base}/static/scripts/chosen/ajax-chosen.js"></script>

[@b.toolbar title="学生替代课程维护"]
    bar.addBack();
[/@]
[@b.form name="baseCodeSearchForm2" title="学生替代课程基本信息" theme="list"  action=b.rest.save(stdAlternativeCourse) onsubmit="return checkCourse()"]
    <input type="hidden" name="stdAlternativeCourse.std.id" id="stdAlternativeCourse.std.id"  value="${(stdAlternativeCourse.std.id)?if_exists}">

    [@b.field label="学号" required='true']
        [#if stdAlternativeCourse?? && stdAlternativeCourse.persisted]
            <input type="hidden" name="stdCode" value="${(stdAlternativeCourse.std.user.code)!}" />
            ${(stdAlternativeCourse.std.user.code)!}(${(stdAlternativeCourse.std.user.name)!})
        [#else]
            <input type="text" name="stdCode" style="width:200px;" value="${(stdAlternativeCourse.std.user.code)!}" onblur="javascript:getStudentByCode(this.value);"/>
            <span><font style="color:#1774C5" id="studentName_"></font></span>
        [/#if]
    [/@]
    [@b.field label="原课程" required='true']
        <select id="originCodes" name="originCodes" style="width:500px;" multiple="true">
         [#list (stdAlternativeCourse.olds)! as course]
            <option value="${(course.code)!}" selected>${(course.name)!}${(course.code)!}</option>
         [/#list]
        </select>
    [/@]

    [@b.field label="替代课程" required='true']
        <select id="substituteCodes" name="substituteCodes" style="width:500px;" multiple="true">
            [#list (stdAlternativeCourse.news)! as course]
            <option value="${(course.code)!}" selected>${(course.name)!}${(course.code)!}</option>
            [/#list]
        </select>
    [/@]
    [@b.textarea name='stdAlternativeCourse.remark' label='备注' cols="46" rows="2" value="${(stdAlternativeCourse.remark?html)!}" comment="最多300字!"/]
    [@b.formfoot]
        [@b.submit value="action.submit" /]
    [/@]
[/@]

<script>
    function checkCourse(){
        var stdId= jQuery("#stdAlternativeCourse\\.std\\.id").val();
        if(stdId) {

        } else {
            jQuery("#studentName_").parent().find(".error").remove();
            jQuery("#studentName_").parent().append("<label class='error' for='studentName_'>学号不能为空!</label>");
            return false;
        }

        if(jQuery("#originCodes_chosen").find(".search-choice").html()==null){
            jQuery("#originCodes").parent().find(".error").remove();
            jQuery("#originCodes").parent().append("<label class='error' for='originCodes'>原课程不能为空!</label>");
            return false;
        }

        if(jQuery("#substituteCodes_chosen").find(".search-choice").html()==null){
            jQuery("#substituteCodes").parent().find(".error").remove();
            jQuery("#substituteCodes").parent().append("<label class='error' for='substituteCodes'>替代课程不能为空!</label>");
            return false;
        }
        return true;
    }

    function getStudentByCode(code){
        jQuery("#studentName_").html('');
        jQuery("#stdAlternativeCourse\\.std\\.id").val("");
        jQuery("#studentName_").parent().find(".error").remove();
        if(code==""){
            jQuery("#studentName_").parent().append("<label class='error' for='studentName_'>请输入学号!</label>");
        }else{
            __fillStdPlanCourses(
                code,
                function(data){
                    var dataObj=eval("(" + data + ")");
                    jQuery("#originCodes").html('');
                    jQuery.each(dataObj.courses, function (i, course) {
                        var option = jQuery('<option/>');
                        option.html(course.name + '(' + course.code + ')');
                        option.val(course.code);
                        option.appendTo(jQuery('#originCodes'));
                    });
                    jQuery('#originCodes').trigger("chosen:updated.chosen");
                }
            );
        }
    }

    function __fillStdPlanCourses(code, callback) {
        studentServiceDwr.getStudentByProjectAndCode(
            code,
            '${project.id}',
            function(student){
                if(student){
                    jQuery("#studentName_").html(student.user.name);
                    jQuery("#stdAlternativeCourse\\.std\\.id").val(student.id);
                    jQuery.ajax({
                        type:"post",
                        url:"std!courses.action",
                        data:"studentCode="+jQuery("input[name=stdCode]").val(),
                        success: callback
                    });
                }else{
                    jQuery("input[name=stdCode]",document.baseCodeSearchForm2).val('');
                    jQuery("#studentName_").parent().append("<label class='error' for='studentName_'>该学号不存在!</label>");
                }
        });
    }

    jQuery(function() {
        jQuery("#originCodes").ajaxChosen(
        {
            method: 'POST',
            url: 'courseSearch!searchByCodeOrNameAjax.action',
            postData:function(){
            return {
                pageIndex:1,
                pageSize:10,
                excludeCodes:jQuery("#substituteCodes").val()
                }
            }
        }
        , function(data) {
            var dataObj=eval("(" + data + ")");
            var items = {};
            jQuery.each(dataObj.courses, function(i, course) {
                items[course.code] = course.name + '(' + course.code + ')';
            });
            jQuery("#substituteCodes").find('option').each(function() {
                if (!$(this).is(":selected")) {
                    return $(this).remove();
                }
            });
            jQuery("#substituteCodes").trigger("chosen:updated.chosen");
            return items;
        });

        jQuery("#substituteCodes").ajaxChosen(
            {
                method: 'POST',
                url: 'courseSearch!searchByCodeOrNameAjax.action',
                postData:function(){
                    return {
                        pageIndex:1,
                        pageSize:10,
                        excludeCodes:jQuery("#originCodes").val()
                        }
                }
            }
            , function(data) {
                var dataObj=eval("(" + data + ")");
                var items = {};
                jQuery.each(dataObj.courses, function(i, course) {
                    items[course.code] = course.name + '(' + course.code + ')';
                });
                 jQuery("#originCodes").find('option').each(function() {
                    if (!$(this).is(":selected")) {
                        return $(this).remove();
                    }
                });
                jQuery("#originCodes").trigger("chosen:updated.chosen");
                return items;
                }
        );
    })
</script>
[@b.foot /]
