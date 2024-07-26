[#ftl]
[@b.head/]
<div class="container">
[@b.toolbar title="教学培养方案修订"]
  bar.addClose();
[/@]
[#include "step.ftl"/]
[@displayStep  4/]
<div class="border-colored border-1px border-0px-tb" style="margin-bottom:20px">
  [@b.form theme="list" action="!saveTransfer"]
    [@b.textarea label="转专业" name="transfer" value=(doc.getText('transfer').contents)! cols="100" rows="5" maxlength="1000" rquired="true"/]
    [@b.formfoot]
      <input type="hidden" name="doc.id" value="${doc.id}"/>
      <input type="hidden" name="step" value="approaches"/>
      [@b.a href="!edit?id=${doc.id}&step=courses" class="btn btn-outline-primary btn-sm" ]<i class="fa fa-arrow-circle-left fa-sm"></i>上一步[/@]
      [@b.submit value="保存，进入下一步" /]
    [/@]
  [/@]
  </div>
</div>
[@b.foot/]
