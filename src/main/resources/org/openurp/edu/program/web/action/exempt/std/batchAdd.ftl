[#ftl]
[@b.head /]
[@b.toolbar title="批量添加免修课程"]
    bar.addBack();
[/@]
[@b.form  theme="list" action="!batchSave" ]
    [@base.course name='course.id' label="课程" required="true" /]
    [@b.textarea name="stdCodes" label="学号"  required="true" rows="10" cols="80" maxlength="30000"/]
    [@b.formfoot]
      [@b.submit value="action.submit" /]
    [/@]
[/@]
[#list 1..10 as i]
  <br/>
[/#list]
[@b.foot /]
