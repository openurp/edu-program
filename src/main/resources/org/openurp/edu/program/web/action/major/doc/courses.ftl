[#ftl]
[@b.head/]
<div class="container">
[@b.toolbar title="教学培养方案修订"]
  bar.addClose();
[/@]
[#include "step.ftl"/]
[@displayStep  3/]
<div class="border-colored border-1px border-0px-tb" style="margin-bottom:20px">
  [@b.form theme="list" action="!saveCourses"]
    [@b.editor theme="mini" name="courseOutcome" label="课程设置与毕业要求达成关系矩阵" rows="40" cols="80"
     style=editorstyle maxlength="20000" required="true" value=(doc.getTable('courseOutcome').contents)! /]
    [@b.formfoot]
      <input type="hidden" name="doc.id" value="${doc.id}"/>
      <input type="hidden" name="step" value="transfer"/>
      [@b.a href="!edit?id=${doc.id}&step=credits" class="btn btn-outline-primary btn-sm" ]<i class="fa fa-arrow-circle-left fa-sm"></i>上一步[/@]
      [@b.submit value="保存，进入下一步" /]
    [/@]
  [/@]
  </div>
</div>
[@b.foot/]
