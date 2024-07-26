[#ftl]
[@b.head/]
<div class="container">
[@b.toolbar title="教学培养方案修订"]
  bar.addClose();
[/@]
[#include "step.ftl"/]
[@displayStep  0/]
<div class="border-colored border-1px border-0px-tb" style="margin-bottom:20px">
  [@b.form theme="list" action="!saveObjectives"]
    [@b.textarea label="概述"  name="summary" value="${(doc.getText('summary').contents)!}" cols="100" rows="4" placeholder="选填"
      maxlength="500" required="false"]
    [/@]
    [@b.textarea label="人才培养目标" name="goals.1" value=(doc.getText('goals.1').contents)! cols="100" rows="5" maxlength="1000" rquired="true"/]
    [#list 1..8 as i]
    [@b.textarea label="培养目标G"+i name="G"+i value="${(doc.getObjective('G'+i).contents)!}" cols="100" rows="3"
      maxlength="500" comment="500字以内" placeholder=((placeholders[i-1])!"") /]
    [/#list]
    [@b.textarea label="人才培养特色" name="goals.2" value=(doc.getText('goals.2').contents)! cols="100" rows="10" maxlength="3000" required="true"]
    [/@]
    [@b.formfoot]
      <input type="hidden" name="doc.id" value="${doc.id}"/>
      <input type="hidden" name="step" value="outcomes"/>
      [@b.a href="!edit?id=${doc.id}" class="btn btn-outline-primary btn-sm" ]<i class="fa fa-arrow-circle-left fa-sm"></i>上一步[/@]
      [@b.submit value="保存，进入下一步" /]
    [/@]
  [/@]
  </div>
</div>
[@b.foot/]
