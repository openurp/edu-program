[#ftl]
[@b.head/]
<div class="container">
[@b.toolbar title="教学培养方案修订"]
  bar.addClose();
[/@]
[#include "step.ftl"/]
[@displayStep  2/]
<div class="border-colored border-1px border-0px-tb" style="margin-bottom:20px">
  [@b.form theme="list" action="!saveCredits"]
    [@b.textarea label="学制和最低学分要求" name="credits" value=(doc.getText('credits').contents)! cols="100" rows="5" maxlength="1000" rquired="true"/]
    [@b.textarea label="主要课程" name="courses" value=(doc.getText('courses').contents)! cols="100" rows="5" maxlength="1000" rquired="true"/]
    [@b.formfoot]
      <input type="hidden" name="doc.id" value="${doc.id}"/>
      <input type="hidden" name="step" value="courses"/>
      [@b.a href="!edit?id=${doc.id}&step=outcomes2" class="btn btn-outline-primary btn-sm" ]<i class="fa fa-arrow-circle-left fa-sm"></i>上一步[/@]
      [@b.submit value="保存，进入下一步" /]
    [/@]
  [/@]
  </div>
</div>
[@b.foot/]
