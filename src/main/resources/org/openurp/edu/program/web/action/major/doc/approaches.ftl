[#ftl]
[@b.head/]
<div class="container">
[@b.toolbar title="课程教学大纲编写"]
  bar.addClose();
[/@]
[#include "step.ftl"/]
[@displayStep  5/]

[#assign approaches = doc.getTexts("approach.")?sort_by('name')/]
<div class="border-colored border-1px border-0px-tb" style="margin-bottom:20px">
    [@b.form theme="list" action="!saveApproach0" target="_self"]
      [@b.textarea label="专业人才培养路径" name="approach" rows="5" cols="80" required="false" value=(doc.getText("approach").contents)! maxlength="1000"/]
      [@b.formfoot]
        <input type="hidden" name="doc.id" value="${doc.id}"/>
        [@b.submit value="保存" /]
      [/@]
    [/@]
    [#list approaches as approach]
      [#include "approachInfo.ftl"/]
    [/#list]
    <div class="card card-info card-primary card-outline">
        [@b.card_header]
          <div class="card-title"><i class="fas fa-edit"></i>&nbsp;新增培养路径--序号${approaches?size+1}</div>
          [@b.card_tools]
            <button type="button" class="btn btn-tool" data-card-widget="collapse">
              <i class="fas fa-plus"></i>
            </button>
          [/@]
        [/@]
        <div class="card-body" style="display:none">
          [@b.form theme="list" action="!saveApproach" target="_self"]
            [@b.textfield label="标题" name="text.title"  required="true" maxlength="100"/]
            [@b.textarea label="内容" name="text.contents" rows="9" cols="80" required="true" maxlength="1000"/]
            [@b.formfoot]
              <input type="hidden" name="doc.id" value="${doc.id}"/>
              <input type="hidden" name="text.name" value="approach.${approaches?size+1}"/>
              [@b.submit value="保存" /]
            [/@]
          [/@]
        </div>
    </div>
  </div>

</div>
[@b.foot/]
