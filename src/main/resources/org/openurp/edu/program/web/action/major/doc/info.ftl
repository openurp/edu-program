[@b.head/]
[#macro header_title title]
  <p style="width:100%;font-weight:bold;font-family: 宋体;font-size: 15px;">${title}</p>
[/#macro]
[#macro p contents=""]
<p style="white-space: preserve;margin-bottom:0px;">   ${contents} [#nested/]</p>
[/#macro]

<div class="container" style="font-family: 宋体;font-size: 14px;padding:0px 0px;box-shadow: 0 2px 10px 1px rgba(0, 0, 0, 0.2);padding:20px">
  <div>
    [@header_title "一、培养目标和专业特色"/]
    [@header_title "（一）人才培养目标"/]
    [@p doc.getText("goals.1").contents!/]
    [#list doc.objectives?sort_by('code') as objective]
    [@p]培养目标${objective.code}：${objective.contents!}[/@]
    [/#list]
    [@header_title "（二）人才培养特色"/]
    [@p doc.getText("goals.2").contents!/]
  </div>
</div>
[@b.foot/]
