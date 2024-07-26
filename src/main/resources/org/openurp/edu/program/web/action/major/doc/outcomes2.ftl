[#ftl]
[@b.head/]
<div class="container">
[@b.toolbar title="教学培养方案修订"]
  bar.addClose();
[/@]
[#include "step.ftl"/]
[@displayStep 1/]
<div class="border-colored border-1px border-0px-tb" style="margin-bottom:20px">
  [@b.form theme="list" action="!saveOutcomes"]
    [@b.textarea label="毕业要求概述"  name="outcomes" value="${(doc.getText('outcomes').contents)!}" cols="100" rows="4" placeholder="选填"
      maxlength="500" required="false"]
    [/@]
    [#list doc.outcomes?sort_by("idx") as outcome]
      [@b.textarea label=outcome.title name="${outcome.code}.contents" value=outcome.contents! cols="100" rows="3" maxlength="500" /]
    [/#list]
    [@b.field label="支撑矩阵"]
      [#assign outcomes = doc.outcomes?sort_by("idx")/]
      [#assign orderedObjectives=doc.objectives?sort_by("code")/]
      <div style="margin-left: 10rem;max-width: 700px;">
        <div class="text-muted">鼠标单击单元格，选中或取消</div>
        <table class="grid-table" style="text-align:center;">
          <tr>
            <td></td>[#list orderedObjectives as o]<td>培养目标${o.code}</td>[/#list]
          </tr>
          [#list outcomes as outcome]
            <tr>
              <td style="width:100px">毕业要求${outcome.code}</td>
              [#list orderedObjectives as go]
              <td onMouseOver="overCell(this)" onMouseOut="outCell(this)" onclick="toggleCell(this)" id="${outcome.code}_${go.id}"  title="点击选中或取消">[#if go.supportWith(outcome)]&#10004;[/#if]</td>
              [/#list]
            </tr>
          [/#list]
        </table>
      </div>
    [/@]
    [@b.formfoot]
      <input type="hidden" name="id" value="${doc.id}"/>
      <input type="hidden" name="step" value="credits"/>
      [#list orderedObjectives as go]
        <input type="hidden" name="G${go.id}.outcomes" id="G${go.id}.outcomes" value="${(go.outcomes)!}"/>
      [/#list]
      [@b.a href="!edit?id=${doc.id}&step=outcomes" class="btn btn-outline-primary btn-sm" ]<i class="fa fa-arrow-circle-left fa-sm"></i>上一步[/@]
      [@b.submit value="保存，进入下一步" /]
    [/@]
  [/@]
  </div>
  <script>
    function overCell(cell){
      cell.style.backgroundColor="#f0f0f0";
    }
    function outCell(cell){
      cell.style.backgroundColor="";
    }
    function toggleCell(cell){
      var id = cell.id;
      var underscoreIdx= id.indexOf("_")
      var outcomeCode=id.substring(0,underscoreIdx)
      var goId=id.substring(underscoreIdx+1)
      var hv = document.getElementById("G"+goId+".outcomes");
      if(cell.innerHTML=="\u2714"){
        cell.innerHTML="";
        hv.value = hv.value.replace(outcomeCode,"");
        hv.value = hv.value.replace(",,",",");
      }else{
        cell.innerHTML="&#10004";
        hv.value = (hv.value + "," + outcomeCode);
      }
    }
  </script>
</div>
[@b.foot/]
