[#ftl]
[#include "planFunctions.ftl" /]
<script>
      function mergeCourseTypeCell(tableId,levels,startRowIndex,bottomrows) {
          var table = document.getElementById(tableId)
          for(var x =levels - 1; x >= 0 ; x--) {
              var content = '';
              var firstY = -1;
              for(var y = startRowIndex; y < table.rows.length - bottomrows; y++) {
                  if(table.rows[y] == undefined || table.rows[y].cells[x] == undefined) {
                      continue;
                  }
                  if(content == table.rows[y].cells[x].innerHTML && table.rows[y].cells[x].className == 'group') {
                      table.rows[y].deleteCell(x);
                      table.rows[firstY].cells[x].rowSpan++;
                  }
                  else {
                      content = table.rows[y].cells[x].innerHTML;
                      // 如果是纯数字或‘学分小计’则不合并
                      if(table.rows[y].cells[x].className != 'group') {
                          content = '';
                      }
                      firstY = y;
                  }
              }
          }
      }
 </script>
[#assign program=plan.program/]
<p style="text-align:center;font-weight:bold;font-size:1.2rem;margin:1rem 0rem 1rem 1rem">
${topSeq.next}、${program.major.name}[#if program.direction??]（${program.direction.name}）[/#if]指导性教学计划（含必修课）
</p>
[#include "course_overall.ftl" /]

[#if stat.hasOptional || stat.hasPractice]
<div style="page-break-after:always;clear:both;"></div>
[#if stat.hasOptional]
<p style="text-align:center;font-weight:bold;font-size:1.2rem;margin:1rem 0rem 1rem 1rem">
${topSeq.next}、${program.major.name}[#if program.direction??]（${program.direction.name}）[/#if]指导性教学计划（选修课部分）
</p>
[#include "course_optional.ftl" /]
[/#if]
[#if stat.hasPractice]
<p style="text-align:center;font-weight:bold;font-size:1.2rem;margin:1rem 0rem 1rem 1rem">
${topSeq.next}、${program.major.name}[#if program.direction??]（${program.direction.name}）[/#if]指导性教学计划（实践课部分）
</p>
[#include "course_practical.ftl" /]
[/#if]
[/#if]
<br/>
