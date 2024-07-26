  [@displaySection "一、培养目标和专业特色" 1/]
  [@displaySection "（一）人才培养目标" 2/]
  [@p2]${(doc.getText("goals.1").contents)!}[/@]
  [#list doc.objectives?sort_by("code") as obj]
    [@p2]培养目标${obj.code}：${obj.contents!}[/@]
  [/#list]
  [@displaySection "（二）人才培养特色" 2/]
  [@p (doc.getText("goals.2").contents)!/]
  [@displaySection "二、毕业要求及其对人才培养目标的支撑" 1/]
  [@displaySection "（一）毕业要求" 2/]
  [@p2]根据培养目标，${program.major.name}专业毕业生应达到以下要求：[/@]
  [#list doc.outcomes?sort_by("idx") as obj]
    [@p2]毕业要求R${obj.idx}【${obj.title}】：${obj.contents!}[/@]
  [/#list]
  [@displaySection "（二）毕业要求与人才培养目标的支撑关系" 2/]
    [#assign outcomes = doc.outcomes?sort_by("idx")/]
    [#assign orderedObjectives=doc.objectives?sort_by("code")/]
    <table class="grid-table" style="text-align:center;font-weight:bold;">
      <tr>
        <td></td>[#list orderedObjectives as o]<td>培养目标${o.code}</td>[/#list]
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
  [@p (doc.getText("courses").contents)!/]
  [@displaySection "（二）课程结构" 2/]
  [#include "../report/credit_stat.ftl"/]
  [@displaySection "五、课程设置与毕业要求达成关系矩阵" 1/]
    [#assign cot = (doc.getTable("courseOutcome").contents)!'<table border="1"></table>'/]
    [#assign cot = cot?replace('<table border="1">','<table id="course_outcome_matrix_${program.id}" style="text-align:center" class="grid-table">')/]
  [@p cot/]
  [@displaySection "六、专业教学计划表" 1/]
  [@p]<a href="#九、专业教学计划表（附表）">1.专业教学计划表（见附表）</a>[/@]

  [@displaySection "七、转专业" 1/]
  [@p (doc.getText("transfer").contents)!/]
  [@displaySection "八、专业人才培养路径" 1/]
  [#if doc.getText("approach")??]
    [@p (doc.getText("approach").contents)!/]
  [/#if]
  [#assign approaches = doc.getTexts("approach.")?sort_by('name')/]
  [#list approaches as approach]
    [@p2]<strong>${approach.name?substring(approach.name?index_of('.')+1)}.${approach.title}</strong>[/@]
    [@p approach.contents/]
    [#if approach.linkTable??]
    ${(doc.getTable(approach.linkTable).contents)!}
    [/#if]
  [/#list]

  [#macro displaySection name level]
    [#if level>1]<h${level} style="margin-top:.5rem;">${name}</h${level}>
    [#else]
    <div class="section">
      <h${level}>
        <a class="q-anchor q-heading-anchor" name="${name}"></a>${name}
      </h${level}>
    </div>
    [/#if]
  [/#macro]

  [#macro p contents=""]
  <p style="white-space: preserve;text-indent:2em;">${contents}[#nested/]</p>
  [/#macro]

  [#macro p2]
  <p style="white-space: preserve;text-indent:2em;" class="mb-0">[#nested/]</p>
  [/#macro]
  <script>
    jQuery(function(){
      //表头加粗居中
      jQuery("#course_outcome_matrix_${program.id}").find("tbody tr:nth-child(-n+2)").each(function(i,e){jQuery(e).css({'text-align':'center','font-weight':'bold'})})

      jQuery("#course_outcome_matrix_22700").find("tbody tr:nth-child(1) td:nth-child(2)").each(function(i,e){jQuery(e).css({'width':'30%'})})

    });
  </script>
