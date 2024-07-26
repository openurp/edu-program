  [#assign doc_table_index=1/]
  [@displaySection "一、培养目标和专业特色" 1/]
  [@multi_line_p]${(doc.getText("summary").contents)!}[/@]
  [@displaySection "（一）人才培养目标" 2/]
  [@multi_line_p]${(doc.getText("goals.1").contents)!}[/@]
  [#list doc.objectives?sort_by("code") as obj]
    [@p2]培养目标${obj.code}：${obj.contents!}[/@]
  [/#list]
  [@displaySection "（二）人才培养特色" 2/]
  [@multi_line_p]${(doc.getText("goals.2").contents)!}[/@]
  [@displaySection "二、毕业要求及其对人才培养目标的支撑" 1/]
  [@displaySection "（一）毕业要求" 2/]
  [@multi_line_p]${(doc.getText("outcomes").contents)!}[/@]
  [@p2]根据培养目标，${program.major.name}专业毕业生应达到以下要求：[/@]
  [#list doc.outcomes?sort_by("idx") as obj]
    [@p2]毕业要求R${obj.idx}【${obj.title}】：${obj.contents!}[/@]
  [/#list]
  [@displaySection "（二）毕业要求与人才培养目标的支撑关系" 2/]
    [#assign outcomes = doc.outcomes?sort_by("idx")/]
    [#assign orderedObjectives=doc.objectives?sort_by("code")/]
    <table class="doc-table" style="font-weight:bold;page-break-inside: avoid;">
      <caption style="caption-side: top;text-align: center;padding: 0px;">表 ${doc_table_index}：毕业要求对人才培养目标的支撑关系</caption>
      [#assign doc_table_index = doc_table_index+1/]
      <tr>
        <td width="20%"></td>[#list orderedObjectives as o]<td>培养目标${o.code}</td>[/#list]
      </tr>
      [#list outcomes as outcome]
        <tr>
          <td style="width:100px">毕业要求${outcome.code}</td>
          [#list orderedObjectives as go]
          <td>[#if go.supportWith(outcome)]√[/#if]</td>
          [/#list]
        </tr>
      [/#list]
    </table>
  [@displaySection "三、学制和最低学分要求" 1/]
  [@p (doc.getText("credits").contents)!/]
  [@displaySection "四、主要课程和结构" 1/]
  [@displaySection "（一）主要课程" 2/]
  [@multi_line_p]${(doc.getText("courses").contents)!}[/@]
  [@displaySection "（二）课程结构" 2/]
  [#include "credit_stat.ftl"/]
  [@displaySection "五、课程设置与毕业要求达成关系矩阵" 1/]
  [#include "matrix.ftl"/]
  [@displaySection "六、专业教学计划表" 1/]
  [@p]1.专业教学计划表（见附表）[/@]
  [@displaySection "七、转专业" 1/]
  [@multi_line_p]${(doc.getText("transfer").contents)}[/@]
  [@displaySection "八、专业人才培养路径" 1/]
  [#if doc.getText("approach")??]
    [@multi_line_p]${(doc.getText("approach").contents)!}[/@]
  [/#if]
  [#assign approaches = doc.getTexts("approach.")?sort_by('name')/]
  [#list approaches as approach]
    <p style="white-space: preserve;text-indent:2em;margin:0.5rem 0rem 0.5rem 0rem;"><strong>${approach.name?substring(approach.name?index_of('.')+1)}.${approach.title}</strong></p>
    [@multi_line_p]${approach.contents}[/@]
    [#include "cert_table.ftl"/]
  [/#list]

  [#macro displaySection name level]
    <h${level+2} [#if level>1]style="margin-top:.5rem;"[/#if]>${name}</h${level+2}>
  [/#macro]

  [#macro p contents=""]
  <p style="white-space: preserve;text-indent:2em;">${contents}[#nested/]</p>
  [/#macro]

  [#macro p2 contents=""]
  <p style="white-space: preserve;text-indent:2em;" class="mb-0">${contents}[#nested/]</p>
  [/#macro]

  [#macro multi_line_p]
    [#assign cnts][#nested/][/#assign]
    [#assign ps = cnts?split("\n")]
    [#list ps as p]
    <p style="white-space: preserve;text-indent:2em;" class="mb-0">${p}</p>
    [/#list]
  [/#macro]
